import '../../../core/units/weight_unit.dart';
import '../../body/data/body_measures.dart';

// GET /auth/me → { exists, userId, role, preferredWeightUnit, coachName,
// exerciseFeedbackEnabled, bodyMeasurements }. role viene del enum de Postgres ("CLIENT" | "COACH" |
// "ADMIN") o null: comparar sin distinguir mayúsculas. Los últimos tres solo
// para atletas.
class AuthMeDto {
  const AuthMeDto({
    required this.exists,
    required this.userId,
    this.role,
    this.preferredWeightUnit,
    this.coachName,
    this.exerciseFeedbackEnabled = false,
    this.bodyMeasurements = const [],
  });

  final bool exists;
  final String userId;
  final String? role;

  /// Unidad de la Sesión y del peso corporal (null = no es atleta o API vieja).
  final WeightUnit? preferredWeightUnit;
  final String? coachName;

  /// El coach da feedback por ejercicio en el hilo de cada tarjeta de videos
  /// (si no, responde en el chat general citándola).
  final bool exerciseFeedbackEnabled;

  /// Medidas que pidió el coach (estándar o creadas por él), en el orden del
  /// catálogo.
  final List<BodyMeasure> bodyMeasurements;

  bool get isAthlete => exists && role?.toLowerCase() == 'client';

  factory AuthMeDto.fromJson(Map<String, dynamic> json) => AuthMeDto(
    exists: json['exists'] as bool? ?? false,
    userId: json['userId'] as String,
    role: json['role'] as String?,
    preferredWeightUnit: json['preferredWeightUnit'] == null
        ? null
        : WeightUnit.parse(json['preferredWeightUnit'] as String),
    coachName: json['coachName'] as String?,
    exerciseFeedbackEnabled: json['exerciseFeedbackEnabled'] as bool? ?? false,
    bodyMeasurements: [
      for (final j in json['bodyMeasurements'] as List? ?? const [])
        ?BodyMeasure.fromJson(j),
    ],
  );
}
