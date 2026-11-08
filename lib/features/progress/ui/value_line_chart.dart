import 'package:flutter/material.dart';

import '../../../core/theme/haki_colors.dart';

/// Línea por semana con el número arriba de cada punto (tema v2, 2026-11-07):
/// relleno suave, 2 líneas de grilla con su valor, récords en dorado. Una
/// semana sin dato une con la siguiente en punteado (no se inventa el valor).
class ValueLineChart extends StatelessWidget {
  const ValueLineChart({
    super.key,
    required this.values,
    required this.xLabels,
    required this.format,
    this.prs = const [],
    this.height = 200,
    this.semanticLabel,
  });

  final List<double?> values;
  final List<String> xLabels;
  final String Function(double) format;

  /// Por columna: récord nuevo (punto dorado)
  final List<bool> prs;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _Painter(
            values: values,
            xLabels: xLabels,
            prs: prs,
            format: format,
            line: c.turquoise,
            pr: c.goldBright,
            grid: c.track,
            label: c.textSecondary,
            axis: c.textMuted,
            background: c.surface,
          ),
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  _Painter({
    required this.values,
    required this.xLabels,
    required this.prs,
    required this.format,
    required this.line,
    required this.pr,
    required this.grid,
    required this.label,
    required this.axis,
    required this.background,
  });

  final List<double?> values;
  final List<String> xLabels;
  final List<bool> prs;
  final String Function(double) format;
  final Color line, pr, grid, label, axis, background;

  static const _top = 24.0;
  static const _bottom = 22.0;
  static const _side = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      for (var i = 0; i < values.length; i++)
        if (values[i] != null) (i, values[i]!),
    ];
    if (points.isEmpty) return;
    var min = points.map((p) => p.$2).reduce((a, b) => a < b ? a : b);
    var max = points.map((p) => p.$2).reduce((a, b) => a > b ? a : b);
    final pad = (max - min) * 0.15;
    min -= pad == 0 ? 1 : pad;
    max += pad == 0 ? 1 : pad;

    // Tema v2: 2 líneas de grilla con su valor a la izquierda
    TextPainter text(String t, double size, Color color, [FontWeight? w]) =>
        TextPainter(
          text: TextSpan(
            text: t,
            style: TextStyle(fontSize: size, fontWeight: w, color: color),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
    final gridValues = [min + (max - min) * .75, min + (max - min) * .25];
    final gridLabels = [for (final v in gridValues) text(format(v), 10, axis)];
    final gutter =
        gridLabels.map((t) => t.width).reduce((a, b) => a > b ? a : b) + 8;

    final h = size.height - _top - _bottom;
    final left = gutter + _side / 2;
    final w = size.width - left - _side;
    double x(int i) =>
        left + (values.length <= 1 ? w / 2 : i * w / (values.length - 1));
    double y(double v) => _top + h - (v - min) * h / (max - min);

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final (k, v) in gridValues.indexed) {
      final gy = y(v);
      canvas.drawLine(Offset(gutter, gy), Offset(size.width, gy), gridPaint);
      gridLabels[k].paint(canvas, Offset(0, gy - gridLabels[k].height / 2));
    }
    canvas.drawLine(
      Offset(gutter, _top + h),
      Offset(size.width, _top + h),
      gridPaint,
    );

    // Relleno suave debajo de la línea
    final offsets = [for (final p in points) Offset(x(p.$1), y(p.$2))];
    if (offsets.length > 1) {
      final area = Path()..moveTo(offsets.first.dx, _top + h);
      for (final o in offsets) {
        area.lineTo(o.dx, o.dy);
      }
      area
        ..lineTo(offsets.last.dx, _top + h)
        ..close();
      canvas.drawPath(area, Paint()..color = line.withValues(alpha: .10));
    }

    // Línea: tramo punteado si hay semanas sin dato en el medio (no se
    // inventan)
    final stroke = Paint()
      ..color = line
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var k = 1; k < points.length; k++) {
      final a = offsets[k - 1], b = offsets[k];
      if (points[k].$1 - points[k - 1].$1 == 1) {
        canvas.drawLine(a, b, stroke);
      } else {
        _dashed(canvas, a, b, stroke);
      }
    }

    final small = values.length > 8;
    for (final (k, p) in points.indexed) {
      final isPr = p.$1 < prs.length && prs[p.$1];
      final o = offsets[k];
      if (isPr) {
        canvas.drawCircle(o, 7, Paint()..color = background);
        canvas.drawCircle(o, 5.5, Paint()..color = pr);
      } else {
        canvas.drawCircle(o, 4.5, Paint()..color = background);
        canvas.drawCircle(
          o,
          4,
          Paint()
            ..color = line
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2,
        );
      }
      final tp = text(
        format(p.$2),
        small ? 10 : 12,
        isPr ? pr : label,
        isPr ? FontWeight.w800 : FontWeight.w600,
      );
      // Arriba del punto; abajo si está pegado al techo
      final above = o.dy - tp.height - 8;
      final dy = above < 2 ? o.dy + 8 : above;
      final dx = (o.dx - tp.width / 2).clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(dx, dy));
    }

    // Semanas: hasta ~5 para que no se pisen
    final step = (values.length / 5).ceil().clamp(1, 99);
    for (var i = 0; i < xLabels.length; i++) {
      if (i % step != 0 && i != xLabels.length - 1) continue;
      final tp = text(xLabels[i], 10, axis);
      final dx = (x(i) - tp.width / 2).clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(dx, size.height - tp.height));
    }
  }

  static void _dashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 5.0, gap = 5.0;
    final d = b - a;
    final len = d.distance;
    if (len == 0) return;
    final dir = d / len;
    for (var t = 0.0; t < len; t += dash + gap) {
      final end = (t + dash).clamp(0.0, len);
      canvas.drawLine(a + dir * t, a + dir * end, paint);
    }
  }

  @override
  bool shouldRepaint(_Painter old) =>
      old.values != values || old.prs != prs || old.line != line;
}
