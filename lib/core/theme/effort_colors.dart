import 'package:flutter/material.dart';

/// Color del esfuerzo (panel de la Sesión): turquesa (fácil) → dorado →
/// carmesí (al fallo). No verde→rojo, para no parecerse a otras apps.
Color effortColor(double rir) {
  const easy = Color(0xFF00C4B4);
  const mid = Color(0xFFE0B64A);
  const fail = Color(0xFFE5484D);
  final t = (4 - rir.clamp(0, 4)) / 4; // 0 = fácil, 1 = al fallo
  return t < .55 ? Color.lerp(easy, mid, t / .55)! : Color.lerp(mid, fail, (t - .55) / .45)!;
}
