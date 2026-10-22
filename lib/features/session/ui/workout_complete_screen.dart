import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../../core/widgets/haki_card.dart';
import '../../program/providers/program_providers.dart';
import '../data/session_plan.dart';
import '../providers/session_providers.dart';
import '../../../l10n/l10n.dart';

// Resumen al finalizar el entreno. Del mockup quedan afuera hasta que haya
// backend: +XP, nuevo PR, subida de videos, RPE de la sesión y nota al coach.
class WorkoutCompleteScreen extends ConsumerWidget {
  const WorkoutCompleteScreen({
    super.key,
    required this.assignmentId,
    required this.dayId,
  });

  final String assignmentId;
  final String dayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final day = ref.watch(sessionDayProvider(assignmentId, dayId)).value;
    final summary = ref.watch(workoutSummaryProvider(assignmentId, dayId));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 36, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.goldSurface,
                    border: Border.all(color: c.gold, width: 1.5),
                  ),
                  child: Icon(Icons.check, size: 36, color: c.goldBright),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.workoutCompleted,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: c.text,
                ),
              ),
              if (day != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${day.day.title} · ${context.l10n.weekN(day.week.weekNumber)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: c.textMuted),
                ),
              ],
              const SizedBox(height: 24),
              switch (summary) {
                AsyncData(:final value) => _Stats(summary: value),
                AsyncError() => Text(
                  context.l10n.summaryError,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.textMuted),
                ),
                _ => const SizedBox(
                  height: 76,
                  child: Center(child: CircularProgressIndicator()),
                ),
              },
              const Spacer(),
              FilledButton(
                onPressed: () {
                  // Recién acá: offline el refresh fallaría y dejaría el
                  // resumen sin datos.
                  ref.invalidate(programSectionsProvider);
                  context.go(Routes.home);
                },
                child: Text(context.l10n.commonDone),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.summary});

  final WorkoutSummary summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final unit = s.unit.label;
    final (volume, volumeUnit) = s.volume >= 10000
        ? (formatWeight(s.volume / 1000), 'k $unit')
        : (s.volume.round().toString(), unit);

    return Row(
      children: [
        Expanded(
          child: _Stat(
            label: context.l10n.restDuration,
            value: s.duration == null ? '—' : '${s.duration!.inMinutes}',
            suffix: s.duration == null ? null : ' min',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Stat(
            label: context.l10n.statSets,
            value: '${s.setsDone}',
            suffix: '/${s.setsTotal}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Stat(
            label: context.l10n.statVolume,
            value: s.volume == 0 ? '—' : volume,
            suffix: s.volume == 0 ? null : ' $volumeUnit',
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.suffix});

  final String label;
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return HakiCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: c.textMuted)),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: value,
              children: [
                if (suffix != null)
                  TextSpan(
                    text: suffix,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: c.textMuted,
                    ),
                  ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: c.text,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
