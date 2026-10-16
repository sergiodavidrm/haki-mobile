// La API habla siempre en kg; la app muestra en la unidad que elige el atleta.
// Mismo factor que haki-api Domain/WeightConversion.cs.

const _kgPerLb = 0.45359237;

enum WeightUnit {
  kg('KG', 'kg'),
  lb('LB', 'lb');

  const WeightUnit(this.api, this.label);

  /// Como lo serializa la API ("KG" / "LB").
  final String api;
  final String label;

  WeightUnit get other => this == kg ? lb : kg;

  static WeightUnit parse(String? s) => s?.toUpperCase() == 'LB' ? lb : kg;

  double fromKg(double kg) => this == lb ? kg / _kgPerLb : kg;

  double toKg(double value) => this == lb ? value * _kgPerLb : value;
}

/// 60 → "60", 61.25 → "61.3", 132.276 → "132.3"
String formatWeight(double v) {
  final r = (v * 10).round() / 10;
  return r == r.roundToDouble() ? r.toStringAsFixed(0) : r.toStringAsFixed(1);
}
