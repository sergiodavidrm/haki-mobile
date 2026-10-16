import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/units/weight_unit.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../../program/data/assignment_dtos.dart';
import '../../program/providers/program_providers.dart';
import '../data/session_plan.dart';
import '../data/session_store.dart';

part 'session_providers.g.dart';

/// Día de la sesión dentro del programa en curso.
class SessionDay {
  const SessionDay({
    required this.program,
    required this.week,
    required this.day,
  });

  final AssignmentDetailDto program;
  final WeekDto week;
  final DayDto day;
}

@riverpod
Future<SessionDay> sessionDay(
  Ref ref,
  String assignmentId,
  String dayId,
) async {
  final program = await ref.watch(currentProgramDetailProvider.future);
  if (program == null || program.assignmentId != assignmentId) {
    throw StateError('El programa ya no está en curso');
  }
  for (final w in program.weeks) {
    for (final d in w.days) {
      if (d.id == dayId) return SessionDay(program: program, week: w, day: d);
    }
  }
  throw StateError('El día ya no existe en el programa');
}

@riverpod
Stream<LocalSessionInfo?> localSession(
  Ref ref,
  String assignmentId,
  String dayId,
) => ref.watch(sessionStoreProvider).watchSession(assignmentId, dayId);

@riverpod
Stream<List<LocalSessionInfo>> localSessionsOf(Ref ref, String assignmentId) =>
    ref.watch(sessionStoreProvider).watchSessionsOf(assignmentId);

/// Series locales del día, indexadas por "dayExerciseId#setNumber".
@riverpod
Stream<Map<String, LocalSetEntry>> localSets(
  Ref ref,
  String assignmentId,
  String dayId,
) => ref
    .watch(sessionStoreProvider)
    .watchSets(assignmentId, dayId)
    .map(
      (rows) => {for (final r in rows) setKey(r.dayExerciseId, r.setNumber): r},
    );

/// Unidad del día (switch del header). Arranca en la preferida del atleta
/// (`GET /auth/me`, kg si no viene). keepAlive: se mantiene al salir y volver
/// a la sesión, y la usa el resumen de Entreno completado.
@Riverpod(keepAlive: true)
class DayWeightUnit extends _$DayWeightUnit {
  @override
  WeightUnit build(String dayId) =>
      ref.watch(authMeProvider).value?.preferredWeightUnit ?? WeightUnit.kg;

  void set(WeightUnit unit) => state = unit;
}

/// Override de unidad por ejercicio (tap en la unidad del ejercicio).
/// Sobrevive a cambios del switch del día.
@Riverpod(keepAlive: true)
class ExerciseUnitOverrides extends _$ExerciseUnitOverrides {
  @override
  Map<String, WeightUnit> build(String dayId) => const {};

  /// Si al invertir queda igual que la unidad del día, se borra el override
  /// (vuelve a seguir al switch del día).
  void toggle(String dayExerciseId, WeightUnit current, WeightUnit dayUnit) {
    final next = current.other;
    state = next == dayUnit
        ? ({...state}..remove(dayExerciseId))
        : {...state, dayExerciseId: next};
  }

  /// Al cambiar el switch del día, los overrides que quedaron iguales a la
  /// nueva unidad dejan de ser overrides.
  void dropMatching(WeightUnit dayUnit) =>
      state = {...state}..removeWhere((_, u) => u == dayUnit);
}

/// Resumen del entreno (Entreno completado), en la unidad del día.
@riverpod
Future<WorkoutSummary> workoutSummary(
  Ref ref,
  String assignmentId,
  String dayId,
) async {
  final s = await ref.watch(sessionDayProvider(assignmentId, dayId).future);
  final local = await ref.watch(localSetsProvider(assignmentId, dayId).future);
  final session = await ref.watch(
    localSessionProvider(assignmentId, dayId).future,
  );
  return summarize(
    s.day.exercises,
    local,
    unit: ref.watch(dayWeightUnitProvider(dayId)),
    startedAt: session?.startedAt,
    completedAt: session?.completedAt,
  );
}
