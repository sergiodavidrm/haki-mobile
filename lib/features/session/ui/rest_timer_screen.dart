import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/section_label.dart';
import '../providers/rest_timer.dart';
import 'rest_timer_widgets.dart';

/// Timer de descanso a pantalla completa. Bajar (chevron) vuelve a la Sesión
/// y el timer sigue corriendo en la barra flotante.
class RestTimerScreen extends ConsumerWidget {
  const RestTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final t = ref.watch(restTimerProvider);
    final timer = ref.read(restTimerProvider.notifier);
    final info = t.info;

    return Scaffold(
      body: SafeArea(
        child: TickBuilder(
          active: t.running,
          builder: (context, now) {
            final left = t.leftAt(now);
            final done = t.doneAt(now);
            final toggleLabel = done
                ? 'Otra vez'
                : t.running
                ? 'Pausar'
                : t.paused
                ? 'Seguir'
                : 'Iniciar';

            // Pantallas bajas: scrollea en vez de desbordar
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Minimizar timer',
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.expand_more, size: 26),
                            ),
                            const Expanded(
                              child: Center(child: SectionLabel('Descanso')),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        if (info != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            info.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: c.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            info.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: c.textMuted),
                          ),
                        ],
                        const SizedBox(height: 20),
                        RestRing(
                          fraction: t.totalSeconds == 0
                              ? 0
                              : left / t.totalSeconds,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Semantics(
                                liveRegion: done,
                                child: Text(
                                  formatClock(left),
                                  style: TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                    color: c.text,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (done)
                                Text(
                                  '¡A darle!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: c.goldBright,
                                  ),
                                )
                              else if (t.paused)
                                SectionLabel('En pausa', color: c.goldBright)
                              else
                                Text(
                                  'de ${formatClock(t.totalSeconds)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: c.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Duración',
                              style: TextStyle(
                                fontSize: 12,
                                color: c.textMuted,
                              ),
                            ),
                            Text(
                              'Se recuerda la última que usaste',
                              style: TextStyle(
                                fontSize: 12,
                                color: c.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (final (i, sec) in restPresets.indexed) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                child: _Preset(
                                  seconds: sec,
                                  selected: sec == t.totalSeconds,
                                  onTap: () => timer.setDuration(sec),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _BigButton(
                                label: '−15 s',
                                semantics: 'Restar 15 segundos',
                                onPressed: () => timer.adjust(-15),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _BigButton(
                                label: toggleLabel,
                                primary: true,
                                // Iniciar cierra la pantalla: el descanso
                                // sigue en la barra de la Sesión
                                onPressed: t.active
                                    ? timer.toggle
                                    : () {
                                        timer.start();
                                        context.pop();
                                      },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _BigButton(
                                label: '+15 s',
                                semantics: 'Sumar 15 segundos',
                                onPressed: () => timer.adjust(15),
                              ),
                            ),
                          ],
                        ),
                        if (info?.next case final next?) ...[
                          const SizedBox(height: 18),
                          _NextCard(next: next),
                        ],
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: t.active ? timer.restart : null,
                              style: TextButton.styleFrom(
                                foregroundColor: c.textMuted,
                              ),
                              child: const Text('Reiniciar'),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                timer.dismiss();
                                context.pop();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: c.textSecondary,
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              iconAlignment: IconAlignment.end,
                              icon: const Icon(Icons.skip_next, size: 20),
                              label: const Text('Saltar descanso'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Preset extends StatelessWidget {
  const _Preset({
    required this.seconds,
    required this.selected,
    required this.onTap,
  });

  final int seconds;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: 'Descanso de ${formatClock(seconds)}',
      excludeSemantics: true,
      child: Material(
        color: selected ? c.goldSurface : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: selected ? c.gold : c.border),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Center(
              child: Text(
                formatClock(seconds),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? c.goldBright : c.textSecondary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.semantics,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final String? semantics;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: semantics,
      excludeSemantics: semantics != null,
      button: true,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: primary ? c.gold : c.surfaceHigh,
          foregroundColor: primary ? c.onAccent : c.text,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _NextCard extends StatelessWidget {
  const _NextCard({required this.next});

  final NextSetInfo next;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return HakiCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          if (next.badge != null) ...[
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.turquoiseSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                next.badge!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: c.turquoise,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Siguiente'),
                const SizedBox(height: 2),
                Text(
                  next.exerciseName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    'Serie ${next.setNumber}',
                    if (next.target != null) next.target!,
                  ].join(' · '),
                  style: TextStyle(fontSize: 13, color: c.turquoise),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
