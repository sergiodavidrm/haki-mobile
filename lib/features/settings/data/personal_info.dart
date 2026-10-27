import '../../../l10n/l10n.dart';

// Ajustes → Mis datos: lo que el atleta edita de su perfil (nombre, género,
// estatura, lesiones) y lo que solo ve (email, objetivo, que lo define el
// coach). Viene en `/auth/me` → `personal`; se guarda con
// PATCH auth/me/personal. El peso no va acá: se registra en Peso corporal.

/// Género como lo guarda la API (enum GenderType).
enum Gender {
  m('M'),
  f('F'),
  other('Other');

  const Gender(this.api);
  final String api;

  static Gender? parse(String? s) =>
      values.where((g) => g.api == s).firstOrNull;
}

/// Unidad en que el atleta ve su estatura (API: "CM" | "IN"). En la BD
/// siempre va en cm.
enum HeightUnit {
  cm('CM'),
  ftIn('IN');

  const HeightUnit(this.api);
  final String api;

  static HeightUnit? parse(String? s) =>
      values.where((u) => u.api == s).firstOrNull;
}

class PersonalInfoDto {
  const PersonalInfoDto({
    required this.email,
    this.gender,
    this.heightCm,
    this.heightUnit,
    this.injuries,
    this.primaryGoal,
  });

  final String email;
  final Gender? gender;
  final double? heightCm;
  final HeightUnit? heightUnit;
  final String? injuries;

  /// Clave del enum FitnessGoal de la API ("MuscleGain"…); solo lectura.
  final String? primaryGoal;

  factory PersonalInfoDto.fromJson(Map<String, dynamic> j) => PersonalInfoDto(
    email: j['email'] as String? ?? '',
    gender: Gender.parse(j['gender'] as String?),
    heightCm: (j['heightCm'] as num?)?.toDouble(),
    heightUnit: HeightUnit.parse(j['heightUnit'] as String?),
    injuries: j['injuriesText'] as String?,
    primaryGoal: j['primaryGoal'] as String?,
  );
}

/// 178 cm → 5 ft 10 in (redondeado a la pulgada).
({int feet, int inches}) cmToFeetInches(double cm) {
  final total = (cm / 2.54).round();
  return (feet: total ~/ 12, inches: total % 12);
}

/// 5 ft 10 in → 177.8 cm (un decimal, como lo guarda la API).
double feetInchesToCm(int feet, int inches) =>
    ((feet * 12 + inches) * 2.54 * 10).round() / 10;

/// Nombre del objetivo en el idioma activo (null = el coach no lo cargó).
String? goalLabel(String? key) => switch (key) {
  'FatLoss' => l10n.goalFatLoss,
  'MuscleGain' => l10n.goalMuscleGain,
  'Strength' => l10n.goalStrength,
  'Endurance' => l10n.goalEndurance,
  'Recomposition' => l10n.goalRecomposition,
  'GeneralHealth' => l10n.goalGeneralHealth,
  _ => null,
};
