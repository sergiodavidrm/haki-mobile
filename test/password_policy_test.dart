import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/auth/data/password_policy.dart';

void main() {
  test('mínimo 8 con letras y números', () {
    expect(PasswordChecks('haki2026').ok, isTrue);
    expect(PasswordChecks('haki202').ok, isFalse, reason: '7 caracteres');
    expect(PasswordChecks('12345678').ok, isFalse, reason: 'sin letras');
    expect(PasswordChecks('hakihaki').ok, isFalse, reason: 'sin números');
  });

  test('no puede ser el email', () {
    final checks = PasswordChecks('Laura1@correo.com', email: ' laura1@correo.com ');
    expect(checks.notEmail, isFalse);
    expect(checks.ok, isFalse);
    expect(PasswordChecks('haki2026', email: 'laura@correo.com').ok, isTrue);
  });

  test('vacía no marca el requisito del email como incumplido', () {
    expect(PasswordChecks('', email: 'laura@correo.com').notEmail, isTrue);
  });
}
