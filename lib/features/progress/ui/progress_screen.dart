import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../l10n/l10n.dart';
import '../../body/providers/body_providers.dart';
import '../../profile/providers/profile_providers.dart';
import '../../program/data/place_label.dart';
import '../../program/data/program_schedule.dart' show dateOnly;
import '../data/progress_report.dart';
import '../providers/progress_providers.dart';

// Tu progreso (mockup "App · Tu progreso"): constancia, ejercicios (con
// ojito para ocultar), récords y peso del período elegido. Lectura positiva:
// sin "estancado" ni el RIR comparado (eso es del coach, tab Rendimiento).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedProgressPeriodProvider);
    final report = ref.watch(progressReportProvider(period));
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(progressReportProvider(period).future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              BackHeader(title: context.l10n.progressTitle, titleSize: 22),
              const SizedBox(height: 12),
              const ProgressPeriodPicker(),
              const SizedBox(height: 14),
              ...switch (report) {
                AsyncData(:final value) => _content(context, ref, value),
                AsyncError() => [_Message(context.l10n.progressError)],
                _ => [
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              },
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, WidgetRef ref, ProgressReport r) {
    if (r.columns.isEmpty) return [_Message(context.l10n.progressEmpty)];
    return [
      _RangeCard(report: r),
      const SizedBox(height: 14),
      _ConstancyCard(report: r),
      const SizedBox(height: 14),
      _ExercisesCard(report: r),
      const SizedBox(height: 14),
      _RecordsCard(report: r),
      const SizedBox(height: 14),
      _WeightCard(report: r),
    ];
  }
}

/// Botón con el período elegido que despliega la lista (sin scroll horizontal).
class ProgressPeriodPicker extends ConsumerStatefulWidget {
  const ProgressPeriodPicker({super.key});

  @override
  ConsumerState<ProgressPeriodPicker> createState() =>
      _ProgressPeriodPickerState();
}

class _ProgressPeriodPickerState extends ConsumerState<ProgressPeriodPicker> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = ref.watch(selectedProgressPeriodProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: c.border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _open = !_open),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: c.goldBright,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      periodLabel(context, selected),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _open ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: c.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_open) ...[
          const SizedBox(height: 6),
          HakiCard(
            radius: 14,
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                for (final p in ProgressPeriod.values)
                  _PeriodOption(
                    label: periodLabel(context, p),
                    selected: p == selected,
                    onTap: () {
                      ref.read(selectedProgressPeriodProvider.notifier).set(p);
                      setState(() => _open = false);
                    },
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

String periodLabel(BuildContext context, ProgressPeriod p) => switch (p) {
  ProgressPeriod.block => context.l10n.progressPeriodBlock,
  ProgressPeriod.previous => context.l10n.progressPeriodPrevious,
  ProgressPeriod.weeks4 => context.l10n.progressPeriodWeeks(4),
  ProgressPeriod.weeks8 => context.l10n.progressPeriodWeeks(8),
};

class _PeriodOption extends StatelessWidget {
  const _PeriodOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? c.goldSurface : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: c.text,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check, size: 18, color: c.goldBright),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "SEMANA 4 DE 6 · Torso · Pierna" / "ÚLTIMAS 8 SEMANAS · 14 sep – hoy"
class _RangeCard extends StatelessWidget {
  const _RangeCard({required this.report});

  final ProgressReport report;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = report.program;
    final ended = p != null && p.status == 'completed';
    final kicker = report.isRange
        ? context.l10n.progressKickerRange(report.columns.length)
        : ended && p.endDate != null
        ? context.l10n.progressKickerEnded(formatDayMonth(p.endDate!))
        : p?.currentWeek != null
        ? context.l10n.progressKickerWeek(p!.currentWeek!, p.totalWeeks)
        : context.l10n.progressPeriodBlock;
    final title = report.isRange
        ? '${formatDayMonth(report.from)} – ${context.l10n.commonToday.toLowerCase()}'
        : p?.name ?? '';
    final note = report.isRange
        ? report.programNames.join(' · ')
        : ended
        ? context.l10n.progressNoteEnded(report.columns.length)
        : context.l10n.progressNoteBlock;
    // Tema v2: card normal (antes caja dorada pálida)
    return HakiCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kicker.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: c.goldBright,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(note, style: TextStyle(fontSize: 12, color: c.textMuted)),
          ],
        ],
      ),
    );
  }
}

class _ConstancyCard extends ConsumerWidget {
  const _ConstancyCard({required this.report});

  final ProgressReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final streak = ref.watch(streakProvider).value;
    return HakiCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(context.l10n.progressConstancy),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.due == 0
                          ? '—'
                          : context.l10n.progressAdherencePct(
                              (100 * report.done / report.due).round(),
                            ),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                      ),
                    ),
                    Text(
                      context.l10n.progressWorkoutsUntilToday(
                        report.done,
                        report.due,
                      ),
                      style: TextStyle(fontSize: 12, color: c.textMuted),
                    ),
                  ],
                ),
              ),
              if (streak != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${streak.currentWeeks}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: c.goldBright,
                      ),
                    ),
                    Text(
                      context.l10n.progressStreak(streak.currentWeeks),
                      style: TextStyle(fontSize: 12, color: c.textMuted),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final (i, col) in report.columns.indexed) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      // Tema v2: un solo color (hecho), lleno en
                      // proporción a los entrenos hechos; vacío = track
                      Container(
                        height: 8,
                        clipBehavior: Clip.antiAlias,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: c.track,
                        ),
                        child: col.state == ColumnState.future
                            ? null
                            : FractionallySizedBox(
                                widthFactor: report.weekFill[i],
                                heightFactor: 1,
                                child: ColoredBox(color: c.turquoise),
                              ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        child: Text(
                          columnLabel(context, report, i),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: col.state == ColumnState.partial
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: col.state == ColumnState.partial
                                ? c.text
                                : c.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// "S3" (bloque) o "14 sep" (rango)
String columnLabel(BuildContext context, ProgressReport r, int i) {
  final col = r.columns[i];
  if (r.isRange && col.start != null) return formatDayMonth(col.start!);
  return context.l10n.progressWeekShort(col.weekNumber ?? i + 1);
}

/// "e1RM 100 → 105 kg" / "6 → 8 reps"
String valueText(ProgressExerciseUnit u, double v) =>
    u.bodyweight ? v.round().toString() : formatWeight(u.unit.fromKg(v));

class ProgressExerciseUnit {
  const ProgressExerciseUnit(this.unit, this.bodyweight);

  final WeightUnit unit;
  final bool bodyweight;
}

class _ExercisesCard extends ConsumerStatefulWidget {
  const _ExercisesCard({required this.report});

  final ProgressReport report;

  @override
  ConsumerState<_ExercisesCard> createState() => _ExercisesCardState();
}

class _ExercisesCardState extends ConsumerState<_ExercisesCard> {
  bool _hiddenOpen = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final unit = ref.watch(bodyWeightUnitProvider);
    final hidden = ref.watch(hiddenExercisesProvider).value ?? const <String>{};
    final groups = groupTrends(trendsOf(widget.report));
    final visible = groups
        .where((g) => !hidden.contains(g.exerciseId))
        .toList();
    final hiddenList = groups
        .where((g) => hidden.contains(g.exerciseId))
        .toList();
    void toggle(String id) =>
        ref.read(hiddenExercisesProvider.notifier).toggle(id);

    return HakiCard(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(14, 14, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Label(context.l10n.progressExercises),
          const SizedBox(height: 4),
          if (groups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                context.l10n.progressEmpty,
                style: TextStyle(fontSize: 13, color: c.textMuted),
              ),
            ),
          for (final g in visible)
            if (g.byPlace)
              _PlaceGroup(
                group: g,
                unit: unit,
                onHide: () => toggle(g.exerciseId),
              )
            else
              _ExerciseRow(
                trend: g.rows.first,
                unit: ProgressExerciseUnit(
                  unit,
                  g.rows.first.exercise.bodyweight,
                ),
                onOpen: () =>
                    context.push(Routes.progressExercise(g.exerciseId)),
                onHide: () => toggle(g.exerciseId),
              ),
          if (hiddenList.isNotEmpty) ...[
            InkWell(
              onTap: () => setState(() => _hiddenOpen = !_hiddenOpen),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility_off_outlined,
                      size: 16,
                      color: c.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.progressHidden(hiddenList.length),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.textMuted,
                        ),
                      ),
                    ),
                    Icon(
                      _hiddenOpen ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: c.textMuted,
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
            if (_hiddenOpen)
              for (final g in hiddenList)
                Opacity(
                  opacity: .6,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          g.name,
                          style: TextStyle(fontSize: 14, color: c.text),
                        ),
                      ),
                      IconButton(
                        tooltip: context.l10n.progressShow(g.name),
                        onPressed: () => toggle(g.exerciseId),
                        icon: Icon(
                          Icons.visibility_off_outlined,
                          size: 18,
                          color: c.goldBright,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.trend,
    required this.unit,
    required this.onOpen,
    this.onHide,
    this.title,
  });

  final ExerciseTrend trend;
  final ProgressExerciseUnit unit;
  final VoidCallback onOpen;

  /// null = fila de un lugar dentro de [_PlaceGroup] (el ojito va en el grupo)
  final VoidCallback? onHide;

  /// En vez del nombre del ejercicio ("Lunes · 3 × 12")
  final String? title;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pct = trend.pct;
    final up = pct != null && pct > 0;
    final range = trend.points.length < 2
        ? context.l10n.progressOneWeek
        : unit.bodyweight
        ? context.l10n.progressRepsRange(
            valueText(unit, trend.first),
            valueText(unit, trend.last),
          )
        : context.l10n.progressE1rmRange(
            valueText(unit, trend.first),
            valueText(unit, trend.last),
            unit.unit.label,
          );
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: context.l10n.progressOpenChart(
              title == null
                  ? trend.exercise.name
                  : '${trend.exercise.name} · $title',
            ),
            excludeSemantics: true,
            child: InkWell(
              onTap: onOpen,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 54),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title ?? trend.exercise.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: c.text,
                            ),
                          ),
                          Text(
                            range,
                            style: TextStyle(fontSize: 12, color: c.textMuted),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      height: 24,
                      child: CustomPaint(
                        // Tema v2: sube = turquesa; igual o baja = gris
                        painter: _Spark(
                          trend.points,
                          up ? c.turquoise : c.textMuted.withValues(alpha: .6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 52,
                      child: pct == null
                          ? null
                          : Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: up ? c.turquoiseSurface : c.surfaceHigh,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                up ? '+$pct%' : context.l10n.progressSame,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: up ? c.turquoise : c.textSecondary,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (onHide != null)
          IconButton(
            tooltip: context.l10n.progressHide(trend.exercise.name),
            onPressed: onHide,
            icon: Icon(Icons.visibility_outlined, size: 18, color: c.textMuted),
          )
        else
          const SizedBox(width: 12),
      ],
    );
  }
}

/// "Lunes · 3 × 12" / "Día 1 · 2.ª · 2 × 12" (fila de un lugar del programa)
String placeTitle(ExerciseProgress e) {
  final day = placeDayLabel(
    dayNumber: e.placeDay!,
    weekDay: e.placeWeekDay,
    slot: e.placeSlot,
  );
  final rx = rxLabel(
    sets: e.placeSets,
    repsMin: e.placeRepsMin,
    repsMax: e.placeRepsMax,
  );
  return rx == null ? day : '$day · $rx';
}

/// Un ejercicio que el coach puso en 2+ lugares (días, o dos veces el mismo
/// día): nombre con ⓘ (por qué va en dos filas) y el ojito, y una fila por
/// lugar que abre su detalle.
class _PlaceGroup extends StatefulWidget {
  const _PlaceGroup({
    required this.group,
    required this.unit,
    required this.onHide,
  });

  final TrendGroup group;
  final WeightUnit unit;
  final VoidCallback onHide;

  @override
  State<_PlaceGroup> createState() => _PlaceGroupState();
}

class _PlaceGroupState extends State<_PlaceGroup> {
  bool _tip = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final g = widget.group;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                g.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: c.text,
                ),
              ),
            ),
            IconButton(
              tooltip: context.l10n.progressPlaceWhy(g.name),
              onPressed: () => setState(() => _tip = !_tip),
              icon: Icon(
                Icons.info_outline,
                size: 17,
                color: _tip ? c.goldBright : c.textMuted,
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: context.l10n.progressHide(g.name),
              onPressed: widget.onHide,
              icon: Icon(
                Icons.visibility_outlined,
                size: 18,
                color: c.textMuted,
              ),
            ),
          ],
        ),
        if (_tip)
          Container(
            margin: const EdgeInsets.only(right: 10, bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: c.goldSurface,
              border: Border.all(color: c.goldBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              context.l10n.progressPlaceTip,
              style: TextStyle(fontSize: 13, height: 1.4, color: c.text),
            ),
          ),
        for (final t in g.rows)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _ExerciseRow(
              trend: t,
              title: placeTitle(t.exercise),
              unit: ProgressExerciseUnit(widget.unit, t.exercise.bodyweight),
              onOpen: () => context.push(
                Routes.progressExercise(
                  g.exerciseId,
                  place: t.exercise.placeKey,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Spark extends CustomPainter {
  _Spark(this.points, this.color);

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final min = points.reduce((a, b) => a < b ? a : b);
    final max = points.reduce((a, b) => a > b ? a : b);
    final span = max - min == 0 ? 1 : max - min;
    final path = Path();
    for (final (i, v) in points.indexed) {
      final o = Offset(
        2 + i * (size.width - 4) / (points.length - 1),
        size.height - 3 - (v - min) * (size.height - 6) / span,
      );
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    // Punto al final (dónde está hoy)
    final last = points.last;
    canvas.drawCircle(
      Offset(
        size.width - 2,
        size.height - 3 - (last - min) * (size.height - 6) / span,
      ),
      3,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_Spark old) => old.points != points || old.color != color;
}

/// PRs (superó su marca) logrados dentro del período
class _RecordsCard extends ConsumerWidget {
  const _RecordsCard({required this.report});

  final ProgressReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final records = ref.watch(recordsProvider).value;
    if (records == null) return const SizedBox.shrink();
    final from = dateOnly(report.from);
    final to = dateOnly(report.to);
    final prs = records
        .where(
          (r) =>
              r.isPr &&
              !dateOnly(r.date).isBefore(from) &&
              !dateOnly(r.date).isAfter(to),
        )
        .take(5)
        .toList();
    return HakiCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      onTap: () => context.push(Routes.records),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(context.l10n.progressRecords),
          const SizedBox(height: 10),
          if (prs.isEmpty)
            Text(
              context.l10n.progressNoRecords,
              style: TextStyle(fontSize: 13, color: c.textMuted),
            ),
          for (final r in prs)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c.goldSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.emoji_events_outlined,
                      size: 16,
                      color: c.goldBright,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.exerciseName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.text,
                          ),
                        ),
                        Text(
                          '${r.setLabel} · e1RM ${r.e1RmLabel}',
                          style: TextStyle(fontSize: 12, color: c.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatDayMonth(r.date),
                    style: TextStyle(fontSize: 12, color: c.textMuted),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Peso del período; tocar abre la pantalla de Peso corporal (gráfico + historial)
class _WeightCard extends ConsumerWidget {
  const _WeightCard({required this.report});

  final ProgressReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final unit = ref.watch(bodyWeightUnitProvider);
    final logs = ref.watch(bodyLogsProvider).value;
    if (logs == null) return const SizedBox.shrink();
    final from = dateOnly(report.from);
    final to = dateOnly(report.to);
    final points =
        logs
            .where(
              (l) =>
                  l.weightKg != null &&
                  !dateOnly(l.date).isBefore(from) &&
                  !dateOnly(l.date).isAfter(to),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    if (points.isEmpty) return const SizedBox.shrink();
    final first = points.first.weightKg!;
    final last = points.last.weightKg!;
    final delta = unit.fromKg(last) - unit.fromKg(first);
    final deltaText = delta.abs() < 0.05
        ? '='
        : '${delta < 0 ? '−' : '+'}${formatWeight(delta.abs())} ${unit.label}';
    return HakiCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      onTap: () => context.push(Routes.weight),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label(context.l10n.progressWeight),
                const SizedBox(height: 4),
                Text(
                  '${formatWeight(unit.fromKg(last))} ${unit.label}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: c.text,
                  ),
                ),
                Text(
                  context.l10n.progressWeightDelta(deltaText),
                  style: TextStyle(fontSize: 12, color: c.turquoise),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 96,
            height: 40,
            child: CustomPaint(
              painter: _Spark([
                for (final p in points) p.weightKg!,
              ], c.turquoise),
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, size: 18, color: c.textMuted),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
      color: context.colors.textMuted,
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 40),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14, color: context.colors.textMuted),
    ),
  );
}
