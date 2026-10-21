import 'package:flutter/material.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../data/body_measures.dart';

/// Línea turquesa de una serie (x proporcional a la fecha). [grid] = las 3
/// líneas horizontales y el punto dorado final con su valor (gráfico de
/// Peso); sin grid
/// es el sparkline de la tarjeta del Perfil.
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
            gridColor: c.surfaceHigh,
            labelColor: c.text,
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
    required this.dot,
  });

  final List<DatedValue> points;
  final bool grid;
  final Color line;
  final Color gridColor;
  final Color labelColor;
  final Color dot;

  @override
  void paint(Canvas canvas, Size size) {
    if (grid) {
      final g = Paint()
        ..color = gridColor
        ..strokeWidth = 1;
      for (final f in const [0.2, 0.5, 0.8]) {
        canvas.drawLine(
          Offset(0, size.height * f),
          Offset(size.width, size.height * f),
          g,
        );
      }
    }
    if (points.isEmpty) return;

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
    const pad = 6.0;
    Offset at(DatedValue p) => Offset(
      span == 0
          ? size.width / 2
          : pad +
                (size.width - 2 * pad) *
                    (p.date.millisecondsSinceEpoch - t0) /
                    span,
      pad + (size.height - 2 * pad) * (1 - (p.value - lo) / (hi - lo)),
    );

    final path = Path()..moveTo(at(points.first).dx, at(points.first).dy);
    for (final p in points.skip(1)) {
      path.lineTo(at(p).dx, at(p).dy);
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
    if (grid || points.length == 1) {
      canvas.drawCircle(at(points.last), grid ? 4.5 : 3, Paint()..color = dot);
    }
    if (grid) {
      // Valor del último punto, arriba del punto (o abajo si no entra)
      final last = at(points.last);
      final tp = TextPainter(
        text: TextSpan(
          text: formatWeight(points.last.value),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: labelColor,
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
