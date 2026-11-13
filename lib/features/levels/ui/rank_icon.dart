import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/rank_colors.dart';

/// Ícono de cada rango (canvas "Haki · Niveles y logros", fila "Íconos de
/// rango"): sol naciente, lanzas cruzadas, kabuto, castillo y tessen. Mismos
/// trazos que el web (`app-rank-icon`), dibujados sobre una grilla de 48.
class RankIcon extends StatelessWidget {
  const RankIcon(this.rank, {super.key, this.size = 24, this.color, this.stroke});

  final Rank rank;
  final double size;
  final Color? color;

  /// Trazo en unidades de la grilla (48); por defecto más grueso si es chico
  final double? stroke;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _RankPainter(
        rank,
        color ?? rankColor(context, rank),
        stroke ?? (size <= 18 ? 3.4 : size <= 32 ? 2.8 : 2.4),
      ),
    ),
  );
}

class _RankPainter extends CustomPainter {
  _RankPainter(this.rank, this.color, this.stroke);

  final Rank rank;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 48);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();

    void line(double x1, double y1, double x2, double y2) => path
      ..moveTo(x1, y1)
      ..lineTo(x2, y2);
    void poly(List<double> p, {bool close = false}) {
      path.moveTo(p[0], p[1]);
      for (var i = 2; i < p.length; i += 2) {
        path.lineTo(p[i], p[i + 1]);
      }
      if (close) path.close();
    }

    // Arco de (x1,y1) a (x2,y2) alrededor de (cx,cy) pasando por arriba
    void arcOver(double cx, double cy, double r, double x1, double y1, double x2, double y2) {
      final a1 = math.atan2(y1 - cy, x1 - cx);
      var a2 = math.atan2(y2 - cy, x2 - cx);
      if (a2 < a1) a2 += 2 * math.pi;
      path
        ..moveTo(x1, y1)
        ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: r), a1, a2 - a1, false);
    }

    void quad(double x1, double y1, double cx, double cy, double x2, double y2) => path
      ..moveTo(x1, y1)
      ..quadraticBezierTo(cx, cy, x2, y2);
    void circle(double cx, double cy, double r) =>
        path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    switch (rank) {
      case Rank.awakening:
        line(5, 34, 43, 34);
        line(13, 40, 35, 40);
        arcOver(24, 34, 10, 14, 34, 34, 34);
        line(24, 20, 24, 15);
        line(14.1, 24.1, 10.9, 20.9);
        line(33.9, 24.1, 37.1, 20.9);
        line(9, 30, 5, 30);
        line(43, 30, 39, 30);
      case Rank.warrior:
        line(10, 41, 33, 15);
        poly([40, 8, 31, 11, 37, 17], close: true);
        line(28.5, 13.5, 33.5, 18.5);
        line(38, 41, 15, 15);
        poly([8, 8, 17, 11, 11, 17], close: true);
        line(19.5, 13.5, 14.5, 18.5);
      case Rank.samurai:
        arcOver(24, 30, 12, 12, 30, 36, 30);
        line(8, 30, 40, 30);
        poly([10, 30, 6, 38, 42, 38, 38, 30]);
        quad(14, 7, 24, 25, 34, 7);
        circle(24, 24, 2.5);
      case Rank.daimyo:
        poly([10, 42, 13, 32, 35, 32, 38, 42], close: true);
        poly([16, 32, 16, 26, 32, 26, 32, 32]);
        quad(11, 26, 24, 19, 37, 26);
        poly([19, 25, 19, 19, 29, 19, 29, 25]);
        quad(14, 19, 24, 13, 34, 19);
        poly([21, 18, 21, 13, 27, 13, 27, 18]);
        quad(18, 13, 24, 7, 30, 13);
        line(22, 42, 22, 38);
        arcOver(24, 38, 2, 22, 38, 26, 38);
        line(26, 38, 26, 42);
      case Rank.shogun:
        arcOver(24, 38, 19, 6.2, 31.5, 41.8, 31.5);
        line(6.2, 31.5, 18.4, 36);
        line(41.8, 31.5, 29.6, 36);
        arcOver(24, 38, 6, 18.4, 36, 29.6, 36);
        line(34.9, 22.4, 27.4, 33.1);
        line(24, 19, 24, 32);
        line(13.1, 22.4, 20.6, 33.1);
        circle(24, 38, 1.6);
        line(24, 40, 24, 46);
        poly([24, 4, 26, 8, 22, 8], close: true);
        line(15, 7, 17.5, 10);
        line(33, 7, 30.5, 10);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RankPainter old) =>
      old.rank != rank || old.color != color || old.stroke != stroke;
}
