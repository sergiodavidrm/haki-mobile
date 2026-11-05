import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/program/data/assignment_dtos.dart';
import 'package:haki_mobile/features/program/data/prescription.dart';
import 'package:haki_mobile/features/session/data/session_plan.dart';

DayExerciseDto strength(String id, {String? group, String? groupKind}) => DayExerciseDto(
  id: id,
  exerciseName: id,
  supersetGroupId: group,
  groupKind: groupKind,
  targetSets: const [TargetSetDto(setNumber: 1, reps: 10), TargetSetDto(setNumber: 2, reps: 10)],
);

DayExerciseDto mobility(String id, {String? group, PrescriptionDto? rx}) => DayExerciseDto(
  id: id,
  exerciseName: id,
  supersetGroupId: group,
  groupKind: group == null ? null : 'combo',
  groupName: group == null ? null : 'Movilidad de cadera',
  groupNote: group == null ? null : 'Antes de la sentadilla',
  kind: ExerciseKinds.mobility,
  prescription: rx ?? const PrescriptionDto(sets: 2, amount: 10, unit: 'reps'),
);

DayExerciseDto cardio(String id) => DayExerciseDto(
  id: id,
  exerciseName: id,
  supersetGroupId: null,
  kind: ExerciseKinds.cardio,
  prescription: const PrescriptionDto(minutes: 30, intensity: 'inclinación 8%'),
);

void main() {
  test('cardio y movilidad no tienen series', () {
    expect(setCountOf(cardio('cami')), 0);
    expect(setCountOf(mobility('cat')), 0);
    expect(setCountOf(strength('sentadilla')), 2);
  });

  test('un combo agrupa sus ejercicios sin letra ni rondas', () {
    final groups = groupSupersets([
      mobility('cat', group: 'c1'),
      mobility('psoas', group: 'c1'),
      strength('sentadilla'),
      strength('remo', group: 's1', groupKind: 'superset'),
      strength('curl', group: 's1', groupKind: 'superset'),
      cardio('cami'),
    ]);
    expect(groups.map((g) => (g.letter, g.isCombo, g.exercises.length)), [
      (null, true, 2),
      (null, false, 1),
      ('A', false, 2),
      (null, false, 1),
    ]);
    expect(groups.first.comboName, 'Movilidad de cadera');
    expect(groups.first.comboNote, 'Antes de la sentadilla');
    expect(groups.first.badgeOf(groups.first.exercises.first), isNull);
  });

  test('un combo de un solo ejercicio sigue siendo combo', () {
    final groups = groupSupersets([mobility('cat', group: 'c1')]);
    expect(groups.single.isCombo, isTrue);
  });

  test('el orden de trabajo salta cardio y movilidad', () {
    final groups = groupSupersets([mobility('cat', group: 'c1'), strength('sentadilla'), cardio('cami')]);
    expect(workOrder(groups).map((r) => '${r.exercise.id}${r.setNumber}'), ['sentadilla1', 'sentadilla2']);
  });

  test('Hecho: el teléfono gana sobre la API', () {
    final api = DayExerciseDto(
      id: 'cat',
      exerciseName: 'cat',
      supersetGroupId: null,
      kind: ExerciseKinds.mobility,
      completedAt: DateTime(2026, 11, 3),
    );
    expect(doneFor(api, const {}), isTrue);
    expect(doneFor(api, const {'cat': false}), isFalse);
    expect(doneFor(cardio('cami'), const {'cami': true}), isTrue);
    expect(exerciseFinished(cardio('cami'), const {}, (_) => true), isFalse);
    expect(exerciseFinished(strength('s'), const {}, (_) => true), isTrue);
  });

  test('Finalizar necesita una serie o un Hecho', () {
    final day = [strength('s'), cardio('cami'), mobility('cat')];
    bool none(DayExerciseDto e, int n) => false;
    expect(hasAnyWork(day, const {}, none), isFalse);
    expect(hasAnyWork(day, const {'cami': false}, none), isFalse);
    expect(hasAnyWork(day, const {'cat': true}, none), isTrue);
    expect(hasAnyWork(day, const {}, (e, n) => e.id == 's' && n == 2), isTrue);
    expect(hasAnyWork(const [], const {}, none), isFalse);
  });

  test('formato de la prescripción', () {
    expect(formatPrescription(ExerciseKinds.cardio, const PrescriptionDto(minutes: 30, intensity: 'zona 2')), '30 min · zona 2');
    expect(formatPrescription(ExerciseKinds.cardio, const PrescriptionDto(minutes: 30, intensity: 'zona 2'), withIntensity: false), '30 min');
    expect(formatPrescription(ExerciseKinds.mobility, const PrescriptionDto(sets: 2, amount: 30, unit: 'seconds', perSide: true)), '2 × 30 s por lado');
    expect(formatPrescription(ExerciseKinds.mobility, const PrescriptionDto(sets: 2, amount: 10, unit: 'reps')), '2 × 10');
  });
}
