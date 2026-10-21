import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../providers/rest_timer.dart';

/// 90 → "1:30"
String formatClock(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// Reconstruye cada segundo mientras [active]; el tiempo se calcula desde
/// timestamps, así que no acumula error.
class TickBuilder extends StatefulWidget {
  const TickBuilder({super.key, required this.active, required this.builder});

  final bool active;
  final Widget Function(BuildContext context, DateTime now) builder;

  @override
  State<TickBuilder> createState() => _TickBuilderState();
}

class _TickBuilderState extends State<TickBuilder> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(TickBuilder old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) _sync();
  }

  void _sync() {
    _timer?.cancel();
    _timer = widget.active
        ? Timer.periodic(
            const Duration(milliseconds: 250),
            (_) => setState(() {}),
          )
        : null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, DateTime.now());
}

/// Botón redondo del header de la Sesión que abre el timer.
class RestTimerButton extends StatelessWidget {
  const RestTimerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surfaceHigh,
      shape: CircleBorder(side: BorderSide(color: c.border)),
      child: IconButton(
        tooltip: 'Timer de descanso',
        onPressed: () => context.push(Routes.rest),
        icon: Icon(Icons.timer_outlined, color: c.goldBright, size: 22),
      ),
    );
  }
}

/// Barra flotante abajo de la Sesión mientras hay un descanso activo.
class RestTimerBar extends ConsumerWidget {
  const RestTimerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final t = ref.watch(restTimerProvider);
    if (!t.active) return const SizedBox.shrink();
    final timer = ref.read(restTimerProvider.notifier);
    final next = t.info?.next;

    return TickBuilder(
      active: t.running,
      builder: (context, now) {
        final left = t.leftAt(now);
        final done = t.doneAt(now);
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: c.surfaceHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.goldBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .5),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: t.totalSeconds == 0 ? 0 : 1 - left / t.totalSeconds,
                minHeight: 3,
                color: c.goldBright,
                backgroundColor: c.border,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: 'Abrir timer de descanso',
                        child: InkWell(
                          onTap: () => context.push(Routes.rest),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 20,
                                color: c.goldBright,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                done ? '¡A darle!' : formatClock(left),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: done ? c.goldBright : c.text,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (next != null)
                                Expanded(
                                  child: Text(
                                    'Luego: ${next.badge ?? next.exerciseName} · serie ${next.setNumber}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: c.textMuted,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _BarButton(
                      tooltip: 'Reiniciar descanso',
                      icon: Icons.replay,
                      onPressed: timer.restart,
                    ),
                    const SizedBox(width: 8),
                    _BarButton(
                      tooltip: t.running && !done
                          ? 'Pausar descanso'
                          : 'Seguir descanso',
                      icon: t.running && !done ? Icons.pause : Icons.play_arrow,
                      primary: true,
                      onPressed: timer.toggle,
                    ),
                    const SizedBox(width: 8),
                    _BarButton(
                      tooltip: 'Cerrar timer',
                      icon: Icons.close,
                      onPressed: timer.dismiss,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        backgroundColor: primary ? c.gold : c.border,
        foregroundColor: primary ? c.onAccent : c.text,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 20),
    );
  }
}

/// Anillo de progreso del descanso (se vacía a medida que pasa el tiempo).
class RestRing extends StatelessWidget {
  const RestRing({
    super.key,
    required this.fraction,
    required this.child,
    this.size = 264,
  });

  /// 1 = lleno (recién arrancado), 0 = terminado.
  final double fraction;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: fraction.clamp(0, 1)),
        duration: const Duration(milliseconds: 300),
        builder: (_, value, child) => CustomPaint(
          painter: _RingPainter(
            fraction: value,
            track: c.surfaceHigh,
            color: c.turquoise,
          ),
          child: child,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.track,
    required this.color,
  });

  final double fraction;
  final Color track;
  final Color color;

  static const _stroke = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arc = rect.deflate(_stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;
    canvas.drawCircle(rect.center, arc.width / 2, paint..color = track);
    if (fraction <= 0) return;
    canvas.drawArc(
      arc,
      -1.5707963267948966, // arriba
      6.283185307179586 * fraction,
      false,
      paint
        ..color = color
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.track != track || old.color != color;
}
