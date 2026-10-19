import '../../../core/units/weight_unit.dart';
import 'body_log_dto.dart';

// Catálogo de medidas corporales (mismo orden y claves que
// haki-api Domain/BodyMeasurementKeys.cs) + lógica pura de Peso y Medidas.

enum MeasureGroup {
  torso('Tronco'),
  limbs('Brazos y piernas'),
  composition('Composición');

  const MeasureGroup(this.label);
  final String label;
}

enum MeasureKind {
  /// Circunferencia, siempre en cm.
  cm,
  percent,

  /// Masa muscular: kg en la API, se muestra en la unidad del atleta.
  mass,

  /// Grasa visceral (nivel de la balanza, sin unidad).
  level,
}

class BodyMeasure {
  const BodyMeasure(
    this.key,
    this.label,
    this.group, [
    this.kind = MeasureKind.cm,
  ]);

  final String key;
  final String label;
  final MeasureGroup group;
  final MeasureKind kind;

  String unitLabel(WeightUnit weightUnit) => switch (kind) {
    MeasureKind.cm => 'cm',
    MeasureKind.percent => '%',
    MeasureKind.mass => weightUnit.label,
    MeasureKind.level => 'nivel',
  };

  /// Valor de la API → como se muestra (solo la masa se convierte).
  double display(double apiValue, WeightUnit u) =>
      kind == MeasureKind.mass ? u.fromKg(apiValue) : apiValue;
}

const bodyMeasures = [
  BodyMeasure('neck', 'Cuello', MeasureGroup.torso),
  BodyMeasure('chest', 'Pecho', MeasureGroup.torso),
  BodyMeasure('leftArm', 'Brazo izquierdo', MeasureGroup.limbs),
  BodyMeasure('rightArm', 'Brazo derecho', MeasureGroup.limbs),
  BodyMeasure('leftForearm', 'Antebrazo izquierdo', MeasureGroup.limbs),
  BodyMeasure('rightForearm', 'Antebrazo derecho', MeasureGroup.limbs),
  BodyMeasure('waist', 'Cintura', MeasureGroup.torso),
  BodyMeasure('abdomen', 'Abdomen', MeasureGroup.torso),
  BodyMeasure('hips', 'Cadera', MeasureGroup.torso),
  BodyMeasure('leftThigh', 'Muslo izquierdo', MeasureGroup.limbs),
  BodyMeasure('rightThigh', 'Muslo derecho', MeasureGroup.limbs),
  BodyMeasure('leftCalf', 'Pantorrilla izquierda', MeasureGroup.limbs),
  BodyMeasure('rightCalf', 'Pantorrilla derecha', MeasureGroup.limbs),
  BodyMeasure(
    'bodyFatPercentage',
    'Grasa corporal',
    MeasureGroup.composition,
    MeasureKind.percent,
  ),
  BodyMeasure(
    'muscleMass',
    'Masa muscular',
    MeasureGroup.composition,
    MeasureKind.mass,
  ),
  BodyMeasure(
    'visceralFat',
    'Grasa visceral',
    MeasureGroup.composition,
    MeasureKind.level,
  ),
];

/// Las medidas que pidió el coach, en el orden del catálogo (claves
/// desconocidas se ignoran: la app puede ser más vieja que la API).
List<BodyMeasure> measuresFor(List<String> keys) {
  final set = keys.toSet();
  return bodyMeasures.where((m) => set.contains(m.key)).toList();
}

/// Valor de una medida en una fecha.
typedef DatedValue = ({DateTime date, double value});

/// Historial de una medida (o del peso con key null), del más viejo al más
/// nuevo, solo los días con dato. [logs] puede venir en cualquier orden.
List<DatedValue> seriesOf(List<BodyLogDto> logs, String? key) {
  final out = <DatedValue>[
    for (final l in logs)
      if ((key == null ? l.weightKg : l.measures[key]) case final v?)
        (date: l.date, value: v),
  ];
  out.sort((a, b) => a.date.compareTo(b.date));
  return out;
}

/// Último valor y el anterior (para la diferencia). null si no hay ninguno.
({DatedValue last, DatedValue? previous})? lastTwo(List<DatedValue> series) {
  if (series.isEmpty) return null;
  return (
    last: series.last,
    previous: series.length > 1 ? series[series.length - 2] : null,
  );
}

enum WeightRange {
  weeks4('4 sem', 28),
  months3('3 meses', 91),
  all('Todo', null);

  const WeightRange(this.label, this.days);
  final String label;
  final int? days;
}

/// Puntos dentro del rango (hasta hoy inclusive).
List<DatedValue> inRange(List<DatedValue> s, WeightRange r, DateTime today) {
  if (r.days == null) return s;
  final from = today.subtract(Duration(days: r.days!));
  return s.where((p) => !p.date.isBefore(from)).toList();
}

/// Cambio entre el primer y el último punto. null con menos de dos.
double? changeOf(List<DatedValue> s) =>
    s.length < 2 ? null : s.last.value - s.first.value;

/// Registros con alguna de las [measures] (los de solo peso no cuentan), del
/// más nuevo al más viejo.
List<BodyLogDto> measureLogsOf(
  List<BodyLogDto> logs,
  List<BodyMeasure> measures,
) =>
    logs
        .where((l) => measures.any((m) => l.measures.containsKey(m.key)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

/// Último valor de cada medida pedida antes de [date] (para "Anterior" al
/// registrar) — los registros de ese mismo día no cuentan.
Map<String, double> previousBefore(
  List<BodyLogDto> logs,
  List<BodyMeasure> measures,
  DateTime date,
) {
  final before = logs.where((l) => l.date.isBefore(date)).toList();
  return {
    for (final m in measures)
      if (seriesOf(before, m.key).lastOrNull case final p?) m.key: p.value,
  };
}

/// "84" / "84.5" para medidas (mismo redondeo que el peso).
String formatMeasure(double v) => formatWeight(v);

/// "+0.5" / "−1.0" / "0.0" (con signo menos tipográfico, como el mockup).
String formatDelta(double d) {
  final r = (d * 10).round() / 10;
  if (r == 0) return '0.0';
  return '${r > 0 ? '+' : '−'}${r.abs().toStringAsFixed(1)}';
}

/// Texto que el atleta escribe → número (acepta coma decimal). null si vacío
/// o inválido; los ≤ 0 tampoco valen.
double? parseMeasure(String s) {
  final v = double.tryParse(s.trim().replaceAll(',', '.'));
  return v == null || v <= 0 ? null : v;
}
