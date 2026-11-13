import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../../core/widgets/haki_card.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../../profile/providers/profile_providers.dart';
import '../../program/providers/program_providers.dart';
import '../../share/providers/share_providers.dart';
import '../data/session_plan.dart';
import '../data/workout_prs.dart';
import '../providers/session_providers.dart';
import '../../../l10n/l10n.dart';
import '../../levels/data/level_dto.dart';
import '../../levels/providers/level_providers.dart';
import '../../levels/ui/level_widgets.dart';

// Resumen al finalizar el entreno (mockup "Entreno completado" del canvas Haki
// Mobile): duración, series, volumen, nuevos PR (tocar abre el Detalle de
// ejercicio) y la subida de videos. Del mockup quedan afuera hasta que haya
// backend: +XP, RPE de la sesión y nota al coach.
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
    final prs =
        ref.watch(workoutPrsOfProvider(assignmentId, dayId)).value ?? const [];
    final videos =
        ref.watch(localVideosProvider(assignmentId, dayId)).value ?? const {};

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
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
                  if (ref.watch(gamificationVisibleProvider)) ...[
                    const SizedBox(height: 12),
                    _XpCard(assignmentId: assignmentId, dayId: dayId),
                  ],
                  for (final pr in prs) ...[
                    const SizedBox(height: 12),
                    _PrCard(
                      pr: pr,
                      onTap: () => context.push(
                        Routes.exercise(assignmentId, dayId, pr.dayExerciseId),
                      ),
                    ),
                  ],
                  if (videos.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _VideosCard(
                      total: videos.length,
                      done: videos.values.where((d) => d).length,
                      coachName: ref.watch(authMeProvider).value?.coachName,
                    ),
                  ],
                ],
              ),
            ),
            if (ref.watch(shareWorkoutsEnabledProvider))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.push(Routes.share(assignmentId, dayId)),
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: Text(context.l10n.shareButton),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: FilledButton(
                onPressed: () {
                  // Recién acá: offline el refresh fallaría y dejaría el
                  // resumen sin datos.
                  ref.invalidate(programSectionsProvider);
                  ref.invalidate(recordsProvider);
                  context.go(Routes.home);
                },
                child: Text(context.l10n.commonDone),
              ),
            ),
          ],
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

/// "NUEVO PR · Jalón vertical · 163.8 lb e1RM · +4.9", en la unidad en que
/// cargó la serie.
class _PrCard extends StatelessWidget {
  const _PrCard({required this.pr, required this.onTap});

  final WorkoutPr pr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final u = pr.unit;
    final e1rm = formatWeight(u.fromKg(pr.e1RmKg));
    final diff = formatWeight(
      u.fromKg(pr.e1RmKg) - u.fromKg(pr.previousE1RmKg),
    );
    return Semantics(
      button: true,
      label: context.l10n.workoutPrSemantics(
        pr.exerciseName,
        '$e1rm ${u.label}',
      ),
      excludeSemantics: true,
      child: Material(
        color: c.goldSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: c.gold),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: c.goldBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.emoji_events_outlined,
                    size: 20,
                    color: c.goldBright,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.workoutNewPr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: c.goldBright,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pr.exerciseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: c.text,
                        ),
                      ),
                      Text(
                        '${formatWeight(pr.weight)} ${u.label} × ${pr.reps}',
                        style: TextStyle(fontSize: 12, color: c.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$e1rm ${u.label}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: c.goldBright,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      context.l10n.workoutPrDiff(diff),
                      style: TextStyle(fontSize: 11, color: c.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Videos del entreno en la cola: "Subiendo videos para X · 1 de 2" con barra,
/// o "Videos enviados a X" cuando terminaron.
class _VideosCard extends StatelessWidget {
  const _VideosCard({
    required this.total,
    required this.done,
    required this.coachName,
  });

  final int total;
  final int done;
  final String? coachName;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final finished = done >= total;
    final coach = coachName?.trim().split(' ').first ?? '';
    final title = finished
        ? (coach.isEmpty ? l.workoutVideosSent : l.workoutVideosSentTo(coach))
        : (coach.isEmpty
              ? l.workoutVideosUploading
              : l.workoutVideosUploadingFor(coach));
    return HakiCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                finished ? Icons.check_circle_outline : Icons.videocam_outlined,
                size: 18,
                color: c.turquoise,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
              ),
              Text(
                l.workoutVideosCount(done, total),
                style: TextStyle(fontSize: 13, color: c.textMuted),
              ),
            ],
          ),
          if (!finished) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : done / total,
                minHeight: 6,
                color: c.turquoise,
                backgroundColor: c.surfaceHigh,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.workoutVideosHint,
              style: TextStyle(fontSize: 12, height: 1.4, color: c.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// "+190 XP" del entreno con el desglose y la barra del nivel (canvas "Haki ·
/// Niveles y logros", App · Entreno completado). Si cambió de rango abre la
/// pantalla de festejo una vez. Sin red o mientras el entreno sube: aviso.
class _XpCard extends ConsumerStatefulWidget {
  const _XpCard({required this.assignmentId, required this.dayId});

  final String assignmentId;
  final String dayId;

  @override
  ConsumerState<_XpCard> createState() => _XpCardState();
}

class _XpCardState extends ConsumerState<_XpCard> {
  bool _celebrated = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final provider = dayXpProvider(widget.assignmentId, widget.dayId);
    ref.listen(provider, (_, next) {
      final xp = next.value;
      if (xp == null || _celebrated || !xp.rankUp || !xp.level.showLevels) return;
      _celebrated = true;
      context.push(Routes.newRank(xp.rankAfter, xp.levelAfter));
    });
    final xp = ref.watch(provider).value;
    if (xp != null && !xp.level.showLevels) return const SizedBox.shrink();

    if (xp == null || xp.pending) {
      return HakiCard(
        child: Row(
          children: [
            Icon(Icons.bolt, color: c.goldBright),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l.xpPending,
                style: TextStyle(fontSize: 13, color: c.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    final level = xp.level;
    return HakiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '+${xp.points} XP',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: c.goldBright),
              ),
              const SizedBox(width: 8),
              Text(l.xpThisWorkout, style: TextStyle(fontSize: 13, color: c.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in xp.items.where((i) => i.points > 0))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _label(context, item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: c.textSecondary),
                    ),
                  ),
                  Text(
                    '+${item.points}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.text),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Divider(height: 1, color: c.border),
          const SizedBox(height: 12),
          Row(
            children: [
              RankMedal(level.rank, size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    XpBar(progress: level.progress),
                    const SizedBox(height: 6),
                    Text(
                      xp.levelUp
                          ? l.xpLevelUp(level.level)
                          : l.xpToNext(level.levelXp, level.levelCost, level.levelCost - level.levelXp, level.level + 1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: xp.levelUp ? FontWeight.w700 : FontWeight.w400,
                        color: xp.levelUp ? c.goldBright : c.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _label(BuildContext context, XpItemDto i) {
    final l = context.l10n;
    return switch (i.kind) {
      'session' => i.points < 100 ? l.xpItemPartial : l.xpItemWorkout,
      'all_sets' => l.xpItemAllSets,
      'pr' => l.xpItemPr(i.detail ?? ''),
      'video' => l.xpItemVideo(i.detail ?? ''),
      'week' => l.xpItemWeek,
      'streak' => l.xpItemStreak,
      'program' => l.xpItemProgram,
      'badge' => l.xpItemBadge(badgeName(l, i.key)),
      'questionnaire' => l.xpItemQuestionnaire,
      'body_log' => l.xpItemBodyLog,
      _ => i.kind,
    };
  }
}
