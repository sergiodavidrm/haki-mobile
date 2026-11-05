import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/haki_colors.dart';

/// Anillo turquesa a medias alrededor de [child] (día parcial: hecho con
/// menos de la mitad de las series). Arranca arriba y avanza en sentido
/// horario; [progress] 0–1.
class PartialRing extends StatelessWidget {
  const PartialRing({
    super.key,
    required this.size,
    required this.progress,
    this.strokeWidth = 2,
    required this.child,
  });

  final double size;
  final double progress;
  final double strokeWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0, 1),
          strokeWidth: strokeWidth,
          track: c.turquoiseBorder,
          arc: c.turquoise,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.track,
    required this.arc,
  });

  final double progress;
  final double strokeWidth;
  final Color track;
  final Color arc;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    ).deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, 2 * pi, false, paint..color = track);
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        paint
          ..color = arc
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.strokeWidth != strokeWidth ||
      old.track != track ||
      old.arc != arc;
}
