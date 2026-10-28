import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/units/weight_unit.dart';
import '../../body/providers/body_providers.dart';
import '../../program/data/assignment_dtos.dart';
import '../../program/providers/program_providers.dart';
import '../data/session_plan.dart';
import '../data/session_store.dart';
import '../../../l10n/l10n.dart';

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
    throw StateError(l10n.sessionProgramNotCurrent);
  }
  for (final w in program.weeks) {
    for (final d in w.days) {
      if (d.id == dayId) return SessionDay(program: program, week: w, day: d);
    }
  }
  throw StateError(l10n.sessionDayGone);
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

/// Videos de la sesión en el teléfono: "dayExerciseId#setNumber" → true si
/// ya se subió, false si está en la cola.
@riverpod
Stream<Map<String, bool>> localVideos(
  Ref ref,
  String assignmentId,
  String dayId,
) => ref.watch(sessionStoreProvider).watchVideos(assignmentId, dayId);

/// Unidad del día (switch del header). Arranca en la preferida del atleta
/// (`GET /auth/me`, kg si no viene). keepAlive: se mantiene al salir y volver
/// a la sesión, y la usa el resumen de Entreno completado.
@Riverpod(keepAlive: true)
class DayWeightUnit extends _$DayWeightUnit {
  @override
  // bodyWeightUnit solo avisa si la unidad cambia: refrescar /auth/me
  // (pull-to-refresh del Perfil) no pisa el switch que el atleta tocó; un
  // cambio real de unidad (Ajustes) sí lo reinicia
  WeightUnit build(String dayId) => ref.watch(bodyWeightUnitProvider);

  void set(WeightUnit unit) => state = unit;
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
