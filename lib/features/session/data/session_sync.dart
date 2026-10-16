import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/app_database.dart';
import '../../../core/network/api_client.dart';

part 'session_sync.g.dart';

// Manda a la API lo que está pendiente en la BD local, en orden:
// 1) crear sesiones → 2) series (crea el exercise-log si hace falta) →
// 3) completar sesiones. Todos los endpoints son idempotentes, así que
// reintentar después de un corte es seguro. Una sola corrida a la vez; si
// falla la red, reintenta con backoff (15 s … 5 min) y al volver a la app.
class SessionSync {
  SessionSync(this._db, this._api) {
    _lifecycle = AppLifecycleListener(onResume: kick);
  }

  final AppDatabase _db;
  final Dio _api;
  late final AppLifecycleListener _lifecycle;

  bool _running = false;
  bool _again = false;
  int _failures = 0;
  Timer? _retry;

  /// Pide una corrida (después de cada escritura local, al abrir la app…).
  void kick() {
    _retry?.cancel();
    if (_running) {
      _again = true;
      return;
    }
    unawaited(_run());
  }

  Future<void> _run() async {
    _running = true;
    try {
      do {
        _again = false;
        await _startSessions();
        await _pushSets();
        await _completeSessions();
      } while (_again);
      _failures = 0;
    } on DioException catch (e) {
      _failures++;
      final seconds = min(300, 15 * pow(2, _failures - 1).toInt());
      debugPrint(
        'SessionSync: falló (${e.type} ${e.response?.statusCode}), reintento en ${seconds}s',
      );
      _retry = Timer(Duration(seconds: seconds), kick);
    } finally {
      _running = false;
    }
  }

  Future<void> _startSessions() async {
    final pending = await (_db.select(
      _db.localSessions,
    )..where((s) => s.remoteId.isNull())).get();
    for (final s in pending) {
      final res = await _api.post<Map<String, dynamic>>(
        '/workout-sessions',
        data: {
          'blockAssignmentId': s.assignmentId,
          'blockDayId': s.dayId,
          'scheduledDate': _dateOnly(s.startedAt),
        },
      );
      await (_db.update(_db.localSessions)..where(
            (x) =>
                x.assignmentId.equals(s.assignmentId) & x.dayId.equals(s.dayId),
          ))
          .write(
            LocalSessionsCompanion(remoteId: Value(res.data!['id'] as String)),
          );
    }
  }

  Future<void> _pushSets() async {
    final pending = await (_db.select(
      _db.localSets,
    )..where((s) => s.synced.equals(false))).get();
    for (final set in pending) {
      final session =
          await (_db.select(_db.localSessions)..where(
                (x) =>
                    x.assignmentId.equals(set.assignmentId) &
                    x.dayId.equals(set.dayId),
              ))
              .getSingleOrNull();
      if (session?.remoteId == null) continue; // se crea en la próxima vuelta

      final logId = await _exerciseLogId(
        set.assignmentId,
        set.dayExerciseId,
        session!.remoteId!,
      );
      await _api.put<Map<String, dynamic>>(
        '/workout-sessions/exercise-logs/$logId/sets/${set.setNumber}',
        data: {
          'weight': set.weight,
          'weightUnit': set.weightUnit,
          'reps': set.reps,
          'rir': set.rir,
        },
      );
      // Solo marcar si no la editaron mientras se mandaba (si no, va en la próxima)
      await (_db.update(_db.localSets)..where(
            (x) =>
                x.assignmentId.equals(set.assignmentId) &
                x.dayExerciseId.equals(set.dayExerciseId) &
                x.setNumber.equals(set.setNumber) &
                x.updatedAt.equals(set.updatedAt),
          ))
          .write(const LocalSetsCompanion(synced: Value(true)));
    }
  }

  Future<String> _exerciseLogId(
    String assignmentId,
    String dayExerciseId,
    String sessionId,
  ) async {
    final cached =
        await (_db.select(_db.localExerciseLogs)..where(
              (x) =>
                  x.assignmentId.equals(assignmentId) &
                  x.dayExerciseId.equals(dayExerciseId),
            ))
            .getSingleOrNull();
    if (cached != null) return cached.remoteId;

    final res = await _api.post<Map<String, dynamic>>(
      '/workout-sessions/$sessionId/exercise-logs',
      data: {'blockDayExerciseId': dayExerciseId},
    );
    final id = res.data!['id'] as String;
    await _db
        .into(_db.localExerciseLogs)
        .insertOnConflictUpdate(
          LocalExerciseLogsCompanion.insert(
            assignmentId: assignmentId,
            dayExerciseId: dayExerciseId,
            remoteId: id,
          ),
        );
    return id;
  }

  Future<void> _completeSessions() async {
    final pending =
        await (_db.select(_db.localSessions)..where(
              (s) =>
                  s.completedAt.isNotNull() &
                  s.completeSynced.equals(false) &
                  s.remoteId.isNotNull(),
            ))
            .get();
    for (final s in pending) {
      // Completar recién cuando subieron todas sus series
      final unsynced =
          await (_db.select(_db.localSets)..where(
                (x) =>
                    x.assignmentId.equals(s.assignmentId) &
                    x.dayId.equals(s.dayId) &
                    x.synced.equals(false),
              ))
              .get();
      if (unsynced.isNotEmpty) continue;

      await _api.put<Map<String, dynamic>>(
        '/workout-sessions/${s.remoteId}/complete',
      );
      await (_db.update(_db.localSessions)..where(
            (x) =>
                x.assignmentId.equals(s.assignmentId) & x.dayId.equals(s.dayId),
          ))
          .write(const LocalSessionsCompanion(completeSynced: Value(true)));
    }
  }

  static String _dateOnly(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void dispose() {
    _retry?.cancel();
    _lifecycle.dispose();
  }
}

@Riverpod(keepAlive: true)
SessionSync sessionSync(Ref ref) {
  final sync = SessionSync(
    ref.watch(appDatabaseProvider),
    ref.watch(apiClientProvider),
  );
  ref.onDispose(sync.dispose);
  // Lo que quedó pendiente de la última vez que se abrió la app
  sync.kick();
  return sync;
}
