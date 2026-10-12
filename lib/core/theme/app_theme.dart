import 'package:flutter/material.dart';

import 'haki_colors.dart';

// Arma el ThemeData de Material a partir de los tokens. Cambiar de paleta =
// pasar otro HakiColors acá; los widgets no se tocan.
ThemeData buildAppTheme(HakiColors c) {
  final scheme = ColorScheme.dark(
    primary: c.gold,
    onPrimary: c.background,
    secondary: c.turquoise,
    onSecondary: c.background,
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
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.background,
    extensions: [c],
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      labelStyle: TextStyle(color: c.textMuted),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: c.gold, width: 1.5)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
