// GET /auth/me → { exists, userId, role }. role viene del enum de Postgres
// ("CLIENT" | "COACH" | "ADMIN") o null: comparar sin distinguir mayúsculas.
class AuthMeDto {
  const AuthMeDto({required this.exists, required this.userId, this.role});

  final bool exists;
  final String userId;
  final String? role;

  bool get isAthlete => exists && role?.toLowerCase() == 'client';

  factory AuthMeDto.fromJson(Map<String, dynamic> json) => AuthMeDto(
        exists: json['exists'] as bool? ?? false,
        userId: json['userId'] as String,
        role: json['role'] as String?,
      );
}
