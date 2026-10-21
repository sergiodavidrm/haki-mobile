import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

// BD local (SQLite) del entreno en curso. Es la fuente de verdad mientras se
// entrena: la UI escribe acá y SessionSync manda lo pendiente a la API.
// Las claves son naturales (assignment + día / ejercicio + serie), iguales a
// las de los upserts idempotentes de workout-sessions.

/// Sesión empezada en este teléfono.
class LocalSessions extends Table {
  TextColumn get assignmentId => text()();
  TextColumn get dayId => text()();

  /// Id de workout-sessions, cuando ya se creó en la API.
  TextColumn get remoteId => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get completeSynced =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {assignmentId, dayId};
}

/// Caché de ids de exercise-logs creados en la API (los crea el sync).
class LocalExerciseLogs extends Table {
  TextColumn get assignmentId => text()();
  TextColumn get dayExerciseId => text()();
  TextColumn get remoteId => text()();

  @override
  Set<Column> get primaryKey => {assignmentId, dayExerciseId};
}

/// Serie registrada. El peso queda como lo escribió el atleta (valor + unidad);
/// la API lo convierte a kg.
class LocalSets extends Table {
  TextColumn get assignmentId => text()();
  TextColumn get dayId => text()();
  TextColumn get dayExerciseId => text()();
  IntColumn get setNumber => integer()();
  RealColumn get weight => real().nullable()();

  /// "KG" | "LB"
  TextColumn get weightUnit => text()();
  IntColumn get reps => integer().nullable()();
  IntColumn get rir => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  /// Id del set-log en la API (lo devuelve el upsert; lo usan los videos).
  TextColumn get remoteId => text().nullable()();

  @override
  Set<Column> get primaryKey => {assignmentId, dayExerciseId, setNumber};
}

/// Cola de videos de series (ver CLAUDE.md § Subida de videos). Una fila por
/// serie: grabar de nuevo pisa la fila. Pasos: recortar y comprimir → subir a Cloudinary
/// (guarda [uploadedUrl]) → PATCH a la API (marca [done] y borra el archivo).
/// Las filas [done] quedan para que la Sesión muestre la cámara como enviada
/// sin recargar el programa.
class LocalVideos extends Table {
  TextColumn get assignmentId => text()();
  TextColumn get dayId => text()();
  TextColumn get dayExerciseId => text()();
  IntColumn get setNumber => integer()();

  /// Id del set-log, si ya se conocía al grabar (serie que vino de la API).
  TextColumn get setLogId => text().nullable()();

  /// Archivo en la carpeta de la app; null cuando ya se subió.
  TextColumn get filePath => text().nullable()();
  BoolColumn get compressed => boolean().withDefault(const Constant(false))();

  /// Tramo elegido en Recortar video (ms); null = el video entero.
  IntColumn get trimStartMs => integer().nullable()();
  IntColumn get trimEndMs => integer().nullable()();
  TextColumn get uploadedUrl => text().nullable()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {assignmentId, dayExerciseId, setNumber};
}

/// Última respuesta de la API para lo que tiene que verse sin señal
/// (`/auth/me`, programas, detalle). JSON tal cual vino (ApiCache).
class CachedResponses extends Table {
  TextColumn get key => text()();
  TextColumn get json => text()();
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    LocalSessions,
    LocalExerciseLogs,
    LocalSets,
    CachedResponses,
    LocalVideos,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'haki'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(cachedResponses);
      if (from < 3) {
        await m.addColumn(localSets, localSets.remoteId);
        await m.createTable(localVideos);
      }
      if (from == 3) {
        await m.addColumn(localVideos, localVideos.trimStartMs);
        await m.addColumn(localVideos, localVideos.trimEndMs);
      }
    },
  );

  /// Borra todo lo local (cerrar sesión / entra otro usuario).
  Future<void> wipe() => transaction(() async {
    await delete(localVideos).go();
    await delete(localSets).go();
    await delete(localExerciseLogs).go();
    await delete(localSessions).go();
    await delete(cachedResponses).go();
  });
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
