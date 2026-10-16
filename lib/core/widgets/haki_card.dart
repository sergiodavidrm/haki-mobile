import 'package:flutter/material.dart';

import '../theme/haki_colors.dart';

enum HakiCardTone { neutral, gold, turquoise }

/// Tarjeta base del mockup: superficie oscura, borde de 1 px y esquinas grandes.
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
  });

  final Widget child;
  final HakiCardTone tone;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

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
      side: BorderSide(color: border),
    );

    return Material(
      color: bg,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
