import 'package:flutter/material.dart';

import '../theme/haki_colors.dart';

enum HakiCardTone { neutral, gold, turquoise }

/// Tarjeta base del mockup: superficie, borde de 1 px, esquinas grandes y, en
/// el tema claro, sombra suave (`cardShadow`).
/// [tone] gold = destacada (día de hoy, PR); turquoise = aviso del coach.
/// Con [onTap] es tocable (ripple dentro de la forma).
class HakiCard extends StatelessWidget {
  const HakiCard({
    super.key,
    required this.child,
    this.tone = HakiCardTone.neutral,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.onTap,
    this.borderColor,
    this.borderWidth = 1,
  });

  final Widget child;
  final HakiCardTone tone;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  /// Pisa el borde del [tone] (día de hoy en Programa: 2 px `todayBorder`).
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, border) = switch (tone) {
      HakiCardTone.neutral => (c.surface, c.border),
      HakiCardTone.gold => (c.goldSurface, c.gold),
      HakiCardTone.turquoise => (c.turquoiseSurface, c.turquoiseBorder),
    };
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor ?? border, width: borderWidth),
    );

    final card = Material(
      color: bg,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
    // Tema claro: la sombra separa la card del fondo (en el oscuro no hay).
    if (c.cardShadow.isEmpty) return card;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: c.cardShadow,
      ),
      child: card,
    );
  }
}
