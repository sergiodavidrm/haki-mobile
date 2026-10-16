import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/app_database.dart';
import '../../../core/units/weight_unit.dart';
import 'session_sync.dart';

part 'session_store.g.dart';

// Tipos propios para la UI/providers: riverpod_generator no ve las clases
// que genera drift (LocalSession/LocalSet), así que no salen del store.

class LocalSessionInfo {
  const LocalSessionInfo({
    required this.dayId,
    required this.startedAt,
    this.completedAt,
  });

  final String dayId;
  final DateTime startedAt;
  final DateTime? completedAt;
}

class LocalSetEntry {
  const LocalSetEntry({
    required this.dayExerciseId,
    required this.setNumber,
    this.weight,
    required this.unit,
    this.reps,
    this.rir,
    required this.synced,
  });

  final String dayExerciseId;
  final int setNumber;
  final double? weight;
  final WeightUnit unit;
  final int? reps;
  final int? rir;

  /// false = todavía no llegó a la API.
  final bool synced;
}

LocalSessionInfo _session(LocalSession s) => LocalSessionInfo(
  dayId: s.dayId,
  startedAt: s.startedAt,
  completedAt: s.completedAt,
);

LocalSetEntry _set(LocalSet s) => LocalSetEntry(
  dayExerciseId: s.dayExerciseId,
  setNumber: s.setNumber,
  weight: s.weight,
  unit: WeightUnit.parse(s.weightUnit),
  reps: s.reps,
  rir: s.rir,
  synced: s.synced,
);

// Escrituras/lecturas locales del entreno. Cada escritura dispara el sync.
class SessionStore {
  SessionStore(this._db, this._sync);

  final AppDatabase _db;
  final SessionSync _sync;

  Stream<LocalSessionInfo?> watchSession(String assignmentId, String dayId) =>
      (_db.select(_db.localSessions)..where(
            (s) => s.assignmentId.equals(assignmentId) & s.dayId.equals(dayId),
          ))
          .watchSingleOrNull()
          .map((s) => s == null ? null : _session(s));

  /// Sesiones locales de un programa (para pisar el estado del día en Hoy).
  Stream<List<LocalSessionInfo>> watchSessionsOf(String assignmentId) =>
      (_db.select(_db.localSessions)
            ..where((s) => s.assignmentId.equals(assignmentId)))
          .watch()
          .map((rows) => rows.map(_session).toList());

  Stream<List<LocalSetEntry>> watchSets(String assignmentId, String dayId) =>
      (_db.select(_db.localSets)..where(
            (s) => s.assignmentId.equals(assignmentId) & s.dayId.equals(dayId),
          ))
          .watch()
          .map((rows) => rows.map(_set).toList());

  /// Idempotente: si ya estaba empezada no toca nada.
  Future<void> start(String assignmentId, String dayId) async {
    await _db
        .into(_db.localSessions)
        .insert(
          LocalSessionsCompanion.insert(
            assignmentId: assignmentId,
            dayId: dayId,
            startedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    _sync.kick();
  }

  Future<void> saveSet({
    required String assignmentId,
    required String dayId,
    required String dayExerciseId,
    required int setNumber,
    required double? weight,
    required WeightUnit unit,
    required int? reps,
    required int? rir,
  }) async {
    await start(assignmentId, dayId);
    await _db
        .into(_db.localSets)
        .insertOnConflictUpdate(
          LocalSetsCompanion.insert(
            assignmentId: assignmentId,
            dayId: dayId,
            dayExerciseId: dayExerciseId,
            setNumber: setNumber,
            weight: Value(weight),
            weightUnit: unit.api,
            reps: Value(reps),
            rir: Value(rir),
            updatedAt: DateTime.now(),
            synced: const Value(false),
          ),
        );
    _sync.kick();
  }

  /// Cosas guardadas en el teléfono que todavía no llegaron a la API
  /// (series + sesiones sin crear o sin completar).
  Future<int> pendingCount() async {
    final sets = await (_db.select(
      _db.localSets,
    )..where((s) => s.synced.equals(false))).get();
    final sessions =
        await (_db.select(_db.localSessions)..where(
              (s) =>
                  s.remoteId.isNull() |
                  (s.completedAt.isNotNull() & s.completeSynced.equals(false)),
            ))
            .get();
    return sets.length + sessions.length;
  }

  Future<void> complete(String assignmentId, String dayId) async {
    await start(assignmentId, dayId);
    await (_db.update(_db.localSessions)..where(
          (s) => s.assignmentId.equals(assignmentId) & s.dayId.equals(dayId),
        ))
        .write(LocalSessionsCompanion(completedAt: Value(DateTime.now())));
    _sync.kick();
  }
}

@Riverpod(keepAlive: true)
SessionStore sessionStore(Ref ref) => SessionStore(
  ref.watch(appDatabaseProvider),
  ref.watch(sessionSyncProvider),
);
