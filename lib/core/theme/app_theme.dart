import 'package:flutter/material.dart';

import 'haki_colors.dart';

// Arma el ThemeData de Material a partir de los tokens. Cambiar de paleta =
// pasar otro HakiColors acá; los widgets no se tocan. [brightness] = tema
// claro (HakiColors.light) u oscuro (HakiColors.obsidian).
ThemeData buildAppTheme(
  HakiColors c, {
  Brightness brightness = Brightness.dark,
}) {
  final scheme =
      (brightness == Brightness.dark
              ? const ColorScheme.dark()
              : const ColorScheme.light())
          .copyWith(
            primary: c.gold,
            onPrimary: c.onAccent,
            secondary: c.turquoise,
            onSecondary: c.onAccent,
            surface: c.surface,
            onSurface: c.text,
            error: c.danger,
          );

  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c.border),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.background,
    extensions: [c],
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      labelStyle: TextStyle(color: c.textMuted),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: c.gold, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.navBar,
      indicatorColor: Colors.transparent,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: s.contains(WidgetState.selected) ? c.goldBright : c.textMuted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? c.goldBright : c.textMuted,
        ),
      ),
    ),
  );
}
