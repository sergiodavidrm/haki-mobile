import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
import '../data/exercise_video.dart';
import '../../program/data/place_label.dart';
import '../../program/data/program_schedule.dart' show mappingsForWeek;
import '../../../core/router/app_router.dart';
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

    final WeightUnit unit =
        ref.watch(exerciseUnitOverridesProvider(dayId))[e.id] ??
        ref.watch(dayWeightUnitProvider(dayId));
    final local =
        ref.watch(localSetsProvider(assignmentId, dayId)).value ?? const {};
    final history = ref.watch(exerciseHistoryProvider(e.exerciseId));
    final place = placeOf(day.day, e);
    final items = historyItems(
      history: history.value,
      exercise: e,
      assignmentId: assignmentId,
      dayId: dayId,
      weekNumber: day.week.weekNumber,
      today: todaySets(e, local),
      now: DateTime.now(),
      place: place,
      sessionDate: day.day.completedAt,
    );
    // En 2+ lugares (2026-11-07): e1RM e historial solo del lugar de la
    // sesión (el viernes, los viernes); comparar días vive en Tu progreso.
    final several = inSeveralPlaces(day.week, e.exerciseId);
    final shown = several ? samePlaceItems(items, place) : items;
    String dayLabelOf(int dayNumber, {int? slot}) => placeDayLabel(
      dayNumber: dayNumber,
      weekdayNumber: day.program.startDate == null
          ? null
          : mappingsForWeek(
              day.program,
              day.week.weekNumber,
            ).where((m) => m.dayNumber == dayNumber).firstOrNull?.weekDay,
      slot: slot,
    );
    final repeatedToday =
        day.day.exercises.where((x) => x.exerciseId == e.exerciseId).length > 1;
    final placeLabel = several
        ? dayLabelOf(place.day, slot: repeatedToday ? place.slot : null)
        : null;
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
            if (shown.any((i) => bestE1rmKg(i.sets) != null)) ...[
              const SizedBox(height: 16),
              _E1rmCard(items: shown, unit: unit, placeLabel: placeLabel),
            ],
            const SizedBox(height: 20),
            Text(
              placeLabel == null
                  ? context.l10n.exerciseHistory
                  : context.l10n.exerciseHistoryOf(placeLabel),
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
              _HistoryList(
                items: shown,
                unit: unit,
                // Al terminar las de este lugar: "Ver todos los días", con el
                // día en cada tarjeta
                all: several ? items : null,
                dayOf: (i) => i.place == null || i.place!.day <= 0
                    ? null
                    : dayLabelOf(i.place!.day),
              ),
            if (several)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(
                    Routes.progressExercise(
                      e.exerciseId,
                      place: '${place.day}-${place.slot}',
                    ),
                  ),
                  style: TextButton.styleFrom(foregroundColor: c.gold),
                  child: Text('${context.l10n.exerciseSeeProgress} →'),
                ),
              ),
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

/// YouTube: miniatura que al tocarla reproduce ahí mismo (pantalla completa
/// con el botón del reproductor, girando el teléfono o deslizando hacia
/// arriba) + "Abrir en YouTube". Otro sitio: se abre afuera, como antes.
class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final id = youtubeIdOf(url);
    return id == null
        ? _ExternalVideoCard(url: url)
        : _YoutubeVideoCard(videoId: id, url: url);
  }
}

class _YoutubeVideoCard extends StatefulWidget {
  const _YoutubeVideoCard({required this.videoId, required this.url});

  final String videoId;
  final String url;

  @override
  State<_YoutubeVideoCard> createState() => _YoutubeVideoCardState();
}

class _YoutubeVideoCardState extends State<_YoutubeVideoCard> {
  YoutubePlayerController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // El webview recién se crea al tocar la miniatura (YoutubePlayerThumbnail)
    _controller ??= YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      params: YoutubePlayerParams(
        showFullscreenButton: true,
        strictRelatedVideos: true,
        showVideoAnnotations: false,
        interfaceLanguage: Localizations.localeOf(context).languageCode,
        captionLanguage: Localizations.localeOf(context).languageCode,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: context.l10n.exercisePlayTechnique,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: YoutubePlayerThumbnail(
              controller: _controller!,
              backgroundColor: c.surface,
              playIcon: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.gold,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 32,
                  color: c.onAccent,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _openExternally(context, widget.url),
            style: TextButton.styleFrom(foregroundColor: c.textMuted),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: Text(context.l10n.exerciseOpenYoutube),
          ),
        ),
      ],
    );
  }
}

Future<void> _openExternally(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  final ok =
      uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.trimOpenError)));
  }
}

class _ExternalVideoCard extends StatelessWidget {
  const _ExternalVideoCard({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: context.l10n.exercisePlayTechnique,
      child: HakiCard(
        padding: const EdgeInsets.symmetric(vertical: 28),
        onTap: () => _openExternally(context, url),
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
                  child: Text(
                    _open ? context.l10n.seeLess : context.l10n.seeMore,
                  ),
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
  const _E1rmCard({required this.items, required this.unit, this.placeLabel});

  /// Del más nuevo al más viejo.
  final List<HistoryItem> items;
  final WeightUnit unit;

  /// "Viernes" si el ejercicio está en 2+ lugares (solo ese lugar)
  final String? placeLabel;

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
                      placeLabel == null
                          ? context.l10n.exerciseE1rmEstimated
                          : context.l10n.exerciseE1rmOf(
                              placeLabel!.toUpperCase(),
                            ),
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
              semanticLabel: context.l10n.exerciseTrend(
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
                    context.l10n.exerciseInBlock(
                      '${formatDelta(inProgram.last - inProgram.first)} ${unit.label}',
                    ),
                  )
                else
                  const SizedBox(),
                if (today != null)
                  Text(
                    (today.past
                        ? context.l10n.exerciseVolumeThatDay
                        : context.l10n.exerciseVolumeToday)(
                      '${formatWeight(unit.fromKg(volumeKg(today.sets)))} ${unit.label}',
                    ),
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
  const _HistoryList({
    required this.items,
    required this.unit,
    this.all,
    this.dayOf,
  });

  final List<HistoryItem> items;
  final WeightUnit unit;

  /// Todas las veces (todos los días); null = [items] ya son todas
  final List<HistoryItem>? all;

  /// "Lunes" para el título de cada tarjeta al ver todos los días
  final String? Function(HistoryItem)? dayOf;

  @override
  State<_HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<_HistoryList> {
  static const _initial = 2;
  static const _step = 5;
  var _shown = _initial;
  var _allDays = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final items = _allDays ? widget.all! : widget.items;
    final rest = items.length - _shown;
    final canSeeAll =
        !_allDays && widget.all != null && widget.all!.length > items.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final i in items.take(_shown)) ...[
          _HistoryCard(
            item: i,
            unit: widget.unit,
            day: _allDays ? widget.dayOf?.call(i) : null,
          ),
          const SizedBox(height: 10),
        ],
        if (rest > 0)
          TextButton(
            onPressed: () => setState(() => _shown += _step),
            style: TextButton.styleFrom(foregroundColor: c.gold),
            child: Text(context.l10n.loadMore(rest)),
          )
        else if (canSeeAll)
          TextButton(
            onPressed: () => setState(() {
              _allDays = true;
              _shown = items.length + _step;
            }),
            style: TextButton.styleFrom(foregroundColor: c.gold),
            child: Text(context.l10n.exerciseSeeAllDays),
          ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, required this.unit, this.day});

  final HistoryItem item;
  final WeightUnit unit;

  /// "Lunes" al ver todos los días (va al final del título)
  final String? day;

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
            day == null ? item.title : '${item.title} · $day',
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
