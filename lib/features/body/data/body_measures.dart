import '../../../core/units/weight_unit.dart';
import 'body_log_dto.dart';
import '../../../l10n/l10n.dart';

// Medidas corporales + lógica pura de Peso y Medidas. Las que pide el coach
// llegan en /auth/me (estándar o creadas por él); [bodyMeasures] son las 16
// estándar (claves de la tabla body_measurements de haki-api). El nombre de
// las estándar sale de l10n por clave; las del coach traen el suyo.

enum MeasureGroup {
  torso,
  limbs,
  composition,
  other;

  /// `category` de la API (trunk | arms | legs | composition | other).
  static MeasureGroup parse(String? category) => switch (category) {
    'trunk' => torso,
    'arms' || 'legs' => limbs,
    'composition' => composition,
    _ => other,
  };

  String get label => switch (this) {
    torso => l10n.measureGroupTorso,
    limbs => l10n.measureGroupLimbs,
    composition => l10n.measureGroupComposition,
    other => l10n.measureGroupOther,
  };
}

enum MeasureKind {
  /// Circunferencia, siempre en cm.
  cm,
  percent,

  /// Masa muscular: kg en la API, se muestra en la unidad del atleta.
  mass,

  /// Grasa visceral (nivel de la balanza, sin unidad).
  level,

  /// Pliegues.
  mm;

  /// `unit` de la API (cm | kg | percent | mm | level).
  static MeasureKind parse(String? unit) => switch (unit) {
    'kg' => mass,
    'percent' => percent,
    'level' => level,
    'mm' => mm,
    _ => cm,
  };
}

class BodyMeasure {
  const BodyMeasure(
    this.key,
    this.name,
    this.group, [
    this.kind = MeasureKind.cm,
  ]);

  /// Elemento de `bodyMeasurements` de /auth/me: `{ key, name, unit,
  /// category }` (name solo en las del coach). Un String suelto es una clave
  /// estándar (caché de /auth/me de antes de las medidas personalizadas).
  /// null si no se reconoce.
  static BodyMeasure? fromJson(Object? json) {
    if (json is String) {
      return bodyMeasures.where((m) => m.key == json).firstOrNull;
    }
    if (json is! Map<String, dynamic>) return null;
    return BodyMeasure(
      json['key'] as String,
      json['name'] as String?,
      MeasureGroup.parse(json['category'] as String?),
      MeasureKind.parse(json['unit'] as String?),
    );
  }

  final String key;

  /// Nombre que le puso el coach; null en las estándar.
  final String? name;
  final MeasureGroup group;
  final MeasureKind kind;

  /// Nombre a mostrar: el del coach o el de la estándar en el idioma activo.
  String get label => name ?? _standardLabel(key) ?? key;

  String unitLabel(WeightUnit weightUnit) => switch (kind) {
    MeasureKind.cm => 'cm',
    MeasureKind.percent => '%',
    MeasureKind.mass => weightUnit.label,
    MeasureKind.level => l10n.measureUnitLevel,
    MeasureKind.mm => 'mm',
  };

  /// Valor de la API → como se muestra (solo la masa se convierte).
  double display(double apiValue, WeightUnit u) =>
      kind == MeasureKind.mass ? u.fromKg(apiValue) : apiValue;
}

String? _standardLabel(String key) => switch (key) {
  'neck' => l10n.measureNeck,
  'chest' => l10n.measureChest,
  'leftArm' => l10n.measureLeftArm,
  'rightArm' => l10n.measureRightArm,
  'leftForearm' => l10n.measureLeftForearm,
  'rightForearm' => l10n.measureRightForearm,
  'waist' => l10n.measureWaist,
  'abdomen' => l10n.measureAbdomen,
  'hips' => l10n.measureHips,
  'leftThigh' => l10n.measureLeftThigh,
  'rightThigh' => l10n.measureRightThigh,
  'leftCalf' => l10n.measureLeftCalf,
  'rightCalf' => l10n.measureRightCalf,
  'bodyFatPercentage' => l10n.measureBodyFat,
  'muscleMass' => l10n.measureMuscleMass,
  'visceralFat' => l10n.measureVisceralFat,
  _ => null,
};

const bodyMeasures = [
  BodyMeasure('neck', null, MeasureGroup.torso),
  BodyMeasure('chest', null, MeasureGroup.torso),
  BodyMeasure('leftArm', null, MeasureGroup.limbs),
  BodyMeasure('rightArm', null, MeasureGroup.limbs),
  BodyMeasure('leftForearm', null, MeasureGroup.limbs),
  BodyMeasure('rightForearm', null, MeasureGroup.limbs),
  BodyMeasure('waist', null, MeasureGroup.torso),
  BodyMeasure('abdomen', null, MeasureGroup.torso),
  BodyMeasure('hips', null, MeasureGroup.torso),
  BodyMeasure('leftThigh', null, MeasureGroup.limbs),
  BodyMeasure('rightThigh', null, MeasureGroup.limbs),
  BodyMeasure('leftCalf', null, MeasureGroup.limbs),
  BodyMeasure('rightCalf', null, MeasureGroup.limbs),
  BodyMeasure(
    'bodyFatPercentage',
    null,
    MeasureGroup.composition,
    MeasureKind.percent,
  ),
  BodyMeasure(
    'muscleMass',
    null,
    MeasureGroup.composition,
    MeasureKind.mass,
  ),
  BodyMeasure(
    'visceralFat',
    null,
    MeasureGroup.composition,
    MeasureKind.level,
  ),
];

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
  weeks4(28),
  months3(91),
  all(null);

  const WeightRange(this.days);
  final int? days;

  String get label => switch (this) {
    weeks4 => l10n.range4Weeks,
    months3 => l10n.range3Months,
    all => l10n.rangeAll,
  };
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
