import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/core/units/weight_unit.dart';
import 'package:haki_mobile/features/body/data/body_log_dto.dart';
import 'package:haki_mobile/features/body/data/body_measures.dart';

BodyLogDto log(
  int month,
  int dayOfMonth, {
  double? kg,
  Map<String, double> m = const {},
}) => BodyLogDto(
  date: DateTime.utc(2026, month, dayOfMonth),
  weightKg: kg,
  measures: m,
);

/// Medidas estándar por clave (lo que antes armaba measuresFor).
List<BodyMeasure> std(List<String> keys) => [
  for (final k in keys) BodyMeasure.fromJson(k)!,
];

void main() {
  test('fromJson: fecha, peso y solo las medidas con valor', () {
    final l = BodyLogDto.fromJson({
      'loggedDate': '2026-09-28',
      'weight': 85.0,
      'weightUnit': 'LB',
      'values': {'waist': 84, 'muscleMass': 40.5},
    });
    expect(l.date, DateTime.utc(2026, 9, 28));
    expect(l.weightKg, 85.0);
    expect(l.weightUnit, WeightUnit.lb);
    expect(l.measures, {'waist': 84.0, 'muscleMass': 40.5});
  });

  test('BodyMeasure.fromJson: estándar, del coach y caché vieja', () {
    final std = BodyMeasure.fromJson({
      'key': 'waist',
      'name': null,
      'unit': 'cm',
      'category': 'trunk',
    })!;
    expect(std.label, 'Cintura');
    expect(std.group, MeasureGroup.torso);

    final custom = BodyMeasure.fromJson({
      'key': '5f0c…',
      'name': 'Pliegue tricipital',
      'unit': 'mm',
      'category': 'other',
    })!;
    expect(custom.label, 'Pliegue tricipital');
    expect(custom.group, MeasureGroup.other);
    expect(custom.unitLabel(WeightUnit.kg), 'mm');

    final mass = BodyMeasure.fromJson({
      'key': 'x',
      'name': 'Masa magra',
      'unit': 'kg',
      'category': 'composition',
    })!;
    expect(mass.unitLabel(WeightUnit.lb), 'lb');

    // /auth/me cacheado antes del cambio: lista de claves
    expect(BodyMeasure.fromJson('chest')!.label, 'Pecho');
    expect(BodyMeasure.fromJson('nueva'), isNull);
  });

  test('seriesOf ordena y salta días sin dato', () {
    final logs = [
      log(9, 24, kg: 85.2),
      log(9, 17, kg: 85.4, m: {'waist': 85}),
      log(9, 21, m: {'waist': 84}), // solo medidas
    ];
    expect(seriesOf(logs, null).map((p) => p.value), [85.4, 85.2]);
    expect(seriesOf(logs, 'waist').map((p) => p.value), [85, 84]);
    final two = lastTwo(seriesOf(logs, 'waist'))!;
    expect(two.last.value, 84);
    expect(two.previous!.value, 85);
    expect(lastTwo(seriesOf(logs, 'hips')), isNull);
  });

  test('inRange + changeOf', () {
    final s = seriesOf([
      log(8, 1, kg: 90),
      log(9, 10, kg: 86),
      log(10, 1, kg: 85.4),
    ], null);
    final today = DateTime.utc(2026, 10, 2);
    expect(inRange(s, WeightRange.weeks4, today).length, 2);
    expect(
      changeOf(inRange(s, WeightRange.weeks4, today)),
      closeTo(-0.6, 1e-9),
    );
    expect(changeOf(inRange(s, WeightRange.all, today)), closeTo(-4.6, 1e-9));
    expect(changeOf(s.take(1).toList()), isNull);
  });

  test('previousBefore no cuenta el mismo día', () {
    final logs = [
      log(9, 1, m: {'waist': 86}),
      log(9, 20, m: {'waist': 85, 'hips': 99}),
    ];
    final ms = std(['waist', 'hips']);
    expect(previousBefore(logs, ms, DateTime.utc(2026, 9, 20)), {'waist': 86});
    expect(previousBefore(logs, ms, DateTime.utc(2026, 9, 21)), {
      'waist': 85,
      'hips': 99,
    });
  });

  test('formatDelta y parseMeasure', () {
    expect(formatDelta(-0.6), '−0.6');
    expect(formatDelta(0.5), '+0.5');
    expect(formatDelta(0.04), '0.0');
    expect(parseMeasure('84,5'), 84.5);
    expect(parseMeasure(' '), isNull);
    expect(parseMeasure('0'), isNull);
  });

  test('masa muscular se muestra en la unidad del atleta', () {
    final mass = bodyMeasures.firstWhere((m) => m.key == 'muscleMass');
    expect(mass.unitLabel(WeightUnit.lb), 'lb');
    expect(mass.display(45.359237, WeightUnit.lb), closeTo(100, 1e-9));
    final waist = bodyMeasures.firstWhere((m) => m.key == 'waist');
    expect(waist.display(84, WeightUnit.lb), 84);
  });

  test('measureLogsOf: solo días con medidas pedidas, más nuevo primero', () {
    final logs = [
      log(9, 1, m: {'waist': 86}),
      log(9, 10, kg: 85), // solo peso
      log(9, 20, m: {'neck': 40}), // medida que el coach no pidió
      log(9, 25, m: {'hips': 99}),
    ];
    final r = measureLogsOf(logs, std(['waist', 'hips']));
    expect(r.map((l) => l.date.day), [25, 1]);
  });
}
