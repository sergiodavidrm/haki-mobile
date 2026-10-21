import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/haki_colors.dart';
import 'haki_logo.dart';

/// Splash del mockup: isotipo grande con brillo que late, "haki" + "FITNESS
/// COACHING" subiendo y el slogan abajo (con un poco de demora). El nativo
/// (Android) es solo el fondo obsidiana, así no hay salto al pasar a este.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // 0.9 s de subida del logo + 0.35 s de demora del slogan
  late final _rise = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  );

  @override
  void initState() {
    super.initState();
    // Recién cuando se ve (en debug el primer cuadro tarda segundos)
    WidgetsBinding.instance.waitUntilFirstFrameRasterized.then((_) {
      if (mounted) _rise.forward();
    });
  }

  @override
  void dispose() {
    _rise.dispose();
    super.dispose();
  }

  Widget _rising(Widget child, double from) {
    final anim = CurvedAnimation(
      parent: _rise,
      curve: Interval(from, from + 0.72, curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const HakiLogoMark(size: 136),
                const SizedBox(height: 28),
                _rising(
                  Column(
                    children: [
                      Text(
                        'haki',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          height: 1,
                          color: c.text,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'FITNESS COACHING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.6,
                          color: c.turquoise,
                        ),
                      ),
                    ],
                  ),
                  0,
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 72,
            child: _rising(
              Text(
                'Voluntad sobre límites.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: c.textMuted,
                ),
              ),
              0.28,
            ),
          ),
        ],
      ),
    );
  }
}

/// Muestra el splash arriba de la app al abrirla y lo desvanece cuando pasó
/// [minDuration] desde que el primer cuadro llegó a la pantalla (la app ya
/// arrancó abajo: login o Cargando → Hoy).
class SplashOverlay extends StatefulWidget {
  const SplashOverlay({
    super.key,
    required this.child,
    this.minDuration = const Duration(milliseconds: 1600),
  });

  final Widget child;
  final Duration minDuration;

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay> {
  var _visible = true;
  var _gone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.waitUntilFirstFrameRasterized
        .then((_) => Future<void>.delayed(widget.minDuration))
        .then((_) {
          if (mounted) setState(() => _visible = false);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_gone)
          IgnorePointer(
            ignoring: !_visible,
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: const Duration(milliseconds: 350),
              onEnd: () => setState(() => _gone = true),
              // Siempre oscuro: es la marca y empalma con el splash nativo
              child: Theme(
                data: buildAppTheme(HakiColors.obsidian),
                child: const SplashScreen(),
              ),
            ),
          ),
      ],
    );
  }
}
