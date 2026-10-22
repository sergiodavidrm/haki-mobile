import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/dates.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/haki_card.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../../chat/ui/feedback_links.dart';
import '../../session/data/session_plan.dart';
import '../../session/data/session_store.dart';
import '../../session/providers/session_providers.dart';
import '../../session/ui/set_row.dart';
import '../../session/ui/set_video_flow.dart';
import '../data/assignment_dtos.dart';
import '../data/program_schedule.dart';
import '../providers/program_providers.dart';
import '../../../l10n/l10n.dart';

// Sesión pasada: lo que se registró en un día completado. Las series son de
// solo lectura, pero se pueden subir videos (muchos los suben después del gym):
// misma cámara y cola que la Sesión. Falta reproducir los videos acá.
class PastSessionScreen extends ConsumerWidget {
  const PastSessionScreen({
    super.key,
    required this.assignmentId,
    required this.dayId,
  });

  final String assignmentId;
  final String dayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final program = ref.watch(programWithLocalProvider(assignmentId));
    final local =
        ref.watch(localSetsProvider(assignmentId, dayId)).value ?? const {};
    final videos =
        ref.watch(localVideosProvider(assignmentId, dayId)).value ?? const {};
    final fallbackUnit =
        ref.watch(authMeProvider).value?.preferredWeightUnit ?? WeightUnit.kg;

    final p = program.value;
    WeekDto? week;
    DayDto? day;
    for (final w in p?.weeks ?? const <WeekDto>[]) {
      for (final d in w.days) {
        if (d.id == dayId) (week, day) = (w, d);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: c.surfaceHigh)),
              ),
              child: BackHeader(
                title: day?.title ?? context.l10n.sessionTitle,
                subtitle: day == null ? null : _subtitle(p!, week!, day),
                titleSize: 20,
                trailing: day == null ? null : _StatusPill(day: day),
              ),
            ),
            Expanded(
              child: switch ((program, day)) {
                (_, final DayDto d) => ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    for (final g in groupSupersets(d.exercises))
                      for (final e in g.exercises)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _ExerciseCard(
                            exercise: e,
                            badge: g.badgeOf(e),
                            local: local,
                            videos: videos,
                            fallbackUnit: fallbackUnit,
                            onVideo: (n, saved, requested) => queueSetVideo(
                              context: context,
                              ref: ref,
                              assignmentId: assignmentId,
                              dayId: dayId,
                              dayExerciseId: e.id,
                              setNumber: n,
                              saved: saved,
                              requested: requested,
                            ),
                          ),
                        ),
                  ],
                ),
                (AsyncLoading(), _) => const Center(
                  child: CircularProgressIndicator(),
                ),
                _ => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    program.hasError
                        ? context.l10n.sessionLoadError
                        : context.l10n.sessionDayGone,
                    style: TextStyle(color: c.textMuted),
                  ),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  /// "Semana 2 · Vie 25 sep · 62 min"
  static String _subtitle(AssignmentDetailDto p, WeekDto w, DayDto d) {
    final date = d.completedAt != null
        ? dateOnly(d.completedAt!)
        : dateOfDay(p, w.weekNumber, d.dayNumber);
    final duration = durationOf(d);
    return [
      l10n.weekN(w.weekNumber),
      if (date != null) capitalize(formatShortDate(date)),
      if (duration != null) l10n.minutesShort(duration.inMinutes),
    ].join(' · ');
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.day});

  final DayDto day;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = day.sessionStatus == SessionStatus.completed;
    final fg = done ? c.turquoise : c.goldBright;
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: done ? c.turquoiseSurface : c.goldSurface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (done) ...[
            Icon(Icons.check_rounded, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            done ? context.l10n.sessionCompleted : context.l10n.programInProgress,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.badge,
    required this.local,
    required this.videos,
    required this.fallbackUnit,
    required this.onVideo,
  });

  final DayExerciseDto exercise;
  final String? badge;
  final Map<String, LocalSetEntry> local;
  final Map<String, bool> videos;
  final WeightUnit fallbackUnit;
  final void Function(int setNumber, SavedSet? saved, bool requested) onVideo;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final e = exercise;
    final count = setCountOf(e);
    final saved = [
      for (var n = 1; n <= count; n++) savedSetFor(e, n, local, videos),
    ];
    // Se muestra en la unidad en que la cargó (la de su primera serie)
    final unit = saved.nonNulls.firstOrNull?.unit ?? fallbackUnit;
    double? inUnit(SavedSet? s) => s?.weight == null
        ? null
        : (s!.unit == unit ? s.weight : unit.fromKg(s.unit.toKg(s.weight!)));
    final top = saved
        .map(inUnit)
        .nonNulls
        .fold<double?>(null, (a, b) => a == null || b > a ? b : a);
    final note = e.athleteNote?.trim();

    return HakiCard(
      radius: 22,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: c.turquoiseSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: c.turquoise,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  e.exerciseName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
              ),
              if (top != null)
                Text(
                  '${formatWeight(top)} ${unit.label}',
                  style: TextStyle(fontSize: 12, color: c.textMuted),
                ),
            ],
          ),
          if (e.streamMessageId != null)
            FeedbackLink(
              messageId: e.streamMessageId!,
              margin: const EdgeInsets.only(top: 10),
            ),
          const SizedBox(height: 10),
          if (saved.every((s) => s == null))
            Text(
              context.l10n.sessionNoSets,
              style: TextStyle(fontSize: 13, color: c.textMuted),
            )
          else ...[
            SetTableHeader(cols: SetCols.normal, unit: unit),
            for (var n = 1; n <= count; n++)
              _PastSetRow(
                setNumber: n,
                target: e.targetSets.where((t) => t.setNumber == n).firstOrNull,
                saved: saved[n - 1],
                weight: inUnit(saved[n - 1]),
                unit: unit,
                onVideo: (requested) => onVideo(n, saved[n - 1], requested),
              ),
          ],
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: c.surfaceHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: c.textSecondary,
                  ),
                  children: [
                    TextSpan(
                      text: '${context.l10n.sessionYourNote}: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: c.textMuted,
                      ),
                    ),
                    TextSpan(text: note),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Fila de solo lectura con las mismas columnas que la Sesión.
class _PastSetRow extends StatelessWidget {
  const _PastSetRow({
    required this.setNumber,
    required this.target,
    required this.saved,
    required this.weight,
    required this.unit,
    required this.onVideo,
  });

  final int setNumber;
  final TargetSetDto? target;
  final SavedSet? saved;

  /// Peso ya convertido a [unit].
  final double? weight;
  final WeightUnit unit;

  /// [requested] = el coach pidió video de esta serie.
  final void Function(bool requested) onVideo;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const cols = SetCols.normal;
    final t = target;
    final objective = [
      if (t?.weightKg != null) formatWeight(unit.fromKg(t!.weightKg!)),
      if (t?.reps != null) '${t!.reps}',
    ].join(' × ');

    Widget value(double width, String? text) => SizedBox(
      width: width,
      child: Text(
        text ?? '–',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: text == null ? FontWeight.w400 : FontWeight.w600,
          color: text == null ? c.textMuted : c.textSecondary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: SetCols.inset),
      child: Row(
        children: [
          SizedBox(
            width: cols.set,
            child: Text(
              '$setNumber',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textMuted),
            ),
          ),
          const SizedBox(width: SetCols.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  objective.isEmpty ? '—' : objective,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: c.turquoiseMuted,
                  ),
                ),
                if (t?.rir != null)
                  Text(
                    'RIR ${t!.rir}',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.25,
                      color: c.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: SetCols.gap),
          value(cols.weight, weight == null ? null : formatWeight(weight!)),
          const SizedBox(width: SetCols.gap),
          value(cols.reps, saved?.reps?.toString()),
          const SizedBox(width: SetCols.gap),
          value(cols.rir, saved?.rir?.toString()),
          const SizedBox(width: SetCols.gap),
          SizedBox(
            width: cols.action,
            // Solo series registradas: el video se cuelga de su set-log
            child: saved == null
                ? null
                : Center(
                    child: SetCameraButton(
                      setNumber: setNumber,
                      requested: t?.requestVideo ?? false,
                      sent: saved!.hasVideo,
                      uploading: saved!.videoUploading,
                      onTap: () => onVideo(t?.requestVideo ?? false),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
