import 'package:flutter/material.dart';

import '../../../core/format/dates.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/dashed_border.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/partial_ring.dart';
import '../../../core/widgets/section_label.dart';
import '../data/assignment_dtos.dart';
import '../data/program_schedule.dart';
import '../../../l10n/l10n.dart';

/// Tarjeta del bloque: rótulo + link de fechas, nombre, semana y entrenos,
/// barra por semanas.
class BlockCard extends StatelessWidget {
  const BlockCard({
    super.key,
    required this.label,
    required this.program,
    required this.week,
    required this.finished,
    this.datesLink,
    this.onDates,
  });

  final String label;
  final AssignmentDetailDto program;

  /// Semana actual (1-based) para "Semana 3 de 6" y la barra.
  final int week;

  /// Programa terminado: "6 semanas" y barra sin semana actual.
  final bool finished;
  final String? datesLink;
  final VoidCallback? onDates;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (done, total) = dayCountsOf(program);
    final weeks = program.totalWeeks;

    return HakiCard(
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: SectionLabel(label)),
              if (datesLink != null)
                InkWell(
                  onTap: onDates,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: Text(
                      datesLink!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c.turquoise,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            program.blockName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: c.text,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                finished
                    ? context.l10n.weeksCount(weeks)
                    : context.l10n.weekOfTotal(week, weeks),
                style: TextStyle(fontSize: 13, color: c.textSecondary),
              ),
              Text(
                context.l10n.workoutsDoneOf(done, total),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.turquoise,
                ),
              ),
            ],
          ),
          if (weeks > 0) ...[
            const SizedBox(height: 12),
            WeekFillBar(program: program, current: finished ? null : week),
          ],
        ],
      ),
    );
  }

}

/// Barra por semanas del bloque (tema v2): cada semana se llena en
/// proporción a los entrenos hechos, en un solo color.
class WeekFillBar extends StatelessWidget {
  const WeekFillBar({
    super.key,
    required this.program,
    this.current,
    this.height = 8,
  });

  final AssignmentDetailDto program;

  /// Semana en curso (dorada en el tema oscuro). null = programa terminado.
  final int? current;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final total = program.totalWeeks;
    double fillOf(int n) {
      final w = program.weeks.where((w) => w.weekNumber == n).firstOrNull;
      if (w == null || w.days.isEmpty) return 0;
      final done = w.days
          .where((d) => d.sessionStatus == SessionStatus.completed)
          .length;
      return done / w.days.length;
    }

    return Row(
      children: [
        for (var n = 1; n <= total; n++) ...[
          if (n > 1) const SizedBox(width: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(height / 2),
              child: SizedBox(
                height: height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: n == current ? c.currentWeekTrack : c.track,
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: fillOf(n),
                      child: ColoredBox(
                        color: n == current ? c.currentWeekFill : c.turquoise,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Selector de semana S1…SN, segmentado en una sola pieza (tema v2), con ✓
/// en las semanas terminadas. Si son más de 6 se desplaza en horizontal.
class WeekTabs extends StatelessWidget {
  const WeekTabs({
    super.key,
    required this.total,
    required this.selected,
    required this.onSelect,
    this.isEnabled,
    this.isDone,
  });

  final int total;
  final int selected;
  final ValueChanged<int> onSelect;

  /// null = todas se pueden elegir.
  final bool Function(int week)? isEnabled;

  /// Semana con todos sus días hechos (lleva ✓).
  final bool Function(int week)? isDone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget tab(int w) {
      final enabled = isEnabled?.call(w) ?? true;
      return Opacity(
        opacity: enabled || w == selected ? 1 : .35,
        child: _WeekTab(
          week: w,
          selected: w == selected,
          done: isDone?.call(w) ?? false,
          onTap: enabled ? () => onSelect(w) : null,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.track,
        borderRadius: BorderRadius.circular(14),
      ),
      child: total <= 6
          ? Row(
              children: [
                for (var w = 1; w <= total; w++) ...[
                  if (w > 1) const SizedBox(width: 4),
                  Expanded(child: tab(w)),
                ],
              ],
            )
          : SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: total,
                separatorBuilder: (_, _) => const SizedBox(width: 4),
                itemBuilder: (_, i) => SizedBox(width: 56, child: tab(i + 1)),
              ),
            ),
    );
  }
}

class _WeekTab extends StatelessWidget {
  const _WeekTab({
    required this.week,
    required this.selected,
    required this.done,
    required this.onTap,
  });

  final int week;
  final bool selected;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      enabled: onTap != null,
      label: context.l10n.weekN(week),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? c.weekTabSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: c.weekTabSelectedBorder)
              : null,
          boxShadow: selected ? c.cardShadow : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: SizedBox(
              height: 38,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'S$week',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? c.weekTabSelectedText : c.textSecondary,
                    ),
                  ),
                  if (done) ...[
                    const SizedBox(width: 3),
                    Icon(Icons.check_rounded, size: 13, color: c.turquoise),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Un día de la semana en el tab Programa.
class DayRowTile extends StatelessWidget {
  const DayRowTile({
    super.key,
    required this.row,
    required this.dated,
    this.onTap,
  });

  final DayRow row;

  /// El programa tiene fechas (cambia "Hecho"/"Siguiente"/"Sin fecha" por la
  /// fecha).
  final bool dated;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final day = row.day;
    final next = row.kind == DayRowKind.next;

    if (row.kind == DayRowKind.preparing) {
      return DashedBorder(
        color: c.border,
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _Badge(row: row),
              const SizedBox(width: 14),
              Expanded(
                child: _Texts(
                  title: day.title,
                  subtitle: context.l10n.programDayPreparing,
                  titleColor: c.textSecondary,
                  subtitleColor: c.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final skipped = row.kind == DayRowKind.skipped;
    return HakiCard(
      radius: 20,
      // El que toca: borde dorado fino
      borderColor: next ? c.todayBorder : null,
      borderWidth: next ? 1.5 : 1,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          _Badge(row: row),
          const SizedBox(width: 14),
          Expanded(
            child: _Texts(
              title: day.title,
              subtitle: _subtitle(context.l10n),
              titleColor: skipped ? c.textSecondary : c.text,
              subtitleColor: c.textMuted,
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              size: 22,
              color: next ? c.goldBright : c.textMuted,
            ),
        ],
      ),
    );
  }

  String _subtitle(AppLocalizations l) {
    final d = row.day;
    final date = row.date == null
        ? null
        : capitalize(formatShortDate(row.date!));
    final when = switch (row.kind) {
      DayRowKind.done => dated ? date : l.dayDone,
      DayRowKind.next => row.isToday ? l.commonToday : (date ?? l.commonNext),
      DayRowKind.inProgress => l.programInProgress,
      DayRowKind.skipped => [?date, l.skipDayRowSub].join(' · '),
      _ => date ?? (dated ? null : l.commonNoDate),
    };
    if (row.kind == DayRowKind.skipped) return when!;
    final n = d.exercises.length;
    final duration = row.kind == DayRowKind.done ? durationOf(d) : null;
    final ss = d.supersetCount;
    return [
      ?when,
      if (row.kind == DayRowKind.done && d.isPartial)
        l.daySetsOf(d.setsDone!, d.setsTotal!)
      else
        l.exercisesCount(n),
      if (duration != null)
        l.minutesShort(duration.inMinutes)
      else if (ss > 0)
        l.supersetsCount(ss),
    ].join(' · ');
  }
}

class _Texts extends StatelessWidget {
  const _Texts({
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.subtitleColor,
  });

  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
      ),
      const SizedBox(height: 3),
      Text(subtitle, style: TextStyle(fontSize: 13, color: subtitleColor)),
    ],
  );
}

/// Círculo de la izquierda: check (hecho), número dorado (el que toca),
/// número turquesa (en curso), número gris (pendiente / preparando).
class _Badge extends StatelessWidget {
  const _Badge({required this.row});

  final DayRow row;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final number = '${row.day.dayNumber}';
    if (row.kind == DayRowKind.done && row.day.partialProgress != null) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.turquoiseSurface,
        ),
        child: PartialRing(
          size: 36,
          progress: row.day.partialProgress!,
          strokeWidth: 3,
          child: Icon(Icons.check_rounded, size: 17, color: c.turquoise),
        ),
      );
    }
    if (row.kind == DayRowKind.done) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c.turquoise),
        child: Icon(Icons.check_rounded, size: 20, color: c.onTurquoise),
      );
    }
    if (row.kind == DayRowKind.skipped) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c.track, width: 2),
        ),
        child: Icon(Icons.close_rounded, size: 18, color: c.textMuted),
      );
    }
    final (border, width, fg, weight) = switch (row.kind) {
      DayRowKind.next => (c.goldBright, 2.0, c.goldBright, FontWeight.w800),
      DayRowKind.inProgress => (c.turquoise, 2.0, c.turquoise, FontWeight.w800),
      _ => (c.border, 1.5, c.textMuted, FontWeight.w700),
    };
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: border, width: width),
      ),
      child: Text(
        number,
        style: TextStyle(fontSize: 14, fontWeight: weight, color: fg),
      ),
    );
  }
}

/// "Todos mis programas · 4 >"
class AllProgramsLink extends StatelessWidget {
  const AllProgramsLink({super.key, required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            Text(
              context.l10n.programsAll,
              style: TextStyle(fontSize: 14, color: c.textSecondary),
            ),
            Text(
              ' · $count',
              style: TextStyle(fontSize: 14, color: c.textMuted),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, size: 20, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}
