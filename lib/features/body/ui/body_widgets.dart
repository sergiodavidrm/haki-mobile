import 'package:flutter/material.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../data/body_measures.dart';

/// Línea turquesa de una serie (x proporcional a la fecha). [grid] (tema v2)
/// = relleno suave, punto por registro, 2 líneas de grilla con su valor y el
/// punto dorado final con su valor; sin grid es el sparkline del Perfil.
class BodyLineChart extends StatelessWidget {
  const BodyLineChart({
    super.key,
    required this.points,
    this.height = 150,
    this.grid = true,
    this.semanticLabel,
  });

  final List<DatedValue> points;
  final double height;
  final bool grid;
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
          painter: _LinePainter(
            points: points,
            grid: grid,
            line: c.turquoise,
            gridColor: c.track,
            labelColor: c.text,
            axisColor: c.textMuted,
            background: c.surface,
            dot: c.goldBright,
          ),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.points,
    required this.grid,
    required this.line,
    required this.gridColor,
    required this.labelColor,
    required this.axisColor,
    required this.background,
    required this.dot,
  });

  final List<DatedValue> points;
  final bool grid;
  final Color line;
  final Color gridColor;
  final Color labelColor;
  final Color axisColor;
  final Color background;
  final Color dot;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      if (grid) _gridLines(canvas, size, 0, size.height, null);
      return;
    }

    final t0 = points.first.date.millisecondsSinceEpoch;
    final span = points.last.date.millisecondsSinceEpoch - t0;
    var lo = points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    var hi = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    // Rango mínimo de 1 para que 0.1 de diferencia no parezca un desplome
    if (hi - lo < 1) {
      final mid = (hi + lo) / 2;
      lo = mid - 0.5;
      hi = mid + 0.5;
    }
    // Con grilla: aire arriba para el valor y a la izquierda para la escala
    final top = grid ? 24.0 : 6.0;
    const bottom = 6.0;
    final h = size.height - top - bottom;
    double yOf(double v) => top + h * (1 - (v - lo) / (hi - lo));
    final left = grid ? _gridLines(canvas, size, top, h, (lo, hi, yOf)) : 6.0;
    const right = 8.0;
    Offset at(DatedValue p) => Offset(
      span == 0
          ? (left + size.width - right) / 2
          : left +
                (size.width - left - right) *
                    (p.date.millisecondsSinceEpoch - t0) /
                    span,
      yOf(p.value),
    );

    final path = Path()..moveTo(at(points.first).dx, at(points.first).dy);
    for (final p in points.skip(1)) {
      path.lineTo(at(p).dx, at(p).dy);
    }
    if (grid && points.length > 1) {
      // Relleno suave debajo de la línea (tema v2)
      final area = Path.from(path)
        ..lineTo(at(points.last).dx, top + h)
        ..lineTo(at(points.first).dx, top + h)
        ..close();
      canvas.drawPath(area, Paint()..color = line.withValues(alpha: .10));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = grid ? 2.5 : 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    if (grid && points.length <= 16) {
      // Un punto por registro (con muchos se vuelve ruido)
      for (final p in points.take(points.length - 1)) {
        final o = at(p);
        canvas.drawCircle(o, 4, Paint()..color = background);
        canvas.drawCircle(
          o,
          3.5,
          Paint()
            ..color = line
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
    if (grid || points.length == 1) {
      if (grid) {
        canvas.drawCircle(at(points.last), 6.5, Paint()..color = background);
      }
      canvas.drawCircle(at(points.last), grid ? 5 : 3, Paint()..color = dot);
    }
    if (grid) {
      // Valor del último punto, arriba del punto (o abajo si no entra)
      final last = at(points.last);
      final tp = TextPainter(
        text: TextSpan(
          text: formatWeight(points.last.value),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: dot,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final above = last.dy - 8 - tp.height;
      tp.paint(
        canvas,
        Offset(
          (last.dx - tp.width / 2).clamp(0, size.width - tp.width),
          above >= 0 ? above : last.dy + 8,
        ),
      );
    }
  }

  /// 2 líneas de grilla con su valor a la izquierda + la base. Devuelve dónde
  /// empieza el gráfico (después de los valores).
  double _gridLines(
    Canvas canvas,
    Size size,
    double top,
    double h,
    (double, double, double Function(double))? scale,
  ) {
    final g = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    if (scale == null) {
      for (final f in const [0.25, 0.75, 1.0]) {
        canvas.drawLine(Offset(0, h * f), Offset(size.width, h * f), g);
      }
      return 0;
    }
    final (lo, hi, yOf) = scale;
    final values = [lo + (hi - lo) * .75, lo + (hi - lo) * .25];
    final labels = [
      for (final v in values)
        TextPainter(
          text: TextSpan(
            text: formatWeight(v),
            style: TextStyle(fontSize: 10, color: axisColor),
          ),
          textDirection: TextDirection.ltr,
        )..layout(),
    ];
    final gutter = labels.map((t) => t.width).reduce((a, b) => a > b ? a : b) + 6;
    for (final (k, v) in values.indexed) {
      final y = yOf(v);
      canvas.drawLine(Offset(gutter, y), Offset(size.width, y), g);
      labels[k].paint(canvas, Offset(0, y - labels[k].height / 2));
    }
    canvas.drawLine(Offset(gutter, top + h), Offset(size.width, top + h), g);
    return gutter + 8;
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.points != points ||
      old.line != line ||
      old.grid != grid ||
      old.labelColor != labelColor;
}

/// "−0.6" turquesa si bajó, dorado si subió, gris si quedó igual.
class DeltaText extends StatelessWidget {
  const DeltaText(this.delta, {super.key, this.suffix = '', this.size = 13});

  final double delta;
  final String suffix;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = formatDelta(delta);
    final color = text == '0.0'
        ? c.textMuted
        : delta < 0
        ? c.turquoise
        : c.goldBright;
    return Text(
      '$text$suffix',
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
