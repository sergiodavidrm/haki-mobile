import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/auth/data/auth_me_dto.dart';

void main() {
  test('/auth/me trae el perfil del coach', () {
    final me = AuthMeDto.fromJson({
      'exists': true,
      'userId': 'u1',
      'role': 'CLIENT',
      'coachName': 'Andrés Solano',
      'coach': {
        'fullName': 'Andrés Solano',
        'coachingSince': 2018,
        'bio': 'Fuerza e hipertrofia.',
        'certifications': [
          {'name': 'CSCS', 'issuer': 'NSCA', 'year': 2019},
          {'name': 'Nutrición deportiva', 'issuer': null, 'year': null},
        ],
      },
    });
    final coach = me.coach!;
    expect(coach.experienceYears(DateTime(2026, 10, 23)), 8);
    expect(coach.certifications.first.subtitle, 'NSCA · 2019');
    expect(coach.certifications.last.subtitle, '');
    expect(coach.isEmpty, isFalse);
  });

  test('coach sin datos y API vieja', () {
    final empty = AuthMeDto.fromJson({
      'exists': true,
      'userId': 'u1',
      'coach': {'fullName': 'A', 'certifications': []},
    }).coach!;
    expect(empty.isEmpty, isTrue);
    expect(empty.experienceYears(DateTime(2026)), isNull);

    expect(AuthMeDto.fromJson({'exists': true, 'userId': 'u1'}).coach, isNull);
  });
}
