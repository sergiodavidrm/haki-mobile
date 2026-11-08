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
    required this.mobility,
    required this.mobilityText,
    required this.cardio,
    required this.cardioText,
    required this.onAccent,
    required this.primary,
    required this.onPrimary,
    required this.track,
    required this.todayBorder,
    required this.cardShadow,
    required this.onTurquoise,
    required this.weekTabSelected,
    required this.weekTabSelectedText,
    required this.weekTabSelectedBorder,
    required this.currentWeekFill,
    required this.currentWeekTrack,
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

  /// Dorado para texto e íconos sobre el fondo (el `gold` no llega a 4.5:1):
  /// más claro en el tema oscuro, más oscuro en el claro.
  final Color goldBright;
  final Color goldSurface;
  final Color goldBorder;
  final Color turquoise;
  final Color turquoiseSurface;
  final Color turquoiseBorder;

  /// Texto secundario sobre superficies turquesa (superseries).
  final Color turquoiseMuted;
  final Color danger;

  /// Tipos de ejercicio (2026-11-03): solo borde + etiqueta, sin fondos.
  final Color mobility;
  final Color mobilityText;
  final Color cardio;
  final Color cardioText;

  /// Texto e íconos sobre dorado o turquesa (botones, badges, checks): oscuro
  /// en los dos temas.
  final Color onAccent;

  /// Tema v2 (2026-11-07, canvas "Haki · Tema v2"): botón primario y "hoy" de
  /// la tira. Dorado en el oscuro, obsidiana en el claro (el dorado relleno se
  /// veía mostaza sobre claro).
  final Color primary;
  final Color onPrimary;

  /// Parte vacía de barras, anillos y grillas de gráficos.
  final Color track;

  /// Borde del día de hoy en la lista de días (tab Programa): dorado fino.
  final Color todayBorder;

  /// Sombra de las tarjetas: el claro separa las cards del fondo con sombra;
  /// el oscuro solo con el borde.
  final List<BoxShadow> cardShadow;

  /// Texto e íconos sobre turquesa relleno (día hecho, check): blanco en el
  /// claro (el turquesa es oscuro), obsidiana en el oscuro.
  final Color onTurquoise;

  /// Selector S1…SN: la semana elegida. Oscuro = dorado (como antes del tema
  /// v2, Sergio); claro = blanco sobre el gris.
  final Color weekTabSelected;
  final Color weekTabSelectedText;
  final Color weekTabSelectedBorder;

  /// Barra del bloque: la semana en curso. Oscuro = dorado; claro = turquesa
  /// como las demás.
  final Color currentWeekFill;
  final Color currentWeekTrack;

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
    mobility: Color(0xFF8B6FD6),
    mobilityText: Color(0xFFB79CFF),
    cardio: Color(0xFFFF7A45),
    cardioText: Color(0xFFFF7A45),
    onAccent: Color(0xFF0D0D0D),
    primary: Color(0xFFB8922A),
    onPrimary: Color(0xFF0D0D0D),
    track: Color(0xFF2A2A2A),
    todayBorder: Color(0xFFB8922A),
    cardShadow: [],
    onTurquoise: Color(0xFF0D0D0D),
    weekTabSelected: Color(0xFF1F1A0E),
    weekTabSelectedText: Color(0xFFE0B64A),
    weekTabSelectedBorder: Color(0xFFB8922A),
    currentWeekFill: Color(0xFFB8922A),
    currentWeekTrack: Color(0xFF3A2F12),
  );

  /// Tema claro v2 (2026-11-07, canvas "Haki · Tema v2"): fondo gris frío
  /// (el crema se veía pálido), cards blancas con sombra, botón primario
  /// obsidiana. Dorado y turquesa más oscuros donde son texto.
  static const light = HakiColors(
    background: Color(0xFFEEF0F3),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFF4F5F7),
    navBar: Color(0xFFFFFFFF),
    border: Color(0xFFE2E5EA),
    text: Color(0xFF111316),
    textSecondary: Color(0xFF3B4048),
    textMuted: Color(0xFF5E646E),
    gold: Color(0xFFB8922A),
    goldBright: Color(0xFF7A5C0C),
    goldSurface: Color(0xFFFBF3DF),
    goldBorder: Color(0xFFEAD9A8),
    turquoise: Color(0xFF00766C),
    turquoiseSurface: Color(0xFFE0F2F0),
    turquoiseBorder: Color(0xFFBFE3DF),
    turquoiseMuted: Color(0xFF3F7A75),
    danger: Color(0xFFD93036),
    mobility: Color(0xFF8B6FD6),
    mobilityText: Color(0xFF6B4FC0),
    cardio: Color(0xFFFF7A45),
    cardioText: Color(0xFFB4501A),
    onAccent: Color(0xFF141414),
    primary: Color(0xFF141414),
    onPrimary: Color(0xFFFFFFFF),
    track: Color(0xFFE4E7EC),
    // Dorado como en el oscuro (el borde obsidiana se veía pesado, Sergio)
    todayBorder: Color(0xFFB8922A),
    cardShadow: [
      BoxShadow(color: Color(0x0D111316), blurRadius: 2, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x0F111316), blurRadius: 14, offset: Offset(0, 4)),
    ],
    onTurquoise: Color(0xFFFFFFFF),
    weekTabSelected: Color(0xFFFFFFFF),
    weekTabSelectedText: Color(0xFF111316),
    weekTabSelectedBorder: Color(0x00000000),
    currentWeekFill: Color(0xFF00766C),
    currentWeekTrack: Color(0xFFE4E7EC),
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
    Color? mobility,
    Color? mobilityText,
    Color? cardio,
    Color? cardioText,
    Color? onAccent,
    Color? primary,
    Color? onPrimary,
    Color? track,
    Color? todayBorder,
    List<BoxShadow>? cardShadow,
    Color? onTurquoise,
    Color? weekTabSelected,
    Color? weekTabSelectedText,
    Color? weekTabSelectedBorder,
    Color? currentWeekFill,
    Color? currentWeekTrack,
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
      mobility: mobility ?? this.mobility,
      mobilityText: mobilityText ?? this.mobilityText,
      cardio: cardio ?? this.cardio,
      cardioText: cardioText ?? this.cardioText,
      onAccent: onAccent ?? this.onAccent,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      track: track ?? this.track,
      todayBorder: todayBorder ?? this.todayBorder,
      cardShadow: cardShadow ?? this.cardShadow,
      onTurquoise: onTurquoise ?? this.onTurquoise,
      weekTabSelected: weekTabSelected ?? this.weekTabSelected,
      weekTabSelectedText: weekTabSelectedText ?? this.weekTabSelectedText,
      weekTabSelectedBorder:
          weekTabSelectedBorder ?? this.weekTabSelectedBorder,
      currentWeekFill: currentWeekFill ?? this.currentWeekFill,
      currentWeekTrack: currentWeekTrack ?? this.currentWeekTrack,
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
      mobility: Color.lerp(mobility, other.mobility, t)!,
      mobilityText: Color.lerp(mobilityText, other.mobilityText, t)!,
      cardio: Color.lerp(cardio, other.cardio, t)!,
      cardioText: Color.lerp(cardioText, other.cardioText, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      track: Color.lerp(track, other.track, t)!,
      todayBorder: Color.lerp(todayBorder, other.todayBorder, t)!,
      cardShadow: BoxShadow.lerpList(cardShadow, other.cardShadow, t)!,
      onTurquoise: Color.lerp(onTurquoise, other.onTurquoise, t)!,
      weekTabSelected: Color.lerp(weekTabSelected, other.weekTabSelected, t)!,
      weekTabSelectedText: Color.lerp(
        weekTabSelectedText,
        other.weekTabSelectedText,
        t,
      )!,
      weekTabSelectedBorder: Color.lerp(
        weekTabSelectedBorder,
        other.weekTabSelectedBorder,
        t,
      )!,
      currentWeekFill: Color.lerp(currentWeekFill, other.currentWeekFill, t)!,
      currentWeekTrack: Color.lerp(
        currentWeekTrack,
        other.currentWeekTrack,
        t,
      )!,
    );
  }
}

extension HakiColorsX on BuildContext {
  HakiColors get colors => Theme.of(this).extension<HakiColors>()!;
}
