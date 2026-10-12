import 'package:flutter/material.dart';

import '../theme/haki_colors.dart';

/// Isotipo de Haki: ondas concéntricas doradas con centro turquesa (el mismo SVG
/// del sidebar/login del web, viewBox 36×36). [pulse] = brillo que late (3 s).
class HakiLogoMark extends StatefulWidget {
  const HakiLogoMark({super.key, this.size = 52, this.pulse = true});

  final double size;
  final bool pulse;

  @override
  State<HakiLogoMark> createState() => _HakiLogoMarkState();
}

class _HakiLogoMarkState extends State<HakiLogoMark> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulse) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _WavesPainter(
            gold: c.gold,
            turquoise: c.turquoise,
            glow: widget.pulse ? Curves.easeInOut.transform(_controller.value) : 0.5,
          ),
        ),
      ),
    );
  }
}

class _WavesPainter extends CustomPainter {
  _WavesPainter({required this.gold, required this.turquoise, required this.glow});

  final Color gold;
  final Color turquoise;
  final double glow; // 0..1

  // (radio, grosor, opacidad) en unidades del viewBox de 36
  static const _rings = [(7.5, 1.2, .55), (13.0, 1.0, .25), (17.5, .8, .10)];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 36;
    final center = size.center(Offset.zero);

    // Brillo detrás del núcleo y del primer anillo
    final glowPaint = Paint()
      ..color = gold.withValues(alpha: .35 + .45 * glow)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, (3 + 5 * glow) * s);
    canvas.drawCircle(center, 3.5 * s, glowPaint);

    for (final (r, w, o) in _rings) {
      canvas.drawCircle(
        center,
        r * s,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * s
          ..color = gold.withValues(alpha: o),
      );
    }

    canvas.drawCircle(center, 2.8 * s, Paint()..color = gold);
    canvas.drawCircle(center, 2.8 * s, Paint()..color = turquoise.withValues(alpha: .55));
  }

  @override
  bool shouldRepaint(_WavesPainter old) =>
      old.glow != glow || old.gold != gold || old.turquoise != turquoise;
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
          child: const HakiLogoMark(size: 52),
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
