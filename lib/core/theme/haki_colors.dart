import 'package:flutter/material.dart';

// Tokens de color propios de Haki (equivalente a las variables @theme del web).
// Los widgets leen colores SOLO de acá: context.colors.gold — nunca Color(0x...).
@immutable
class HakiColors extends ThemeExtension<HakiColors> {
  const HakiColors({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.gold,
    required this.turquoise,
    required this.danger,
  });

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color border;
  final Color text;
  final Color textMuted;
  final Color gold;
  final Color turquoise;
  final Color danger;

  /// Paleta vigente del atleta: Obsidian / Gold / Turquoise.
  static const obsidian = HakiColors(
    background: Color(0xFF0D0D0D),
    surface: Color(0xFF161616),
    surfaceHigh: Color(0xFF1F1F1F),
    border: Color(0xFF2A2A2A),
    text: Color(0xFFF2F2F2),
    textMuted: Color(0xFF9A9A9A),
    gold: Color(0xFFB8922A),
    turquoise: Color(0xFF00C4B4),
    danger: Color(0xFFE5484D),
  );

  @override
  HakiColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? border,
    Color? text,
    Color? textMuted,
    Color? gold,
    Color? turquoise,
    Color? danger,
  }) {
    return HakiColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      border: border ?? this.border,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      gold: gold ?? this.gold,
      turquoise: turquoise ?? this.turquoise,
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
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      turquoise: Color.lerp(turquoise, other.turquoise, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension HakiColorsX on BuildContext {
  HakiColors get colors => Theme.of(this).extension<HakiColors>()!;
}
