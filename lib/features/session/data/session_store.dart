import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/app_database.dart';
import '../../../core/units/weight_unit.dart';
import 'session_sync.dart';
import 'video_files.dart';

part 'session_store.g.dart';

// Tipos propios para la UI/providers: riverpod_generator no ve las clases
// que genera drift (LocalSession/LocalSet), así que no salen del store.

class LocalSessionInfo {
  const LocalSessionInfo({
    required this.dayId,
    required this.startedAt,
    this.completedAt,
    this.skippedAt,
    this.skipNote,
    this.skipSynced = true,
  });

  final String dayId;
  final DateTime startedAt;
  final DateTime? completedAt;

  /// "No voy a hacer este día": null = no está marcado.
  final DateTime? skippedAt;
  final String? skipNote;

  /// false = marcar o deshacer todavía no llegó a la API (lo local manda).
  final bool skipSynced;
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
    this.savedAt,
  });

  final String dayExerciseId;
  final int setNumber;
  final double? weight;
  final WeightUnit unit;
  final int? reps;
  final int? rir;

  /// false = todavía no llegó a la API.
  final bool synced;

  /// Última vez que se guardó en el teléfono (para la duración del entreno).
  final DateTime? savedAt;
}

LocalSessionInfo _session(LocalSession s) => LocalSessionInfo(
  dayId: s.dayId,
  startedAt: s.startedAt,
  completedAt: s.completedAt,
  skippedAt: s.skippedAt,
  skipNote: s.skipNote,
  skipSynced: s.skipSynced,
);

LocalSetEntry _set(LocalSet s) => LocalSetEntry(
  dayExerciseId: s.dayExerciseId,
  setNumber: s.setNumber,
  weight: s.weight,
  unit: WeightUnit.parse(s.weightUnit),
  reps: s.reps,
  rir: s.rir,
  synced: s.synced,
  savedAt: s.updatedAt,
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

  /// Todas las series de un programa (para el día parcial en Hoy y Programa).
  Stream<List<LocalSetEntry>> watchSetsOf(String assignmentId) =>
      (_db.select(_db.localSets)
            ..where((s) => s.assignmentId.equals(assignmentId)))
          .watch()
          .map((rows) => rows.map(_set).toList());

  Stream<List<LocalSetEntry>> watchSets(String assignmentId, String dayId) =>
      (_db.select(_db.localSets)..where(
            (s) => s.assignmentId.equals(assignmentId) & s.dayId.equals(dayId),
          ))
          .watch()
          .map((rows) => rows.map(_set).toList());

  /// Notas del día guardadas en el teléfono: dayExerciseId → nota (null = la
  /// borró). Ganan sobre la que vino de la API.
  Stream<Map<String, String?>> watchNotes(String assignmentId, String dayId) =>
      (_db.select(_db.localNotes)..where(
            (n) => n.assignmentId.equals(assignmentId) & n.dayId.equals(dayId),
          ))
          .watch()
          .map((rows) => {for (final n in rows) n.dayExerciseId: n.note});

  /// Cardio / Movilidad marcados en el teléfono: dayExerciseId → hecho. Ganan
  /// sobre `completedAt` de la API.
  Stream<Map<String, bool>> watchDone(String assignmentId, String dayId) =>
      (_db.select(_db.localDone)..where(
            (d) => d.assignmentId.equals(assignmentId) & d.dayId.equals(dayId),
          ))
          .watch()
          .map((rows) => {for (final d in rows) d.dayExerciseId: d.done});

  /// Videos de la sesión: setKey → true si ya se subió, false si está en la
  /// cola.
  Stream<Map<String, bool>> watchVideos(String assignmentId, String dayId) =>
      (_db.select(_db.localVideos)..where(
            (v) => v.assignmentId.equals(assignmentId) & v.dayId.equals(dayId),
          ))
          .watch()
          .map(
            (rows) => {
              for (final v in rows) '${v.dayExerciseId}#${v.setNumber}': v.done,
            },
          );

  /// Encola el video de una serie. Si la serie ya tenía uno pendiente, el
  /// nuevo lo reemplaza (el archivo viejo se borra). [setLogId] cuando la
  /// serie vino de la API.
  Future<void> addVideo({
    required String assignmentId,
    required String dayId,
    required String dayExerciseId,
    required int setNumber,
    required String sourcePath,
    String? setLogId,
    int? trimStartMs,
    int? trimEndMs,
  }) async {
    final path = await keepVideo(sourcePath);
    final previous =
        await (_db.select(_db.localVideos)..where(
              (v) =>
                  v.assignmentId.equals(assignmentId) &
                  v.dayExerciseId.equals(dayExerciseId) &
                  v.setNumber.equals(setNumber),
            ))
            .getSingleOrNull();
    await _db
        .into(_db.localVideos)
        .insertOnConflictUpdate(
          LocalVideosCompanion.insert(
            assignmentId: assignmentId,
            dayId: dayId,
            dayExerciseId: dayExerciseId,
            setNumber: setNumber,
            setLogId: Value(setLogId ?? previous?.setLogId),
            filePath: Value(path),
            compressed: const Value(false),
            trimStartMs: Value(trimStartMs),
            trimEndMs: Value(trimEndMs),
            uploadedUrl: const Value(null),
            done: const Value(false),
            createdAt: DateTime.now(),
          ),
        );
    await deleteVideoFile(previous?.filePath);
    _sync.kick();
  }

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

  /// "No voy a hacer este día" (offline, como las series). Solo si el día no
  /// tiene nada registrado (la UI lo ofrece así; la API responde 409 si no).
  Future<bool> skip(String assignmentId, String dayId, {String? note}) async {
    final value = note?.trim();
    bool ofDay(String a, String d) => a == assignmentId && d == dayId;
    final sets = await (_db.select(
      _db.localSets,
    )..where((s) => s.assignmentId.equals(assignmentId))).get();
    final done = await (_db.select(_db.localDone)..where(
          (x) => x.assignmentId.equals(assignmentId) & x.done.equals(true),
        ))
        .get();
    if (sets.any((s) => ofDay(s.assignmentId, s.dayId)) ||
        done.any((x) => ofDay(x.assignmentId, x.dayId))) {
      return false;
    }
    await start(assignmentId, dayId);
    await (_db.update(_db.localSessions)..where(
          (s) => s.assignmentId.equals(assignmentId) & s.dayId.equals(dayId),
        ))
        .write(
          LocalSessionsCompanion(
            skippedAt: Value(DateTime.now()),
            skipNote: Value(value == null || value.isEmpty ? null : value),
            skipSynced: const Value(false),
          ),
        );
    _sync.kick();
    return true;
  }

  /// Deshacer "No voy a hacer este día" (también al registrar algo ese día).
  /// [force] = aunque en el teléfono no figure marcado (vino marcado de la
  /// API).
  Future<void> unskip(
    String assignmentId,
    String dayId, {
    bool force = false,
  }) async {
    final row =
        await (_db.select(_db.localSessions)..where(
              (s) =>
                  s.assignmentId.equals(assignmentId) & s.dayId.equals(dayId),
            ))
            .getSingleOrNull();
    if (row == null || (row.skippedAt == null && !force)) {
      if (!force) return;
      await start(assignmentId, dayId);
    }
    await (_db.update(_db.localSessions)..where(
          (s) => s.assignmentId.equals(assignmentId) & s.dayId.equals(dayId),
        ))
        .write(
          const LocalSessionsCompanion(
            skippedAt: Value(null),
            skipNote: Value(null),
            skipSynced: Value(false),
          ),
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
    // Registrar algo deshace "no lo hago" (después de la serie: así la serie
    // sube primero y la API ya lo reabre sola)
    await unskip(assignmentId, dayId);
    _sync.kick();
  }

  /// Nota para el coach sobre un ejercicio. Vacía = la borra. Crea la sesión si
  /// no existía (se puede escribir antes de cargar series).
  Future<void> saveNote({
    required String assignmentId,
    required String dayId,
    required String dayExerciseId,
    required String? note,
  }) async {
    final value = note?.trim();
    await start(assignmentId, dayId);
    await _db
        .into(_db.localNotes)
        .insertOnConflictUpdate(
          LocalNotesCompanion.insert(
            assignmentId: assignmentId,
            dayId: dayId,
            dayExerciseId: dayExerciseId,
            note: Value(value == null || value.isEmpty ? null : value),
            updatedAt: DateTime.now(),
            synced: const Value(false),
          ),
        );
    _sync.kick();
  }

  /// Cardio / Movilidad: marcar (o desmarcar) Hecho. Crea la sesión si no
  /// existía.
  Future<void> saveDone({
    required String assignmentId,
    required String dayId,
    required String dayExerciseId,
    required bool done,
  }) async {
    await start(assignmentId, dayId);
    await _db
        .into(_db.localDone)
        .insertOnConflictUpdate(
          LocalDoneCompanion.insert(
            assignmentId: assignmentId,
            dayId: dayId,
            dayExerciseId: dayExerciseId,
            done: done,
            updatedAt: DateTime.now(),
            synced: const Value(false),
          ),
        );
    if (done) await unskip(assignmentId, dayId);
    _sync.kick();
  }

  /// Cosas guardadas en el teléfono que todavía no llegaron a la API
  /// (series + notas + sesiones sin crear o sin completar + videos).
  Future<int> pendingCount() async {
    final sets = await (_db.select(
      _db.localSets,
    )..where((s) => s.synced.equals(false))).get();
    final notes = await (_db.select(
      _db.localNotes,
    )..where((n) => n.synced.equals(false))).get();
    final done = await (_db.select(
      _db.localDone,
    )..where((d) => d.synced.equals(false))).get();
    bool sameDay(String a, String d, LocalSession s) =>
        a == s.assignmentId && d == s.dayId;
    // Una sesión sin crear en la API cuenta solo si tiene algo para subir
    // (abrir un día para mirarlo no crea nada, ver SessionSync._startSessions)
    final sessions =
        (await (_db.select(_db.localSessions)..where(
                  (s) =>
                      s.remoteId.isNull() |
                      (s.completedAt.isNotNull() &
                          s.completeSynced.equals(false)) |
                      s.skipSynced.equals(false),
                ))
                .get())
            .where(
              (s) =>
                  s.remoteId != null ||
                  s.completedAt != null ||
                  !s.skipSynced ||
                  sets.any((x) => sameDay(x.assignmentId, x.dayId, s)) ||
                  notes.any((n) => sameDay(n.assignmentId, n.dayId, s)) ||
                  done.any((d) => sameDay(d.assignmentId, d.dayId, s)),
            )
            .toList();
    final videos = await (_db.select(
      _db.localVideos,
    )..where((v) => v.done.equals(false))).get();
    return sets.length +
        notes.length +
        done.length +
        sessions.length +
        videos.length;
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
