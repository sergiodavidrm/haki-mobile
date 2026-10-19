import '../../../core/units/weight_unit.dart';

// GET /auth/me → { exists, userId, role, preferredWeightUnit, coachName,
// bodyMeasurements }. role viene del enum de Postgres ("CLIENT" | "COACH" |
// "ADMIN") o null: comparar sin distinguir mayúsculas. Los últimos tres solo
// para atletas.
class AuthMeDto {
  const AuthMeDto({
    required this.exists,
    required this.userId,
    this.role,
    this.preferredWeightUnit,
    this.coachName,
    this.bodyMeasurements = const [],
  });

  final bool exists;
  final String userId;
  final String? role;

  /// Unidad de la Sesión y del peso corporal (null = no es atleta o API vieja).
  final WeightUnit? preferredWeightUnit;
  final String? coachName;

  /// Claves de las medidas que pidió el coach (`BodyMeasurementKeys` de la API).
  final List<String> bodyMeasurements;

  bool get isAthlete => exists && role?.toLowerCase() == 'client';

  factory AuthMeDto.fromJson(Map<String, dynamic> json) => AuthMeDto(
    exists: json['exists'] as bool? ?? false,
    userId: json['userId'] as String,
    role: json['role'] as String?,
    preferredWeightUnit: json['preferredWeightUnit'] == null
        ? null
        : WeightUnit.parse(json['preferredWeightUnit'] as String),
    coachName: json['coachName'] as String?,
    bodyMeasurements: [
      for (final k in json['bodyMeasurements'] as List? ?? const [])
        k as String,
    ],
  );
}
