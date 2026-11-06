import '../../../core/units/weight_unit.dart';
import '../../profile/data/records.dart';
import '../../program/data/assignment_dtos.dart';
import '../../program/data/program_schedule.dart' show dateOnly;
import 'session_plan.dart';
import 'session_store.dart';

// Nuevos PR de un entreno (Entreno completado). Se calculan en el teléfono
// con las series del día y el récord vigente de cada ejercicio
// (GET progress/{id}/records), así anda aunque las series no hayan subido.
// e1RM = peso × (1 + reps/30), igual que la API (Domain/PersonalRecords.cs).

class WorkoutPr {
  const WorkoutPr({
    required this.dayExerciseId,
    required this.exerciseName,
    required this.e1RmKg,
    required this.previousE1RmKg,
    required this.weight,
    required this.unit,
    required this.reps,
  });

  final String dayExerciseId;
  final String exerciseName;
  final double e1RmKg;
  final double previousE1RmKg;

  /// La serie que lo logró, tal cual se cargó
  final double weight;
  final WeightUnit unit;
  final int reps;
}

double e1RmKgOf(double weightKg, int reps) => weightKg * (1 + reps / 30);

/// PRs del entreno: el mejor e1RM del día de cada ejercicio de fuerza contra
/// su marca anterior. Si el récord vigente ya es de este día (las series ya
/// subieron), la marca anterior es su `previousE1RmKg`. Sin marca anterior
/// (primera vez) no hay PR.
List<WorkoutPr> workoutPrs(
  List<DayExerciseDto> exercises,
  Map<String, LocalSetEntry> local,
  List<PersonalRecordDto> records, {
  required DateTime trainedOn,
}) {
  final byExercise = {for (final r in records) r.exerciseId: r};
  final day = dateOnly(trainedOn);
  final prs = <WorkoutPr>[];
  for (final e in exercises) {
    WorkoutPr? best;
    final record = byExercise[e.exerciseId];
    if (record == null) continue;
    final previous = dateOnly(record.date) == day
        ? record.previousE1RmKg
        : record.e1RmKg;
    if (previous == null) continue;
    for (var n = 1; n <= setCountOf(e); n++) {
      final s = savedSetFor(e, n, local);
      final w = s?.weight, reps = s?.reps;
      if (s == null || w == null || w <= 0 || reps == null || reps <= 0) {
        continue;
      }
      final value = e1RmKgOf(s.unit.toKg(w), reps);
      if (best == null || value > best.e1RmKg) {
        best = WorkoutPr(
          dayExerciseId: e.id,
          exerciseName: e.exerciseName,
          e1RmKg: value,
          previousE1RmKg: previous,
          weight: w,
          unit: s.unit,
          reps: reps,
        );
      }
    }
    // Redondeo: 0,05 kg para no marcar PR por decimales de la conversión
    if (best != null && best.e1RmKg > previous + 0.05) prs.add(best);
  }
  prs.sort(
    (a, b) =>
        (b.e1RmKg / b.previousE1RmKg).compareTo(a.e1RmKg / a.previousE1RmKg),
  );
  return prs;
}

/// Día en que entrenó: la primera serie guardada en el teléfono, si no el
/// arranque de la sesión, si no hoy.
DateTime trainedOnOf(Map<String, LocalSetEntry> local, DateTime? startedAt) {
  final times = [
    for (final s in local.values)
      if (s.savedAt != null) s.savedAt!,
  ]..sort();
  return times.firstOrNull ?? startedAt ?? DateTime.now();
}
