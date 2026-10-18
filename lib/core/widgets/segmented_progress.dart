import 'package:flutter/material.dart';

import '../theme/haki_colors.dart';

/// Barra de progreso por segmentos (semanas de un bloque, entrenos de la semana).
/// [done] segmentos turquesa, el siguiente dorado si [highlightCurrent].
class SegmentedProgress extends StatelessWidget {
  const SegmentedProgress({
    super.key,
    required this.total,
    required this.done,
    this.highlightCurrent = false,
    this.height = 6,
    this.trackColor,
  });

  final int total;
  final int done;
  final bool highlightCurrent;
  final double height;

  /// Color de los segmentos sin hacer (por defecto el borde).
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: i < done
                    ? c.turquoise
                    : (highlightCurrent && i == done
                          ? c.gold
                          : trackColor ?? c.border),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
