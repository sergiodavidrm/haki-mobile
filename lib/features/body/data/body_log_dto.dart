import '../../../core/units/weight_unit.dart';

// Un registro de GET body-logs/{clientId} (uno por día). Peso y masa muscular
// vienen en kg; weightUnit = unidad en que se ingresó el peso.
class BodyLogDto {
  const BodyLogDto({
    required this.date,
    this.weightKg,
    this.weightUnit = WeightUnit.kg,
    this.measures = const {},
  });

  /// UTC a medianoche, como las fechas de los programas.
  final DateTime date;
  final double? weightKg;
  final WeightUnit weightUnit;

  /// Clave de medida → valor (cm, mm, %, kg o nivel). Solo las que tienen dato.
  final Map<String, double> measures;

  factory BodyLogDto.fromJson(Map<String, dynamic> json) => BodyLogDto(
    date: DateTime.parse('${json['loggedDate']}T00:00:00Z'),
    weightKg: (json['weight'] as num?)?.toDouble(),
    weightUnit: WeightUnit.parse(json['weightUnit'] as String?),
    measures: {
      for (final e in (json['values'] as Map? ?? const {}).entries)
        e.key as String: (e.value as num).toDouble(),
    },
  );
}
