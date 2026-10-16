import 'package:flutter/material.dart';

// Tokens de color propios de Haki (equivalente a las variables @theme del web).
// Los widgets leen colores SOLO de acá: context.colors.gold — nunca Color(0x...).
@immutable
class HakiColors extends ThemeExtension<HakiColors> {
  const HakiColors({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.navBar,
    required this.border,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.gold,
    required this.goldBright,
    required this.goldSurface,
    required this.goldBorder,
    required this.turquoise,
    required this.turquoiseSurface,
    required this.turquoiseBorder,
    required this.turquoiseMuted,
    required this.danger,
  });

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color navBar;
  final Color border;
  final Color text;
  final Color textSecondary;
  final Color textMuted;
  final Color gold;

  /// Dorado para texto e íconos sobre fondo oscuro (el `gold` no llega a 4.5:1).
  final Color goldBright;
  final Color goldSurface;
  final Color goldBorder;
  final Color turquoise;
  final Color turquoiseSurface;
  final Color turquoiseBorder;

  /// Texto secundario sobre superficies turquesa (superseries).
  final Color turquoiseMuted;
  final Color danger;

  /// Paleta vigente del atleta: Obsidian / Gold / Turquoise.
  static const obsidian = HakiColors(
    background: Color(0xFF0D0D0D),
    surface: Color(0xFF161616),
    surfaceHigh: Color(0xFF1F1F1F),
    navBar: Color(0xFF111111),
    border: Color(0xFF2A2A2A),
    text: Color(0xFFF2F2F2),
    textSecondary: Color(0xFFC8C8C8),
    textMuted: Color(0xFF9A9A9A),
    gold: Color(0xFFB8922A),
    goldBright: Color(0xFFE0B64A),
    goldSurface: Color(0xFF1F1A0E),
    goldBorder: Color(0xFF3A2F12),
    turquoise: Color(0xFF00C4B4),
    turquoiseSurface: Color(0xFF0F2A28),
    turquoiseBorder: Color(0xFF1D3A37),
    turquoiseMuted: Color(0xFF8FB9B5),
    danger: Color(0xFFE5484D),
  );

  @override
  HakiColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? navBar,
    Color? border,
    Color? text,
    Color? textSecondary,
    Color? textMuted,
    Color? gold,
    Color? goldBright,
    Color? goldSurface,
    Color? goldBorder,
    Color? turquoise,
    Color? turquoiseSurface,
    Color? turquoiseBorder,
    Color? turquoiseMuted,
    Color? danger,
  }) {
    return HakiColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      navBar: navBar ?? this.navBar,
      border: border ?? this.border,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      gold: gold ?? this.gold,
      goldBright: goldBright ?? this.goldBright,
      goldSurface: goldSurface ?? this.goldSurface,
      goldBorder: goldBorder ?? this.goldBorder,
      turquoise: turquoise ?? this.turquoise,
      turquoiseSurface: turquoiseSurface ?? this.turquoiseSurface,
      turquoiseBorder: turquoiseBorder ?? this.turquoiseBorder,
      turquoiseMuted: turquoiseMuted ?? this.turquoiseMuted,
      danger: danger ?? this.danger,
    );
  }

  @override
  HakiColors lerp(HakiColors? other, double t) {
    if (other == null) return this;
    return HakiColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      navBar: Color.lerp(navBar, other.navBar, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldBright: Color.lerp(goldBright, other.goldBright, t)!,
      goldSurface: Color.lerp(goldSurface, other.goldSurface, t)!,
      goldBorder: Color.lerp(goldBorder, other.goldBorder, t)!,
      turquoise: Color.lerp(turquoise, other.turquoise, t)!,
      turquoiseSurface: Color.lerp(
        turquoiseSurface,
        other.turquoiseSurface,
        t,
      )!,
      turquoiseBorder: Color.lerp(turquoiseBorder, other.turquoiseBorder, t)!,
      turquoiseMuted: Color.lerp(turquoiseMuted, other.turquoiseMuted, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension HakiColorsX on BuildContext {
  HakiColors get colors => Theme.of(this).extension<HakiColors>()!;
}
