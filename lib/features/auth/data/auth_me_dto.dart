import '../../../core/units/weight_unit.dart';

// GET /auth/me → { exists, userId, role, preferredWeightUnit }. role viene del
// enum de Postgres ("CLIENT" | "COACH" | "ADMIN") o null: comparar sin
// distinguir mayúsculas. preferredWeightUnit ("KG" | "LB") solo para atletas.
class AuthMeDto {
  const AuthMeDto({
    required this.exists,
    required this.userId,
    this.role,
    this.preferredWeightUnit,
  });

  final bool exists;
  final String userId;
  final String? role;

  /// Unidad con la que arranca la Sesión (null = no es atleta o API vieja).
  final WeightUnit? preferredWeightUnit;

  bool get isAthlete => exists && role?.toLowerCase() == 'client';

  factory AuthMeDto.fromJson(Map<String, dynamic> json) => AuthMeDto(
    exists: json['exists'] as bool? ?? false,
    userId: json['userId'] as String,
    role: json['role'] as String?,
    preferredWeightUnit: json['preferredWeightUnit'] == null
        ? null
        : WeightUnit.parse(json['preferredWeightUnit'] as String),
  );
}
