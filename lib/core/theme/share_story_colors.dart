import 'package:flutter/painting.dart';

/// Colores fijos de los stickers para historias: van sobre la foto del atleta
/// en Instagram, así que no siguen el tema de la app. Canvas
/// https://claude.ai/artifact/XgxAnMeTfAh9gdVjzmFy2t
abstract final class ShareStoryColors {
  /// Fondos que se pueden elegir (con opacidad): obsidiana, dorado,
  /// turquesa, blanco. Sobre blanco el texto va oscuro.
  static const backgrounds = [
    Color(0xFF0D0D0D),
    Color(0xFFB8922A),
    Color(0xFF00968A),
    Color(0xFFFFFFFF),
  ];
  static const lightBackground = 3;

  static const shadow = Color(0x99000000);

  /// Día hecho de la semana (relleno) y su ✓
  static const doneFill = Color(0xFF00C4B4);
  static const onDone = Color(0xFF0D0D0D);

  /// Cuadriculado de la vista previa (no sale en la imagen)
  static const checkerLight = Color(0xFF444444);
  static const checkerDark = Color(0xFF3A3A3A);
}

/// Colores del contenido según el fondo (claro = blanco elegido).
class StickerPalette {
  const StickerPalette._({
    required this.ink,
    required this.muted,
    required this.gold,
    required this.accent,
    required this.warn,
    required this.track,
    required this.rest,
    required this.light,
  });

  final Color ink;
  final Color muted;
  final Color gold;
  final Color accent;
  final Color warn;
  final Color track;
  final Color rest;
  final bool light;

  static const onDark = StickerPalette._(
    ink: Color(0xFFFFFFFF),
    muted: Color(0xC7FFFFFF),
    gold: Color(0xFFE8C35A),
    accent: Color(0xFF3FE0D2),
    warn: Color(0xFFFFB27A),
    track: Color(0x2EFFFFFF),
    rest: Color(0x2EFFFFFF),
    light: false,
  );

  static const onLight = StickerPalette._(
    ink: Color(0xFF141414),
    muted: Color(0xFF575757),
    gold: Color(0xFF8A6A12),
    accent: Color(0xFF00766C),
    warn: Color(0xFFB4501A),
    track: Color(0x1A000000),
    rest: Color(0x1F000000),
    light: true,
  );
}
