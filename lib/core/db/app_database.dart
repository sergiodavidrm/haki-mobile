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

  @override
  Set<Column> get primaryKey => {assignmentId, dayExerciseId, setNumber};
}

@DriftDatabase(tables: [LocalSessions, LocalExerciseLogs, LocalSets])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'haki'));

  @override
  int get schemaVersion => 1;

  /// Borra todo lo local (cerrar sesión / entra otro usuario).
  Future<void> wipe() => transaction(() async {
    await delete(localSets).go();
    await delete(localExerciseLogs).go();
    await delete(localSessions).go();
  });
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
