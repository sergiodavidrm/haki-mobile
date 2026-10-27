import '../../../core/units/weight_unit.dart';
import '../../body/data/body_measures.dart';
import '../../profile/data/coach_profile_dto.dart';
import '../../settings/data/personal_info.dart';

// GET /auth/me → { exists, userId, role, fullName, preferredWeightUnit, coachName,
// exerciseFeedbackEnabled, bodyMeasurements, accessEndsAt, coach, personal }. role viene del enum de Postgres ("CLIENT" | "COACH" |
// "ADMIN") o null: comparar sin distinguir mayúsculas. Los últimos tres solo
// para atletas.
class AuthMeDto {
  const AuthMeDto({
    required this.exists,
    required this.userId,
    this.role,
    this.fullName,
    this.preferredWeightUnit,
    this.coachName,
    this.exerciseFeedbackEnabled = false,
    this.bodyMeasurements = const [],
    this.accessEndsAt,
    this.coach,
    this.personal,
  });

  final bool exists;
  final String userId;
  final String? role;

  /// Nombre completo del atleta (el que cargó el coach al invitarlo).
  final String? fullName;

  /// Unidad de la Sesión y del peso corporal (null = no es atleta o API vieja).
  final WeightUnit? preferredWeightUnit;
  final String? coachName;

  /// El coach da feedback por ejercicio en el hilo de cada tarjeta de videos
  /// (si no, responde en el chat general citándola).
  final bool exerciseFeedbackEnabled;

  /// Medidas que pidió el coach (estándar o creadas por él), en el orden del
  /// catálogo.
  final List<BodyMeasure> bodyMeasurements;

  /// El coach lo archivó o eliminó: puede usar la app hasta esta fecha
  /// (7 días después). null = sin límite.
  final DateTime? accessEndsAt;

  /// Pantalla "Tu coach": experiencia, bio y certificaciones (null = API vieja
  /// o no es atleta).
  final CoachProfileDto? coach;

  /// Pantalla "Mis datos" (null = API vieja o no es atleta).
  final PersonalInfoDto? personal;

  bool get isAthlete => exists && role?.toLowerCase() == 'client';

  bool accessEnded(DateTime now) =>
      accessEndsAt != null && now.isAfter(accessEndsAt!);

  factory AuthMeDto.fromJson(Map<String, dynamic> json) => AuthMeDto(
    exists: json['exists'] as bool? ?? false,
    userId: json['userId'] as String,
    role: json['role'] as String?,
    fullName: json['fullName'] as String?,
    preferredWeightUnit: json['preferredWeightUnit'] == null
        ? null
        : WeightUnit.parse(json['preferredWeightUnit'] as String),
    coachName: json['coachName'] as String?,
    exerciseFeedbackEnabled: json['exerciseFeedbackEnabled'] as bool? ?? false,
    bodyMeasurements: [
      for (final j in json['bodyMeasurements'] as List? ?? const [])
        ?BodyMeasure.fromJson(j),
    ],
    accessEndsAt: json['accessEndsAt'] == null
        ? null
        : DateTime.tryParse(json['accessEndsAt'] as String)?.toLocal(),
    coach: json['coach'] == null
        ? null
        : CoachProfileDto.fromJson(json['coach'] as Map<String, dynamic>),
    personal: json['personal'] == null
        ? null
        : PersonalInfoDto.fromJson(json['personal'] as Map<String, dynamic>),
  );
}
