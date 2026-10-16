import 'package:flutter/material.dart';

import '../theme/haki_colors.dart';

enum PillTone { neutral, gold, turquoise }

/// Chip informativo (no tocable): "7 ejercicios", "2 superseries", "NUEVO PR".
class PillChip extends StatelessWidget {
  const PillChip(
    this.label, {
    super.key,
    this.tone = PillTone.neutral,
    this.icon,
  });

  final String label;
  final PillTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (tone) {
      PillTone.neutral => (c.surfaceHigh, c.textSecondary),
      PillTone.gold => (c.goldSurface, c.goldBright),
      PillTone.turquoise => (c.turquoiseSurface, c.turquoise),
    };

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
