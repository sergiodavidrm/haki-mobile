import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/haki_colors.dart';

/// Indicador de carga del mockup ("Cargando"): arco dorado que gira sobre un
/// anillo gris, tres ondas que se expanden (dos doradas, una turquesa) y un
/// núcleo dorado que late.
class HakiLoader extends StatefulWidget {
  const HakiLoader({super.key, this.size = 128});

  final double size;

  @override
  State<HakiLoader> createState() => _HakiLoaderState();
}

class _HakiLoaderState extends State<HakiLoader>
    with SingleTickerProviderStateMixin {
  // Un solo reloj de 2.4 s (el ciclo de las ondas); giro y latido derivan de él
  late final _t = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _t,
        builder: (_, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _LoaderPainter(
            t: _t.value,
            track: c.border,
            gold: c.gold,
            goldLight: c.goldBright,
            turquoise: c.turquoise,
          ),
        ),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  _LoaderPainter({
    required this.t,
    required this.track,
    required this.gold,
    required this.goldLight,
    required this.turquoise,
  });

  /// 0..1 dentro del ciclo de 2.4 s.
  final double t;
  final Color track;
  final Color gold;
  final Color goldLight;
  final Color turquoise;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 128;
    final center = size.center(Offset.zero);

    // Ondas: arrancan en r=40 (inset 24 del mockup), escala .25 → 1.7 y se
    // apagan; desfasadas 1/3 del ciclo
    const waves = [0.0, 1 / 3, 2 / 3];
    for (var i = 0; i < waves.length; i++) {
      final p = (t - waves[i]) % 1;
      final eased = Curves.easeOut.transform(p);
      final scale = .25 + (1.7 - .25) * eased;
      canvas.drawCircle(
        center,
        40 * s * scale,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * s
          ..color = (i == 2 ? turquoise : goldLight).withValues(
            alpha: .85 * (1 - eased),
          ),
      );
    }

    // Anillo + arco que gira (1.1 s por vuelta ≈ 2.18 vueltas por ciclo)
    final ring = Rect.fromCircle(center: center, radius: 60 * s);
    canvas.drawCircle(
      center,
      60 * s,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * s
        ..color = track,
    );
    final turn = (t * 2400 / 1100) % 1;
    canvas.drawArc(
      ring,
      2 * pi * turn - pi / 2,
      2 * pi * 90 / 377, // dasharray 90 sobre la circunferencia (2π·60)
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * s
        ..strokeCap = StrokeCap.round
        ..color = gold,
    );

    // Núcleo que late (1.2 s: dos latidos por ciclo)
    final beat = (sin(t * 2 * pi * 2 - pi / 2) + 1) / 2;
    final r = 8 * s * (1 + .25 * beat);
    canvas.drawCircle(
      center,
      r + 9 * s,
      Paint()
        ..color = goldLight.withValues(alpha: .5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 9 * s),
    );
    canvas.drawCircle(
      center,
      r + 5 * s,
      Paint()..color = turquoise.withValues(alpha: .25),
    );
    canvas.drawCircle(center, r, Paint()..color = goldLight);
  }

  @override
  bool shouldRepaint(_LoaderPainter old) => old.t != t;
}

/// Pantalla "Cargando tu semana…" (mientras se baja /auth/me y el programa).
class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    this.title = 'Cargando tu semana…',
    this.subtitle = 'Sincronizando tu programa con tu coach',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const HakiLoader(),
        const SizedBox(height: 44),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: c.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: c.textMuted),
        ),
      ],
    );
  }
}
