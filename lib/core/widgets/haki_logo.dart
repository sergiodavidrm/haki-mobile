import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/haki_colors.dart';
import '../theme/haki_logo_colors.dart';

/// Isotipo de Haki (J2): anillos atravesados por una pesa, con el núcleo
/// turquesa. Misma geometría que el web (`app-haki-logo`) y
/// `branding/make_logo.py` (viewBox 100).
///
/// [pulse] = brillo suave y núcleo que late (3 s). [draw] = los anillos se
/// dibujan al aparecer, de adentro hacia afuera (splash).
class HakiLogoMark extends StatefulWidget {
  const HakiLogoMark({
    super.key,
    this.size = 52,
    this.pulse = true,
    this.draw = false,
  });

  final double size;
  final bool pulse;
  final bool draw;

  @override
  State<HakiLogoMark> createState() => _HakiLogoMarkState();
}

class _HakiLogoMarkState extends State<HakiLogoMark> with TickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  late final _draw = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
    value: widget.draw ? 0 : 1,
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulse) _pulse.repeat(reverse: true);
    if (widget.draw) _draw.forward();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _draw.dispose();
    super.dispose();
  }

  /// Avance de cada anillo (interior, medio, exterior), escalonados.
  static List<double> _ringsProgress(double t) => [
        for (final start in const [0.0, .17, .33])
          Curves.easeOut.transform(((t - start) / .67).clamp(0.0, 1.0)),
      ];

  @override
  Widget build(BuildContext context) {
    final colors = HakiLogoColors.of(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulse, _draw]),
        builder: (_, _) {
          final beat = widget.pulse ? Curves.easeInOut.transform(_pulse.value) : 0.0;
          return CustomPaint(
            size: Size.square(widget.size),
            painter: HakiMarkPainter(
              colors: colors,
              glow: widget.pulse ? beat : 0,
              coreScale: 1 + .3 * beat,
              rings: _ringsProgress(_draw.value),
            ),
          );
        },
      ),
    );
  }
}

/// Dibuja el isotipo en un cuadrado de [Size]. Lo usan [HakiLogoMark] y el
/// loader (sin el anillo exterior, que ahí es el arco que gira).
class HakiMarkPainter extends CustomPainter {
  HakiMarkPainter({
    required this.colors,
    this.glow = 0,
    this.coreScale = 1,
    this.rings = const [1, 1, 1],
    this.outerRing = true,
  });

  final HakiLogoColors colors;

  /// 0..1: brillo dorado suave detrás del núcleo.
  final double glow;
  final double coreScale;

  /// Cuánto de cada anillo está dibujado (interior, medio, exterior), 0..1.
  final List<double> rings;
  final bool outerRing;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 100;
    final center = size.center(Offset.zero);
    final bounds = Offset.zero & size;
    final clear = Paint()..blendMode = BlendMode.clear;
    RRect rrect(double x, double y, double w, double h, double r) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(x * u, y * u, w * u, h * u), Radius.circular(r * u));

    if (glow > 0) {
      canvas.drawCircle(
        center,
        12 * u,
        Paint()
          ..color = colors.gold.withValues(alpha: .25 * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * u),
      );
    }

    // Anillos en una capa propia, recortada alrededor de los discos y del
    // núcleo (se separan de la pesa sobre cualquier fondo)
    canvas.saveLayer(bounds, Paint());
    final stroke = max(2 * u, 1.0);
    void ring(double r, Color color, double alpha, double progress) {
      if (progress <= 0) return;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r * u),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = color.withValues(alpha: alpha),
      );
    }

    canvas.drawCircle(center, 16 * u, Paint()..color = colors.core.withValues(alpha: .12));
    ring(16, colors.core, .8, rings[0]);
    ring(28, colors.gold, .75, rings[1]);
    if (outerRing) ring(40, colors.gold, .55, rings[2]);
    for (final (x, y, w, h, r) in const [
      (6.5, 30.5, 13.0, 39.0, 4.5),
      (80.5, 30.5, 13.0, 39.0, 4.5),
      (18.0, 37.0, 8.0, 26.0, 3.0),
      (74.0, 37.0, 8.0, 26.0, 3.0),
    ]) {
      canvas.drawRRect(rrect(x, y, w, h, r), clear);
    }
    canvas.drawCircle(center, 9 * u, clear);
    canvas.restore();

    // La barra solo se recorta alrededor del núcleo
    canvas.saveLayer(bounds, Paint());
    canvas.drawRRect(rrect(2, 46, 96, 8, 4), Paint()..color = colors.bar);
    canvas.drawCircle(center, 9 * u, clear);
    canvas.restore();

    for (final (x, y, w, h, r, color) in [
      (8.0, 32.0, 10.0, 36.0, 3.0, colors.gold),
      (82.0, 32.0, 10.0, 36.0, 3.0, colors.gold),
      (19.0, 38.0, 6.0, 24.0, 2.0, colors.gold2),
      (75.0, 38.0, 6.0, 24.0, 2.0, colors.gold2),
      (26.0, 43.0, 3.0, 14.0, 1.0, colors.gold3),
      (71.0, 43.0, 3.0, 14.0, 1.0, colors.gold3),
    ]) {
      canvas.drawRRect(rrect(x, y, w, h, r), Paint()..color = color);
    }

    canvas.drawCircle(center, 6.5 * u * coreScale, Paint()..color = colors.core);
  }

  @override
  bool shouldRepaint(HakiMarkPainter old) =>
      old.glow != glow ||
      old.coreScale != coreScale ||
      old.colors != colors ||
      old.outerRing != outerRing ||
      !_sameRings(old.rings, rings);

  static bool _sameRings(List<double> a, List<double> b) =>
      a.length == b.length && Iterable.generate(a.length).every((i) => a[i] == b[i]);
}

/// Logo completo para login/splash: isotipo en recuadro + "haki" + "FITNESS COACHING".
class HakiLogo extends StatelessWidget {
  const HakiLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: c.border),
          ),
          alignment: Alignment.center,
          child: const HakiLogoMark(size: 60),
        ),
        const SizedBox(height: 16),
        Text('haki',
            style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                height: 1,
                color: c.text)),
        const SizedBox(height: 6),
        Text('FITNESS COACHING',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.3,
                color: c.turquoise)),
      ],
    );
  }
}
