import '../../program/data/prescription.dart';
import 'package:flutter/material.dart';

import '../../../core/format/dates.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/dashed_border.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/partial_ring.dart';
import '../../../core/widgets/pill_chip.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/segmented_progress.dart';
import '../../program/data/assignment_dtos.dart';
import '../../program/data/program_schedule.dart';
import '../../../l10n/l10n.dart';

/// Tira L–D de la semana (programas con fechas por día). Turquesa relleno +
/// ✓ = hecho; anillo + ✓ = parcial; aro gris + ✕ = "no lo hago"; punteado =
/// hay entreno; primario = el día elegido (hoy si no se tocó otro); aro dorado
/// = hoy cuando se eligió otro día. Tocar un día muestra lo que toca
/// ese día; las flechas cambian de semana dentro del programa.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.days,
    required this.onSelect,
    this.onPrevWeek,
    this.onNextWeek,
    this.onToday,
  });

  final List<StripDay> days;
  final ValueChanged<DateTime> onSelect;

  /// null = no hay semana anterior/siguiente en el programa.
  final VoidCallback? onPrevWeek;
  final VoidCallback? onNextWeek;

  /// "Hoy": solo cuando se eligió otro día.
  final VoidCallback? onToday;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    Widget arrow(IconData icon, String tip, VoidCallback? onTap) => IconButton(
      tooltip: tip,
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      color: c.textSecondary,
      disabledColor: c.border,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                formatMonthYear(days.first.date),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: c.textSecondary,
                ),
              ),
            ),
            if (onToday != null)
              TextButton(
                onPressed: onToday,
                style: TextButton.styleFrom(
                  foregroundColor: c.goldBright,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(l.commonToday),
              ),
            arrow(Icons.chevron_left, l.weekPrev, onPrevWeek),
            arrow(Icons.chevron_right, l.weekNext, onNextWeek),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final d in days)
              _StripDayCell(day: d, onTap: () => onSelect(d.date)),
          ],
        ),
      ],
    );
  }
}

class _StripDayCell extends StatelessWidget {
  const _StripDayCell({required this.day, required this.onTap});

  final StripDay day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final d = day;
    final selected = d.isSelected;
    final partial = d.kind == StripDayKind.done && d.partialProgress != null;
    final done = d.kind == StripDayKind.done && !partial;

    // Tema v2 (2026-11-07): elegido = primario (dorado / obsidiana); hecho =
    // turquesa relleno + ✓ abajo; parcial = anillo + ✓; "no lo hago" = aro
    // gris + ✕; con entreno = aro punteado; hoy sin elegir = aro dorado.
    final Color bg = selected
        ? c.primary
        : done
        ? c.turquoise
        : Colors.transparent;
    final Color fg = selected
        ? c.onPrimary
        : done
        ? c.onTurquoise
        : partial
        ? c.turquoise
        : d.kind == StripDayKind.skipped
        ? c.textMuted
        : c.textSecondary;
    final Border? border = selected || done || partial
        ? null
        : d.isToday
        ? Border.all(color: c.goldBright, width: 1.5)
        : d.kind == StripDayKind.skipped
        ? Border.all(color: c.track, width: 2)
        : null;

    Widget circle = Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: border,
      ),
      child: Text(
        '${d.date.day}',
        style: TextStyle(
          fontSize: 15,
          fontWeight: d.kind == StripDayKind.none && !selected
              ? FontWeight.w500
              : FontWeight.w700,
          color: fg,
        ),
      ),
    );
    if (partial && !selected) {
      circle = PartialRing(
        size: 40,
        progress: d.partialProgress!,
        child: circle,
      );
    } else if (d.kind == StripDayKind.planned && !selected && !d.isToday) {
      circle = DashedBorder(
        color: c.textMuted,
        radius: 20,
        strokeWidth: 1.2,
        dash: 3,
        gap: 3,
        child: circle,
      );
    }

    final Widget mark = switch (d.kind) {
      StripDayKind.done => Icon(Icons.check_rounded, size: 13, color: c.turquoise),
      StripDayKind.skipped => Icon(Icons.close_rounded, size: 13, color: c.textMuted),
      StripDayKind.planned when selected => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c.gold),
      ),
      _ => const SizedBox.shrink(),
    };

    return Semantics(
      button: true,
      selected: selected,
      label:
          '${formatShortDate(d.date)}: ${switch (d.kind) {
            StripDayKind.done when partial => context.l10n.stripPartial,
            StripDayKind.done => context.l10n.stripDone,
            StripDayKind.planned => context.l10n.stripPlanned,
            StripDayKind.skipped => context.l10n.stripSkipped,
            StripDayKind.none => context.l10n.stripNone,
          }}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 44,
          child: Column(
            children: [
              Text(
                weekdayInitial(d.date),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected || d.isToday ? c.goldBright : c.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              circle,
              const SizedBox(height: 4),
              SizedBox(height: 14, child: Center(child: mark)),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Semana 2 del programa · 2 de 4 entrenos" (programas sin día de la semana
/// asignado). Es la semana del programa, no la del calendario: la racha del
/// Perfil cuenta por semana de calendario y por eso pueden no coincidir.
class WeekProgressCard extends StatelessWidget {
  const WeekProgressCard({super.key, required this.week});

  final WeekDto week;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = week.days
        .where((d) => d.sessionStatus == SessionStatus.completed)
        .length;
    return HakiCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.weekOfProgram(week.weekNumber),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: c.text,
                ),
              ),
              Text(
                context.l10n.workoutsDoneOf(done, week.days.length),
                style: TextStyle(fontSize: 13, color: c.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedProgress(total: week.days.length, done: done),
        ],
      ),
    );
  }
}

/// Tarjeta grande de Hoy para un día con entreno.
class TrainingDayCard extends StatelessWidget {
  const TrainingDayCard({
    super.key,
    required this.program,
    required this.plan,
    required this.onStart,
    required this.onOpenDone,
    this.onUnskip,
    this.date,
  });

  final AssignmentDetailDto program;
  final TrainingDay plan;

  /// Día marcado "No voy a hacer este día" → Deshacer.
  final VoidCallback? onUnskip;

  /// Día elegido en la tira si no es hoy: la etiqueta dice la fecha.
  final DateTime? date;
  final VoidCallback onStart;

  /// Día ya completado → Sesión pasada (ver lo hecho y subir videos).
  final VoidCallback onOpenDone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final day = plan.day;
    final l = context.l10n;
    final label =
        '${date != null
            ? capitalize(formatShortDate(date!))
            : plan.isScheduledToday
            ? l.commonToday
            : l.commonNext} · ${l.weekOfTotal(plan.week.weekNumber, program.totalWeeks)}';

    return HakiCard(
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(label, color: c.goldBright),
          const SizedBox(height: 14),
          Text(
            day.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: c.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            program.blockName,
            style: TextStyle(fontSize: 14, color: c.textMuted),
          ),
          const SizedBox(height: 14),
          if (day.exercises.isEmpty)
            Text(
              l.homeDayPreparing,
              style: TextStyle(fontSize: 14, color: c.textSecondary),
            )
          else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // La tarjeta no crece: fuerza como siempre + chips de movilidad y cardio
                if (day.exercises.any((e) => e.isStrength))
                  PillChip(l.exercisesCount(day.exercises.where((e) => e.isStrength).length)),
                if (day.supersetCount > 0)
                  PillChip(
                    l.supersetsCount(day.supersetCount),
                    tone: PillTone.turquoise,
                  ),
                if (day.exercises.where((e) => e.kind == ExerciseKinds.mobility).length case final n when n > 0)
                  PillChip(l.todayChipMobility(n), dotColor: c.mobilityText),
                ...switch (day.exercises.where((e) => e.kind == ExerciseKinds.cardio).toList()) {
                  [] => const <Widget>[],
                  [final one] => [
                    PillChip(
                      [one.exerciseName, formatPrescription(one.kind, one.prescription, withIntensity: false)]
                          .where((s) => s.isNotEmpty)
                          .join(' '),
                      dotColor: c.cardioText,
                    ),
                  ],
                  final many => [
                    PillChip(
                      l.todayChipCardios(
                        many.length,
                        many.fold<int>(0, (a, e) => a + (e.prescription?.minutes ?? 0)),
                      ),
                      dotColor: c.cardioText,
                    ),
                  ],
                },
                if (day.videoRequestCount > 0)
                  PillChip(
                    l.videosRequestedCount(day.videoRequestCount),
                    tone: PillTone.gold,
                    icon: Icons.videocam_outlined,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            switch (day.sessionStatus) {
              SessionStatus.completed => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: c.turquoise, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        l.workoutCompleted,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: c.turquoise,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onOpenDone,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      foregroundColor: c.turquoise,
                      side: BorderSide(color: c.turquoiseBorder),
                    ),
                    icon: const Icon(Icons.videocam_outlined, size: 18),
                    label: Text(l.workoutViewUploadVideos),
                  ),
                ],
              ),
              SessionStatus.skipped => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: c.track, width: 2),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: c.textMuted,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l.skipMarkedToday,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: onUnskip,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      foregroundColor: c.text,
                      side: BorderSide(color: c.primary, width: 1.5),
                    ),
                    child: Text(l.skipUndoTrain),
                  ),
                ],
              ),
              SessionStatus.inProgress => FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l.workoutContinue),
              ),
              SessionStatus.pending => FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l.workoutStart),
              ),
            },
          ],
        ],
      ),
    );
  }
}

/// Tarjeta de Hoy sin entreno: descanso, semana completa, programa terminado,
/// sin programa, etc.
class TodayInfoCard extends StatelessWidget {
  const TodayInfoCard({
    super.key,
    required this.label,
    required this.title,
    this.body,
  });

  final String label;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return HakiCard(
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label, color: c.goldBright),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: c.text,
            ),
          ),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(
              body!,
              style: TextStyle(fontSize: 14, height: 1.45, color: c.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
