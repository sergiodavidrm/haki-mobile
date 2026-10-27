import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/settings/data/personal_info.dart';

void main() {
  test('cm ↔ ft/in redondea a la pulgada y vuelve con un decimal', () {
    expect(cmToFeetInches(178), (feet: 5, inches: 10));
    expect(cmToFeetInches(152.4), (feet: 5, inches: 0));
    expect(feetInchesToCm(5, 10), 177.8);
    expect(feetInchesToCm(6, 0), 182.9);
  });

  test('personal de /auth/me: enums de la API y campos vacíos', () {
    final p = PersonalInfoDto.fromJson({
      'email': 'a@b.com',
      'gender': 'Other',
      'heightCm': 178,
      'heightUnit': 'IN',
      'injuriesText': null,
      'primaryGoal': 'MuscleGain',
    });
    expect(p.gender, Gender.other);
    expect(p.heightCm, 178.0);
    expect(p.heightUnit, HeightUnit.ftIn);
    expect(p.injuries, isNull);
    expect(PersonalInfoDto.fromJson({'email': 'x'}).gender, isNull);
  });
}
