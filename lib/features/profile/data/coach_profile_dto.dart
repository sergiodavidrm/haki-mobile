// Lo que el atleta ve de su coach en "Tu coach" (viene en GET /auth/me →
// coach). Experiencia = año actual − coachingSince.
class CoachProfileDto {
  const CoachProfileDto({
    required this.fullName,
    this.coachingSince,
    this.bio,
    this.certifications = const [],
  });

  final String fullName;

  /// Año en que empezó a entrenar atletas (null = no lo cargó).
  final int? coachingSince;
  final String? bio;
  final List<CoachCertificationDto> certifications;

  int? experienceYears(DateTime now) =>
      coachingSince == null ? null : (now.year - coachingSince!).clamp(0, 100);

  /// Sin experiencia, bio ni certificaciones: la pantalla muestra el aviso.
  bool get isEmpty =>
      coachingSince == null &&
      (bio?.trim().isEmpty ?? true) &&
      certifications.isEmpty;

  factory CoachProfileDto.fromJson(Map<String, dynamic> json) =>
      CoachProfileDto(
        fullName: json['fullName'] as String? ?? '',
        coachingSince: json['coachingSince'] as int?,
        bio: json['bio'] as String?,
        certifications: [
          for (final c in json['certifications'] as List? ?? const [])
            CoachCertificationDto.fromJson(c as Map<String, dynamic>),
        ],
      );
}

class CoachCertificationDto {
  const CoachCertificationDto({required this.name, this.issuer, this.year});

  final String name;
  final String? issuer;
  final int? year;

  /// "NSCA · 2019" (vacío si no tiene ninguno)
  String get subtitle => [
    issuer,
    year?.toString(),
  ].nonNulls.where((s) => s.isNotEmpty).join(' · ');

  factory CoachCertificationDto.fromJson(Map<String, dynamic> json) =>
      CoachCertificationDto(
        name: json['name'] as String,
        issuer: json['issuer'] as String?,
        year: json['year'] as int?,
      );
}
