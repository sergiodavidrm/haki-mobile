import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/core/units/weight_unit.dart';
import 'package:haki_mobile/features/profile/data/records.dart';

PersonalRecordDto rec(
  String name,
  DateTime date, {
  String assignment = 'a1',
  double? previous,
  WeightUnit unit = WeightUnit.kg,
}) => PersonalRecordDto(
  exerciseId: name,
  exerciseName: name,
  assignmentId: assignment,
  date: date,
  e1RmKg: 74.3,
  weightKg: 54.88,
  unit: unit,
  reps: 12,
  rir: 1,
  previousE1RmKg: previous,
);

void main() {
  final today = DateTime(2026, 10, 21); // miércoles

  test('Esta semana = PRs desde el lunes; el resto filtrado por bloque', () {
    final all = [
      rec('jalon', DateTime(2026, 10, 20), previous: 72),
      rec('remo', DateTime(2026, 10, 19)), // primera vez: no es PR
      rec('press', DateTime(2026, 10, 10), previous: 60),
      rec('sentadilla', DateTime(2026, 9, 1), assignment: 'a0', previous: 90),
    ];
    final block = recordSections(
      all,
      today: today,
      currentAssignmentId: 'a1',
      blockOnly: true,
    );
    expect(block.thisWeek.map((r) => r.exerciseId), ['jalon']);
    expect(block.rest.map((r) => r.exerciseId), ['remo', 'press']);

    final hist = recordSections(
      all,
      today: today,
      currentAssignmentId: 'a1',
      blockOnly: false,
    );
    expect(hist.rest.map((r) => r.exerciseId), ['remo', 'press', 'sentadilla']);
  });

  test('etiquetas en la unidad de la serie', () {
    final r = rec('jalon', today, previous: 72.08, unit: WeightUnit.lb);
    expect(r.e1RmLabel, '163.8 lb');
    expect(r.setLabel, '121 lb × 12 · RIR 1');
    expect(r.improvementLabel, '+4.9');
    expect(rec('x', today).improvementLabel, isNull);
  });

  test('fecha: hoy, ayer o día y mes', () {
    expect(recordDateLabel(DateTime(2026, 10, 21), today), 'hoy');
    expect(recordDateLabel(DateTime(2026, 10, 20), today), 'ayer');
    expect(recordDateLabel(DateTime(2026, 9, 28), today), '28 sep');
  });
}
