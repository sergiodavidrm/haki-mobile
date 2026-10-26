import 'package:flutter/material.dart';

/// Colores del isotipo (J2: anillos atravesados por una pesa). Iguales a
/// `branding/make_logo.py` y al web (`--color-logo-*`). La versión clara es
/// para fondos claros (tema claro); el splash es siempre oscuro.
class HakiLogoColors {
  const HakiLogoColors({
    required this.gold,
    required this.gold2,
    required this.gold3,
    required this.bar,
    required this.core,
  });

  /// Anillos y discos grandes.
  final Color gold;

  /// Discos chicos.
  final Color gold2;

  /// Topes.
  final Color gold3;
  final Color bar;

  /// Núcleo y anillo interior.
  final Color core;

  static const dark = HakiLogoColors(
    gold: Color(0xFFC9A84C),
    gold2: Color(0xFF9A7A22),
    gold3: Color(0xFF7A5E18),
    bar: Color(0xFF00A99A),
    core: Color(0xFF00C4B4),
  );

  static const light = HakiLogoColors(
    gold: Color(0xFF8A6A12),
    gold2: Color(0xFF6B520E),
    gold3: Color(0xFF4F3C0A),
    bar: Color(0xFF00897E),
    core: Color(0xFF00A99A),
  );

  static HakiLogoColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
