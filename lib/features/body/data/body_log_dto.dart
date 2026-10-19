import '../../../core/units/weight_unit.dart';
import 'body_measures.dart';

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

  /// Clave de [bodyMeasures] → valor (cm, %, kg o nivel). Solo las que tienen dato.
  final Map<String, double> measures;

  factory BodyLogDto.fromJson(Map<String, dynamic> json) => BodyLogDto(
    date: DateTime.parse('${json['loggedDate']}T00:00:00Z'),
    weightKg: (json['weight'] as num?)?.toDouble(),
    weightUnit: WeightUnit.parse(json['weightUnit'] as String?),
    measures: {
      for (final m in bodyMeasures)
        if (json[m.key] != null) m.key: (json[m.key] as num).toDouble(),
    },
  );
}
