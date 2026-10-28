import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/pill_chip.dart';
import '../../body/data/body_measures.dart';
import '../../body/ui/body_widgets.dart';
import '../../chat/ui/feedback_links.dart';
import '../../session/providers/session_providers.dart';
import '../data/exercise_stats.dart';
import '../providers/exercise_providers.dart';
import '../../../l10n/l10n.dart';

// Detalle de ejercicio (desde el nombre en la Sesión): video técnico, cómo se
// hace, nota del coach, e1RM con tendencia y PR, e historial de todas las veces
// que lo hizo. Pesos en la unidad del ejercicio en la Sesión. Del mockup falta
// el feedback del coach (hilo de Stream, con el Chat).
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.assignmentId,
    required this.dayId,
    required this.dayExerciseId,
  });

  final String assignmentId;
  final String dayId;

  /// BlockDayExerciseId.
  final String dayExerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final day = ref.watch(sessionDayProvider(assignmentId, dayId)).value;
    final e = day?.day.exercises
        .where((x) => x.id == dayExerciseId)
        .firstOrNull;

    if (day == null || e == null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackHeader(title: context.l10n.exerciseTitle, titleSize: 22),
                const SizedBox(height: 16),
                if (day != null)
                  Text(
                    context.l10n.exerciseGone,
                    style: TextStyle(color: c.textMuted),
                  )
                else
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      );
    }

    final WeightUnit unit = ref.watch(dayWeightUnitProvider(dayId));
    final local =
        ref.watch(localSetsProvider(assignmentId, dayId)).value ?? const {};
    final history = ref.watch(exerciseHistoryProvider(e.exerciseId));
    final items = historyItems(
      history: history.value,
      exercise: e,
      assignmentId: assignmentId,
      dayId: dayId,
      weekNumber: day.week.weekNumber,
      today: todaySets(e, local),
      now: DateTime.now(),
    );
    final video = e.coachVideoUrl ?? e.techniqueVideoUrl;
    // El feedback más reciente (mockup: arriba de todo)
    final withFeedback = items
        .where((i) => i.streamMessageId != null)
        .firstOrNull;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            BackHeader(title: e.exerciseName, titleSize: 22),
            if (withFeedback != null) ...[
              const SizedBox(height: 12),
              FeedbackLink(
                messageId: withFeedback.streamMessageId!,
                title: context.l10n.exerciseVideoFeedback(withFeedback.title),
              ),
            ],
            if (video != null) ...[
              const SizedBox(height: 16),
              _VideoCard(url: video),
            ],
            if (e.description?.trim().isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              _HowTo(text: e.description!.trim()),
            ],
            if (e.coachNote?.trim().isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              _CoachNoteCard(note: e.coachNote!.trim()),
            ],
            if (items.any((i) => bestE1rmKg(i.sets) != null)) ...[
              const SizedBox(height: 16),
              _E1rmCard(items: items, unit: unit),
            ],
            const SizedBox(height: 20),
            Text(
              context.l10n.exerciseHistory,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              Text(
                history.isLoading
                    ? context.l10n.commonLoading
                    : context.l10n.exerciseNeverDone,
                style: TextStyle(fontSize: 13, color: c.textMuted),
              )
            else
              _HistoryList(items: items, unit: unit),
            if (history.hasError)
              Text(
                context.l10n.exerciseOfflineHistory,
                style: TextStyle(fontSize: 12, color: c.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: context.l10n.exercisePlayTechnique,
      child: HakiCard(
        padding: const EdgeInsets.symmetric(vertical: 28),
        onTap: () async {
          final uri = Uri.tryParse(url);
          final ok =
              uri != null &&
              await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!ok && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.trimOpenError)),
            );
          }
        },
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.gold),
              child: Icon(
                Icons.play_arrow_rounded,
                size: 32,
                color: c.onAccent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              context.l10n.exerciseTechniqueVideo,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowTo extends StatefulWidget {
  const _HowTo({required this.text});

  final String text;

  @override
  State<_HowTo> createState() => _HowToState();
}

class _HowToState extends State<_HowTo> {
  var _open = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = TextStyle(fontSize: 14, height: 1.55, color: c.textSecondary);
    return HakiCard(
      child: LayoutBuilder(
        builder: (context, box) {
          // "Ver más" solo si el texto pasa de 3 líneas
          final tp = TextPainter(
            text: TextSpan(text: widget.text, style: style),
            maxLines: 3,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: box.maxWidth);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.exerciseHowTo,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.text,
                style: style,
                maxLines: _open ? null : 3,
                overflow: _open ? null : TextOverflow.ellipsis,
              ),
              if (tp.didExceedMaxLines)
                TextButton(
                  onPressed: () => setState(() => _open = !_open),
                  style: TextButton.styleFrom(
                    foregroundColor: c.turquoise,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text(_open ? context.l10n.seeLess : context.l10n.seeMore),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CoachNoteCard extends StatelessWidget {
  const _CoachNoteCard({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return HakiCard(
      tone: HakiCardTone.gold,
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.exerciseCoachNote,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: c.goldBright,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: TextStyle(fontSize: 14, height: 1.5, color: c.text),
          ),
        ],
      ),
    );
  }
}

class _E1rmCard extends StatelessWidget {
  const _E1rmCard({required this.items, required this.unit});

  /// Del más nuevo al más viejo.
  final List<HistoryItem> items;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final points = <DatedValue>[
      for (final i in items.reversed)
        if (bestE1rmKg(i.sets) case final e?)
          (date: i.date, value: unit.fromKg(e)),
    ];
    final latest = points.last.value;
    final pr = isNewPr([for (final i in items) i.sets]);

    // Cambio dentro de este programa (primera vez vs. la más reciente)
    final inProgram = [
      for (final i in items.reversed)
        if (i.inThisProgram)
          if (bestE1rmKg(i.sets) case final e?) unit.fromKg(e),
    ];
    final today = items.where((i) => i.isToday).firstOrNull;

    return HakiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.exerciseE1rmEstimated,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: c.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: formatWeight(latest)),
                          TextSpan(
                            text: ' ${unit.label}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: c.textMuted,
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                      ),
                    ),
                  ],
                ),
              ),
              if (pr)
                PillChip(
                  context.l10n.exerciseNewPr,
                  tone: PillTone.gold,
                  icon: Icons.emoji_events_outlined,
                ),
            ],
          ),
          if (points.length >= 2) ...[
            const SizedBox(height: 10),
            BodyLineChart(
              points: points,
              height: 72,
              semanticLabel:
                  context.l10n.exerciseTrend(
                    formatWeight(points.first.value),
                    '${formatWeight(latest)} ${unit.label}',
                    points.length,
                  ),
            ),
          ],
          const SizedBox(height: 10),
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 12, color: c.textMuted),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (inProgram.length >= 2)
                  Text(
                    context.l10n.exerciseInBlock('${formatDelta(inProgram.last - inProgram.first)} ${unit.label}'),
                  )
                else
                  const SizedBox(),
                if (today != null)
                  Text(
                    context.l10n.exerciseVolumeToday('${formatWeight(unit.fromKg(volumeKg(today.sets)))} ${unit.label}'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Arranca con las 2 más nuevas (hoy y la última vez, que es lo que se mira
/// para decidir la carga) y "Cargar más" suma de a 5.
class _HistoryList extends StatefulWidget {
  const _HistoryList({required this.items, required this.unit});

  final List<HistoryItem> items;
  final WeightUnit unit;

  @override
  State<_HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<_HistoryList> {
  static const _initial = 2;
  static const _step = 5;
  var _shown = _initial;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final items = widget.items;
    final rest = items.length - _shown;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final i in items.take(_shown)) ...[
          _HistoryCard(item: i, unit: widget.unit),
          const SizedBox(height: 10),
        ],
        if (rest > 0)
          TextButton(
            onPressed: () => setState(() => _shown += _step),
            style: TextButton.styleFrom(foregroundColor: c.gold),
            child: Text(context.l10n.loadMore(rest)),
          ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, required this.unit});

  final HistoryItem item;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.isToday ? c.gold : c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            item.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in item.sets)
                Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.surfaceHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    setChip(s, unit),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
            ],
          ),
          if (item.streamMessageId != null) ...[
            const SizedBox(height: 8),
            FeedbackLink(
              messageId: item.streamMessageId!,
              compact: true,
              videoCount: item.videoCount,
            ),
          ],
        ],
      ),
    );
  }
}
