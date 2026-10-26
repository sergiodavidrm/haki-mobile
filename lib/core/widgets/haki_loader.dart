import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/haki_colors.dart';
import '../theme/haki_logo_colors.dart';
import '../../l10n/l10n.dart';
import 'haki_logo.dart';

/// Indicador de carga ("Cargando"): el isotipo J2 con un arco dorado que gira
/// sobre un anillo gris (en lugar del anillo exterior), tres ondas que salen
/// del núcleo (dos doradas, una turquesa) y el núcleo con halo que late.
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
    final logo = HakiLogoColors.of(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _t,
        builder: (_, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _LoaderPainter(
            t: _t.value,
            track: c.border,
            arc: logo.gold,
            wave: c.goldBright,
            logo: logo,
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
    required this.arc,
    required this.wave,
    required this.logo,
  });

  /// 0..1 dentro del ciclo de 2.4 s.
  final double t;
  final Color track;
  final Color arc;
  final Color wave;
  final HakiLogoColors logo;

  @override
  void paint(Canvas canvas, Size size) {
    // Mismo encuadre que el mockup: viewBox -4..104 (el isotipo ocupa 100)
    final s = size.width / 108;
    final center = size.center(Offset.zero);

    // Ondas: salen del núcleo (r 16), escala .4 → 2.7 y se apagan;
    // desfasadas 1/3 del ciclo
    const waves = [0.0, 1 / 3, 2 / 3];
    for (var i = 0; i < waves.length; i++) {
      final p = (t - waves[i]) % 1;
      final eased = Curves.easeOut.transform(p);
      canvas.drawCircle(
        center,
        16 * s * (.4 + 2.3 * eased),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = (i == 2 ? logo.core : wave).withValues(alpha: .85 * (1 - eased)),
      );
    }

    // Anillo + arco que gira (1.1 s por vuelta ≈ 2.18 vueltas por ciclo)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * s;
    canvas.drawCircle(center, 48 * s, ringPaint..color = track);
    final turn = (t * 2400 / 1100) % 1;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 48 * s),
      2 * pi * turn - pi / 2,
      2 * pi * 72 / 302, // dasharray 72 sobre la circunferencia (2π·48)
      false,
      ringPaint
        ..color = arc
        ..strokeCap = StrokeCap.round,
    );

    // Isotipo (sin el anillo exterior) con el núcleo que late (1.2 s: dos
    // latidos por ciclo) y su halo
    final beat = (sin(t * 2 * pi * 2 - pi / 2) + 1) / 2;
    canvas.save();
    canvas.translate(4 * s, 4 * s);
    HakiMarkPainter(colors: logo, coreScale: 1 + .25 * beat, outerRing: false)
        .paint(canvas, Size.square(100 * s));
    canvas.restore();
    canvas.drawCircle(
      center,
      11 * s * (1 + .25 * beat),
      Paint()..color = logo.core.withValues(alpha: .22),
    );
  }

  @override
  bool shouldRepaint(_LoaderPainter old) => old.t != t;
}

/// Pantalla "Cargando tu semana…" (mientras se baja /auth/me y el programa).
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.title, this.subtitle});

  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const HakiLoader(),
        const SizedBox(height: 44),
        Text(
          title ?? context.l10n.loadingTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: c.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle ?? context.l10n.loadingSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: c.textMuted),
        ),
      ],
    );
  }
}
