import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_compress/video_compress.dart';

import '../../../core/db/app_database.dart';
import '../../../core/network/api_client.dart';
import 'video_files.dart';
import 'video_trim.dart';

part 'session_sync.g.dart';

// Manda a la API lo que está pendiente en la BD local, en orden:
// 1) crear sesiones → 2) series y notas (crean el exercise-log si hace falta)
// → 3) completar sesiones → 4) videos, de a uno (ver _pushVideo). Todos los
// endpoints son idempotentes, así que reintentar después de un corte es
// seguro. Una sola corrida a la vez; si falla la red, reintenta con backoff
// (15 s … 5 min) y al volver a la app.
class SessionSync {
  SessionSync(this._db, this._api, [Dio? upload]) : _upload = upload ?? Dio() {
    _lifecycle = AppLifecycleListener(onResume: kick);
  }

  final AppDatabase _db;
  final Dio _api;

  /// Sin el JWT de la API: sube directo a Cloudinary.
  final Dio _upload;
  late final AppLifecycleListener _lifecycle;

  bool _running = false;
  bool _again = false;

  /// Alguna nota o Hecho rechazado en esta corrida: se reintenta más tarde
  /// (no en cada kick) para no repetir el mismo 409 miles de veces.
  bool _rejected = false;
  DateTime? _rejectedUntil;
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
      final retryRejected =
          _rejectedUntil == null || DateTime.now().isAfter(_rejectedUntil!);
      _rejected = false;
      do {
        _again = false;
        await _startSessions();
        await _pushSets();
        if (retryRejected) {
          await _pushNotes();
          await _pushDone();
        }
        await _completeSessions();
        // Un video por vuelta: series nuevas no esperan a toda la cola
        if (await _pushVideo()) _again = true;
      } while (_again);
      _failures = 0;
      if (retryRejected) {
        _rejectedUntil = _rejected
            ? DateTime.now().add(const Duration(minutes: 10))
            : null;
      }
    } on DioException catch (e) {
      _failures++;
      final seconds = min(300, 15 * pow(2, _failures - 1).toInt());
      debugPrint(
        'SessionSync: falló (${e.type} ${e.response?.statusCode} '
        '${e.requestOptions.method} ${e.requestOptions.uri}) '
        '${e.response?.data}, reintento en ${seconds}s',
      );
      _retry = Timer(Duration(seconds: seconds), kick);
    } catch (e, st) {
      // Cualquier otra cosa (plugin de video, archivo…): mismo backoff, para
      // que la cola no quede frenada hasta el próximo kick
      _failures++;
      final seconds = min(300, 15 * pow(2, _failures - 1).toInt());
      debugPrint('SessionSync: error ($e), reintento en ${seconds}s');
      debugPrint('$st');
      _retry = Timer(Duration(seconds: seconds), kick);
    } finally {
      _running = false;
    }
  }

  /// Crea en la API las sesiones que ya tienen algo para subir (una serie, una
  /// nota o Finalizar), con la fecha en que entrenó: la de la primera serie o
  /// nota. Abrir un día solo para mirarlo no crea nada: antes la fecha quedaba
  /// la de cuando se abrió (un día abierto el lunes y entrenado el jueves
  /// figuraba como del lunes: "7 días sin entrenar" en la campana del coach).
  Future<void> _startSessions() async {
    final pending = await (_db.select(
      _db.localSessions,
    )..where((s) => s.remoteId.isNull())).get();
    for (final s in pending) {
      final trainedAt = await _trainedAt(s);
      if (trainedAt == null) continue;
      final res = await _api.post<Map<String, dynamic>>(
        '/workout-sessions',
        data: {
          'blockAssignmentId': s.assignmentId,
          'blockDayId': s.dayId,
          'scheduledDate': _dateOnly(trainedAt),
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

  /// Cuándo empezó a entrenar ese día: la primera serie o nota guardada; si
  /// solo tocó Finalizar, ese momento. null = todavía no hay nada que subir.
  Future<DateTime?> _trainedAt(LocalSession s) async {
    final sets =
        await (_db.select(_db.localSets)..where(
              (x) =>
                  x.assignmentId.equals(s.assignmentId) &
                  x.dayId.equals(s.dayId),
            ))
            .get();
    final notes =
        await (_db.select(_db.localNotes)..where(
              (x) =>
                  x.assignmentId.equals(s.assignmentId) &
                  x.dayId.equals(s.dayId),
            ))
            .get();
    final done =
        await (_db.select(_db.localDone)..where(
              (x) =>
                  x.assignmentId.equals(s.assignmentId) &
                  x.dayId.equals(s.dayId),
            ))
            .get();
    final times = [
      for (final x in sets) x.updatedAt,
      for (final n in notes) n.updatedAt,
      for (final d in done) d.updatedAt,
      ?s.completedAt,
    ];
    if (times.isEmpty) return null;
    return times.reduce((a, b) => a.isBefore(b) ? a : b);
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
      final res = await _api.put<Map<String, dynamic>>(
        '/workout-sessions/exercise-logs/$logId/sets/${set.setNumber}',
        data: {
          'weight': set.weight,
          'weightUnit': set.weightUnit,
          'reps': set.reps,
          'rir': set.rir,
        },
      );
      Expression<bool> sameSet(LocalSets x) =>
          x.assignmentId.equals(set.assignmentId) &
          x.dayExerciseId.equals(set.dayExerciseId) &
          x.setNumber.equals(set.setNumber);
      await (_db.update(_db.localSets)..where(sameSet)).write(
        LocalSetsCompanion(remoteId: Value(res.data?['id'] as String?)),
      );
      // Solo marcar si no la editaron mientras se mandaba (si no, va en la próxima)
      await (_db.update(_db.localSets)
            ..where((x) => sameSet(x) & x.updatedAt.equals(set.updatedAt)))
          .write(const LocalSetsCompanion(synced: Value(true)));
    }
  }

  /// Notas del atleta: PUT idempotente (reenviarla la pisa, null la borra).
  Future<void> _pushNotes() async {
    final pending = await (_db.select(
      _db.localNotes,
    )..where((n) => n.synced.equals(false))).get();
    for (final n in pending) {
      final session =
          await (_db.select(_db.localSessions)..where(
                (x) =>
                    x.assignmentId.equals(n.assignmentId) &
                    x.dayId.equals(n.dayId),
              ))
              .getSingleOrNull();
      if (session?.remoteId == null) continue; // se crea en la próxima vuelta

      final logId = await _exerciseLogId(
        n.assignmentId,
        n.dayExerciseId,
        session!.remoteId!,
      );
      // Un rechazo de la API (4xx) no frena la cola: antes una nota con 409
      // cortaba la corrida y Finalizar entreno nunca llegaba al coach
      if (!await _putOrSkip(
        '/workout-sessions/exercise-logs/$logId/note',
        {'note': n.note},
      )) {
        continue;
      }
      // Solo marcar si no la editaron mientras se mandaba
      await (_db.update(_db.localNotes)..where(
            (x) =>
                x.assignmentId.equals(n.assignmentId) &
                x.dayExerciseId.equals(n.dayExerciseId) &
                x.updatedAt.equals(n.updatedAt),
          ))
          .write(const LocalNotesCompanion(synced: Value(true)));
    }
  }

  /// Cardio / Movilidad: Hecho (PUT idempotente).
  Future<void> _pushDone() async {
    final pending = await (_db.select(
      _db.localDone,
    )..where((d) => d.synced.equals(false))).get();
    for (final d in pending) {
      final session =
          await (_db.select(_db.localSessions)..where(
                (x) =>
                    x.assignmentId.equals(d.assignmentId) &
                    x.dayId.equals(d.dayId),
              ))
              .getSingleOrNull();
      if (session?.remoteId == null) continue; // se crea en la próxima vuelta

      final logId = await _exerciseLogId(
        d.assignmentId,
        d.dayExerciseId,
        session!.remoteId!,
      );
      if (!await _putOrSkip(
        '/workout-sessions/exercise-logs/$logId/done',
        {'done': d.done},
      )) {
        continue;
      }
      await (_db.update(_db.localDone)..where(
            (x) =>
                x.assignmentId.equals(d.assignmentId) &
                x.dayExerciseId.equals(d.dayExerciseId) &
                x.updatedAt.equals(d.updatedAt),
          ))
          .write(const LocalDoneCompanion(synced: Value(true)));
    }
  }

  /// PUT de una nota o un Hecho. false = la API lo rechazó (400/404/409/422):
  /// queda sin subir y se reintenta en la próxima corrida, pero sin cortar
  /// esta (las series y Finalizar siguen). Red caída o 401/5xx: se propaga y
  /// la corrida entera reintenta con backoff.
  Future<bool> _putOrSkip(String path, Map<String, dynamic> data) async {
    try {
      await _api.put<void>(path, data: data);
      return true;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 400 || code == 404 || code == 409 || code == 422) {
        debugPrint('SessionSync: rechazado ($code) $path ${e.response?.data}');
        _rejected = true;
        return false;
      }
      rethrow;
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
      // …y sus Hecho de cardio/movilidad (si no, la API ve el día vacío)
      final undone =
          await (_db.select(_db.localDone)..where(
                (x) =>
                    x.assignmentId.equals(s.assignmentId) &
                    x.dayId.equals(s.dayId) &
                    x.synced.equals(false),
              ))
              .get();
      if (undone.isNotEmpty) continue;

      try {
        await _api.put<Map<String, dynamic>>(
          '/workout-sessions/${s.remoteId}/complete',
        );
      } on DioException catch (e) {
        // 409 = el día no tiene nada registrado: se reabre en el teléfono en
        // vez de reintentar para siempre
        if (e.response?.statusCode != 409) rethrow;
        debugPrint(
          'SessionSync: Finalizar rechazado (409) ${e.response?.data}',
        );
        await (_db.update(_db.localSessions)..where(
              (x) =>
                  x.assignmentId.equals(s.assignmentId) &
                  x.dayId.equals(s.dayId),
            ))
            .write(const LocalSessionsCompanion(completedAt: Value(null)));
        continue;
      }
      await (_db.update(_db.localSessions)..where(
            (x) =>
                x.assignmentId.equals(s.assignmentId) & x.dayId.equals(s.dayId),
          ))
          .write(const LocalSessionsCompanion(completeSynced: Value(true)));
    }
  }

  /// Avanza el primer video pendiente (comprimir → subir → PATCH) guardando
  /// el progreso en la fila: si algo falla se retoma desde ese paso. Un video
  /// a la vez, PATCH incluido (ver CLAUDE.md). true = hubo trabajo de videos
  /// (puede quedar más para otra vuelta).
  Future<bool> _pushVideo() async {
    final pending =
        await (_db.select(_db.localVideos)
              ..where((v) => v.done.equals(false))
              ..orderBy([(v) => OrderingTerm.asc(v.createdAt)]))
            .get();
    for (final v in pending) {
      final setLogId = await _setLogIdOf(v);
      if (setLogId == null) continue; // la serie todavía no subió

      // createdAt cambia si lo reemplazaron: así no se pisa el video nuevo
      Expression<bool> same(LocalVideos x) =>
          x.assignmentId.equals(v.assignmentId) &
          x.dayExerciseId.equals(v.dayExerciseId) &
          x.setNumber.equals(v.setNumber) &
          x.createdAt.equals(v.createdAt);
      Future<int> save(LocalVideosCompanion c) =>
          (_db.update(_db.localVideos)..where(same)).write(c);
      Future<void> drop(String? file) async {
        await (_db.delete(_db.localVideos)..where(same)).go();
        await deleteVideoFile(file);
      }

      var path = v.filePath;
      var url = v.uploadedUrl;

      if (url == null && !v.compressed && path != null) {
        path = await _compress(path, v.trimStartMs, v.trimEndMs, save);
        if (path == null) return true; // lo reemplazaron mientras tanto
      }

      try {
        if (url == null) {
          if (path == null) {
            await drop(null);
            return true;
          }
          url = await _uploadToCloudinary(setLogId, path);
          await save(LocalVideosCompanion(uploadedUrl: Value(url)));
        }
        await _api.patch<void>(
          '/set-logs/$setLogId/video',
          data: {'videoUrl': url},
        );
      } on DioException catch (e) {
        final code = e.response?.statusCode;
        // El archivo o la serie no sirven más, o el coach dejó de pedir videos
        // (409 al firmar): se descarta en vez de reintentar para siempre
        if (code == 400 || code == 404 || code == 409 || code == 413) {
          debugPrint(
            'SessionSync: video descartado ($code) ${e.response?.data}',
          );
          await drop(path);
          return true;
        }
        rethrow;
      } on FileSystemException catch (e) {
        debugPrint('SessionSync: video descartado, falta el archivo ($e)');
        await drop(null);
        return true;
      }

      await save(
        const LocalVideosCompanion(done: Value(true), filePath: Value(null)),
      );
      await deleteVideoFile(path);
      return true;
    }
    return false;
  }

  /// Recorta (si eligió un tramo) y comprime a 720p para que suba rápido y
  /// ocupe poco en Cloudinary. Si no se puede comprimir se sube el original
  /// entero. null = la fila ya no es de este video.
  Future<String?> _compress(
    String path,
    int? trimStartMs,
    int? trimEndMs,
    Future<int> Function(LocalVideosCompanion) save,
  ) async {
    MediaInfo? out;
    try {
      ({int start, int duration})? trim;
      if (trimStartMs != null && trimEndMs != null) {
        final total = (await VideoCompress.getMediaInfo(path)).duration;
        final range = TrimRange(trimStartMs, trimEndMs);
        if (total != null && !range.isWhole(total.round())) {
          trim = compressTrimArgs(
            range,
            total.round(),
            android: Platform.isAndroid,
          );
        }
      }
      out = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.Res1280x720Quality,
        includeAudio: true,
        startTime: trim?.start,
        duration: trim?.duration,
      );
    } catch (e) {
      debugPrint('SessionSync: no se pudo comprimir ($e), va el original');
    }
    final compressed = out?.path;
    if (compressed == null) {
      await save(const LocalVideosCompanion(compressed: Value(true)));
      return path;
    }
    final kept = await keepVideo(compressed);
    // No VideoCompress.deleteAllCache(): en Android responde dos veces y rompe
    await deleteVideoFile(compressed);
    final updated = await save(
      LocalVideosCompanion(
        filePath: Value(kept),
        compressed: const Value(true),
      ),
    );
    if (updated == 0) {
      await deleteVideoFile(kept);
      return null;
    }
    await deleteVideoFile(path);
    return kept;
  }

  /// Id del set-log: el que se guardó al grabar o el que devolvió el upsert.
  /// Una serie subida antes de que existiera remoteId se vuelve a mandar
  /// (idempotente) para conseguirlo.
  Future<String?> _setLogIdOf(LocalVideo v) async {
    if (v.setLogId != null) return v.setLogId;
    Expression<bool> sameSet(LocalSets x) =>
        x.assignmentId.equals(v.assignmentId) &
        x.dayExerciseId.equals(v.dayExerciseId) &
        x.setNumber.equals(v.setNumber);
    final set = await (_db.select(
      _db.localSets,
    )..where(sameSet)).getSingleOrNull();
    if (set == null) return null;
    if (set.remoteId == null && set.synced) {
      await (_db.update(
        _db.localSets,
      )..where(sameSet)).write(const LocalSetsCompanion(synced: Value(false)));
      _again = true;
    }
    return set.remoteId;
  }

  /// Upload firmado: la API da la firma (el secret no está en la app).
  Future<String> _uploadToCloudinary(String setLogId, String path) async {
    final sig = (await _api.post<Map<String, dynamic>>(
      '/set-logs/$setLogId/video/signature',
    )).data!;
    final res = await _upload.post<Map<String, dynamic>>(
      sig['uploadUrl'] as String,
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(path),
        'api_key': sig['apiKey'],
        'timestamp': sig['timestamp'].toString(),
        'signature': sig['signature'],
        'public_id': sig['publicId'],
        'overwrite': 'true',
        'invalidate': 'true',
      }),
    );
    return res.data!['secure_url'] as String;
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
