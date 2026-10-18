import 'package:flutter/material.dart';

import '../../../core/format/dates.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/dashed_border.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/segmented_progress.dart';
import '../data/assignment_dtos.dart';
import '../data/program_schedule.dart';

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
                    ? '$weeks ${weeks == 1 ? 'semana' : 'semanas'}'
                    : 'Semana $week de $weeks',
                style: TextStyle(fontSize: 13, color: c.textSecondary),
              ),
              Text(
                '$done de $total entrenos',
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
            SegmentedProgress(
              total: weeks,
              done: finished ? _completedWeeks(program) : week - 1,
              highlightCurrent: !finished,
            ),
          ],
        ],
      ),
    );
  }

  static int _completedWeeks(AssignmentDetailDto p) => p.weeks
      .where(
        (w) =>
            w.days.isNotEmpty &&
            w.days.every((d) => d.sessionStatus == SessionStatus.completed),
      )
      .length;
}

/// Selector de semana S1…SN. Si son más de 6 se desplaza en horizontal.
class WeekTabs extends StatelessWidget {
  const WeekTabs({
    super.key,
    required this.total,
    required this.selected,
    required this.onSelect,
  });

  final int total;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    Widget tab(int w) =>
        _WeekTab(week: w, selected: w == selected, onTap: () => onSelect(w));

    if (total <= 6) {
      return Row(
        children: [
          for (var w = 1; w <= total; w++) ...[
            if (w > 1) const SizedBox(width: 8),
            Expanded(child: tab(w)),
          ],
        ],
      );
    }
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: total,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => SizedBox(width: 52, child: tab(i + 1)),
      ),
    );
  }
}

class _WeekTab extends StatelessWidget {
  const _WeekTab({
    required this.week,
    required this.selected,
    required this.onTap,
  });

  final int week;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      label: 'Semana $week',
      excludeSemantics: true,
      child: Material(
        color: selected ? c.goldSurface : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: selected ? c.gold : c.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                'S$week',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? c.goldBright : c.textMuted,
                ),
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
                  subtitle: 'Tu coach lo está preparando',
                  titleColor: c.textSecondary,
                  subtitleColor: c.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return HakiCard(
      tone: next ? HakiCardTone.gold : HakiCardTone.neutral,
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          _Badge(row: row),
          const SizedBox(width: 14),
          Expanded(
            child: _Texts(
              title: day.title,
              subtitle: _subtitle(),
              titleColor: c.text,
              subtitleColor: next
                  ? c.goldBright.withValues(alpha: .75)
                  : c.textMuted,
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

  String _subtitle() {
    final d = row.day;
    final date = row.date == null
        ? null
        : capitalize(formatShortDate(row.date!));
    final when = switch (row.kind) {
      DayRowKind.done => dated ? date : 'Hecho',
      DayRowKind.next => row.isToday ? 'Hoy' : (date ?? 'Siguiente'),
      DayRowKind.inProgress => 'En curso',
      _ => date ?? (dated ? null : 'Sin fecha'),
    };
    final n = d.exercises.length;
    final duration = row.kind == DayRowKind.done ? durationOf(d) : null;
    final ss = d.supersetCount;
    return [
      ?when,
      '$n ${n == 1 ? 'ejercicio' : 'ejercicios'}',
      if (duration != null)
        '${duration.inMinutes} min'
      else if (ss > 0)
        '$ss ${ss == 1 ? 'superserie' : 'superseries'}',
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
    if (row.kind == DayRowKind.done) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c.turquoise),
        child: Icon(Icons.check_rounded, size: 20, color: c.background),
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
              'Todos mis programas',
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
