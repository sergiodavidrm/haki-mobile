import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/core/units/weight_unit.dart';
import 'package:haki_mobile/features/profile/data/records.dart';
import 'package:haki_mobile/features/program/data/assignment_dtos.dart';
import 'package:haki_mobile/features/session/data/session_plan.dart';
import 'package:haki_mobile/features/session/data/workout_prs.dart';
import 'package:haki_mobile/features/session/data/session_store.dart';

DayExerciseDto ex(String id) => DayExerciseDto(
  id: 'de-$id',
  exerciseId: id,
  exerciseName: id,
  supersetGroupId: null,
  targetSets: [
    for (var n = 1; n <= 3; n++) TargetSetDto(setNumber: n, reps: 10),
  ],
);

LocalSetEntry set(String id, int n, double kg, int reps) => LocalSetEntry(
  dayExerciseId: 'de-$id',
  setNumber: n,
  weight: kg,
  unit: WeightUnit.kg,
  reps: reps,
  synced: false,
);

PersonalRecordDto record(
  String id,
  double e1rm,
  DateTime date, {
  double? prev,
}) => PersonalRecordDto(
  exerciseId: id,
  exerciseName: id,
  assignmentId: 'a',
  date: date,
  e1RmKg: e1rm,
  weightKg: 60,
  unit: WeightUnit.kg,
  reps: 10,
  previousE1RmKg: prev,
);

void main() {
  final today = DateTime(2026, 11, 5);
  final lastWeek = DateTime(2026, 10, 29);
  final day = [ex('remo'), ex('banca'), ex('curl')];
  final local = {
    setKey('de-remo', 1): set('remo', 1, 72, 10), // 96 > 93,3
    setKey('de-banca', 1): set('banca', 1, 80, 8), // 101,3 < 104
    setKey('de-curl', 1): set('curl', 1, 15, 12), // sin récord previo
  };

  test('PR contra el récord vigente; sin marca anterior no hay PR', () {
    final prs = workoutPrs(day, local, [
      record('remo', 93.33, lastWeek, prev: 90),
      record('banca', 104, lastWeek),
    ], trainedOn: today);
    expect(prs.map((p) => p.exerciseName), ['remo']);
    expect(prs.single.e1RmKg, closeTo(96, 0.01));
    expect(prs.single.previousE1RmKg, 93.33);
  });

  test('si el récord ya es de hoy (subió), compara con el anterior', () {
    final prs = workoutPrs(day, local, [
      record('remo', 96, today, prev: 93.33),
    ], trainedOn: today);
    expect(prs.single.previousE1RmKg, 93.33);
  });

  test('primera vez (récord de hoy sin anterior): no es PR', () {
    expect(
      workoutPrs(day, local, [record('curl', 21, today)], trainedOn: today),
      isEmpty,
    );
  });
}
