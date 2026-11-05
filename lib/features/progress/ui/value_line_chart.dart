import 'package:flutter/material.dart';

import '../../../core/theme/haki_colors.dart';

/// Línea por semana con el número arriba de cada punto (no hay eje Y: así se
/// lee sin adivinar). Los récords van en dorado y más grandes. Una semana sin
/// dato no corta la línea: une con la siguiente.
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
            grid: c.surfaceHigh,
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
    final h = size.height - _top - _bottom;
    final w = size.width - _side * 2;
    double x(int i) =>
        _side + (values.length <= 1 ? w / 2 : i * w / (values.length - 1));
    double y(double v) => _top + h - (v - min) * h / (max - min);

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final f in [0.0, 0.5, 1.0]) {
      final gy = _top + h * f;
      canvas.drawLine(Offset(0, gy), Offset(size.width, gy), gridPaint);
    }

    final path = Path();
    for (final (k, p) in points.indexed) {
      final o = Offset(x(p.$1), y(p.$2));
      k == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    final small = values.length > 8;
    for (final p in points) {
      final isPr = p.$1 < prs.length && prs[p.$1];
      final o = Offset(x(p.$1), y(p.$2));
      canvas.drawCircle(o, isPr ? 6 : 4, Paint()..color = background);
      canvas.drawCircle(o, isPr ? 5 : 3.5, Paint()..color = isPr ? pr : line);
      final tp = TextPainter(
        text: TextSpan(
          text: format(p.$2),
          style: TextStyle(
            fontSize: small ? 10 : 12,
            fontWeight: isPr ? FontWeight.w800 : FontWeight.w600,
            color: isPr ? pr : label,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      // Arriba del punto; abajo si está pegado al techo
      final above = o.dy - tp.height - 8;
      final dy = above < 2 ? o.dy + 8 : above;
      final dx = (o.dx - tp.width / 2).clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(dx, dy));
    }

    // Fechas: hasta ~5 para que no se pisen
    final step = (values.length / 5).ceil().clamp(1, 99);
    for (var i = 0; i < xLabels.length; i++) {
      if (i % step != 0 && i != xLabels.length - 1) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: xLabels[i],
          style: TextStyle(fontSize: 10, color: axis),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final dx = (x(i) - tp.width / 2).clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(dx, size.height - tp.height));
    }
  }

  @override
  bool shouldRepaint(_Painter old) =>
      old.values != values || old.prs != prs || old.line != line;
}
