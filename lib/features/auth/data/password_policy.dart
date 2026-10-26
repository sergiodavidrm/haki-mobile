// Misma política que Supabase (Authentication → Email: mínimo 8, "Letters and
// digits") y que el web (core/constants/password.ts). Supabase la hace cumplir
// igual; esto avisa mientras escribe.
const passwordMinLength = 8;

final _letter = RegExp('[A-Za-z]');
final _digit = RegExp(r'\d');

class PasswordChecks {
  PasswordChecks(this.password, {this.email = ''});

  final String password;
  final String email;

  bool get length => password.length >= passwordMinLength;
  bool get letter => _letter.hasMatch(password);
  bool get digit => _digit.hasMatch(password);
  bool get notEmail =>
      password.isEmpty ||
      email.trim().isEmpty ||
      password.toLowerCase() != email.trim().toLowerCase();

  bool get ok => length && letter && digit && notEmail;
}
