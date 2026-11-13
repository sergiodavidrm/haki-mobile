import 'package:flutter/material.dart';

import '../../../core/format/dates.dart';
import '../../../core/theme/share_story_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../../core/widgets/haki_logo.dart';
import '../../../l10n/l10n.dart';
import '../../profile/data/records.dart';
import '../data/muscle_names.dart';
import '../data/share_format.dart';
import '../data/share_stickers.dart';
import '../providers/share_providers.dart';

// Los stickers (canvas https://claude.ai/artifact/XgxAnMeTfAh9gdVjzmFy2t).
// Ancho fijo de 300; se exportan a 1080 px de ancho (PNG, transparente si va
// sin fondo).

const stickerWidth = 300.0;

/// Los stickers que tienen datos para mostrar.
List<StickerKind> availableStickers(ShareData d, SharePeriod p) => [
  for (final k in StickerKind.of(p))
    if (switch (k) {
      StickerKind.dayRecord =>
        d.day != null && (d.day!.records.isNotEmpty || d.day!.best != null),
      StickerKind.dayMuscles => d.day?.muscles.isNotEmpty ?? false,
      StickerKind.daySummary || StickerKind.dayExercises => d.day != null,
      StickerKind.weekRecords => d.week.records.isNotEmpty,
      StickerKind.weekMuscles => d.week.muscles.isNotEmpty,
      StickerKind.weekProgram => d.week.program != null,
      StickerKind.monthRecords => d.month.records.isNotEmpty,
      StickerKind.monthMuscles => d.month.muscles.isNotEmpty,
      _ => true,
    })
      k,
];

String stickerLabel(BuildContext context, StickerKind k) {
  final l = context.l10n;
  return switch (k) {
    StickerKind.dayRecord => l.shareStRecord,
    StickerKind.daySummary => l.shareStSummary,
    StickerKind.dayMuscles ||
    StickerKind.weekMuscles ||
    StickerKind.monthMuscles => l.shareStMuscles,
    StickerKind.dayExercises => l.shareStExercises,
    StickerKind.weekDays => l.shareStWeek,
    StickerKind.weekNumbers => l.shareStNumbers,
    StickerKind.weekRecords || StickerKind.monthRecords => l.shareStRecords,
    StickerKind.weekProgram => l.shareStProgram,
    StickerKind.monthWorkouts => l.shareStWorkouts,
  };
}

IconData stickerIcon(StickerKind k) => switch (k) {
  StickerKind.dayRecord ||
  StickerKind.weekRecords ||
  StickerKind.monthRecords => Icons.workspace_premium_outlined,
  StickerKind.daySummary => Icons.timer_outlined,
  StickerKind.dayMuscles ||
  StickerKind.weekMuscles ||
  StickerKind.monthMuscles => Icons.bar_chart_rounded,
  StickerKind.dayExercises => Icons.format_list_bulleted,
  StickerKind.weekDays => Icons.event_available_outlined,
  StickerKind.weekNumbers || StickerKind.monthWorkouts => Icons.trending_up,
  StickerKind.weekProgram => Icons.linear_scale,
};

class Sticker extends StatelessWidget {
  const Sticker({
    super.key,
    required this.kind,
    required this.data,
    this.background,
    this.opacity = 0.7,
  });

  final StickerKind kind;
  final ShareData data;

  /// Índice de [ShareStoryColors.backgrounds]; null = sin fondo
  final int? background;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final bg = background;
    final p = bg == ShareStoryColors.lightBackground
        ? StickerPalette.onLight
        : StickerPalette.onDark;
    final shadows = bg == null
        ? const [Shadow(color: ShareStoryColors.shadow, blurRadius: 3, offset: Offset(0, 1))]
        : const <Shadow>[];
    return Container(
      width: stickerWidth,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg == null
            ? null
            : ShareStoryColors.backgrounds[bg].withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: p.ink,
          fontSize: 12,
          height: 1.25,
          shadows: shadows,
          decoration: TextDecoration.none,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _body(context, p),
            const SizedBox(height: 10),
            _Brand(light: p.light),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, StickerPalette p) {
    final u = data.unit;
    return switch (kind) {
      StickerKind.dayRecord => _DayRecord(data.day!, u, p),
      StickerKind.daySummary => _DaySummary(data.day!, u, p),
      StickerKind.dayMuscles => _DayMuscles(data.day!, u, p),
      StickerKind.dayExercises => _DayExercises(data.day!, u, p),
      StickerKind.weekDays => _WeekDays(data.week, p),
      StickerKind.weekNumbers => _Numbers(
        kicker: stickerWeekRange(data.week.start),
        title: context.l10n.shareMyWeek,
        now: data.week.totals,
        before: data.week.previous,
        footer: context.l10n.shareVsLastWeekShort,
        unit: u,
        p: p,
      ),
      StickerKind.weekRecords => _Records(
        kicker: stickerWeekRange(data.week.start),
        title: context.l10n.shareRecordsThisWeek(data.week.records.length),
        records: data.week.records,
        unit: u,
        p: p,
      ),
      StickerKind.weekMuscles => _Muscles(
        kicker: stickerWeekRange(data.week.start),
        lines: data.week.muscles,
        p: p,
      ),
      StickerKind.weekProgram => _Program(data.week.program!, u, p),
      StickerKind.monthMuscles => _Muscles(
        kicker: _monthLabel(context),
        lines: [
          for (final m in data.month.muscles) MuscleLine(m.key, m.value, null),
        ],
        p: p,
      ),
      StickerKind.monthWorkouts => _Numbers(
        kicker: _monthLabel(context),
        title: context.l10n.shareStWorkouts,
        now: data.month.totals,
        before: data.month.previous,
        footer: context.l10n.shareVsMonth(
          formatMonthYear(
            DateTime(data.month.month.year, data.month.month.month - 1),
          ).split(' ').first.toLowerCase(),
        ),
        unit: u,
        p: p,
      ),
      StickerKind.monthRecords => _Records(
        kicker: _monthLabel(context),
        title: context.l10n.shareRecordsOfMonth,
        records: data.month.records,
        unit: u,
        p: p,
        max: 3,
      ),
    };
  }

  String _monthLabel(BuildContext context) {
    final m = formatMonthYear(data.month.month);
    return data.month.toDate ? context.l10n.shareToDate(m) : m;
  }
}

// ------------------------------------------------------------ piezas comunes

class _Brand extends StatelessWidget {
  const _Brand({required this.light});
  final bool light;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Theme(
        data: ThemeData(brightness: light ? Brightness.light : Brightness.dark),
        child: const HakiLogoMark(size: 15, pulse: false),
      ),
      const SizedBox(width: 5),
      const Text(
        'haki',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    ],
  );
}

Text _kicker(String s, StickerPalette p, {TextAlign? align}) => Text(
  s,
  textAlign: align,
  style: TextStyle(fontSize: 11, color: p.muted),
);

Text _title(String s) => Text(
  s,
  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
);

class _Medal extends StatelessWidget {
  const _Medal(this.p, {this.size = 24});
  final StickerPalette p;
  final double size;

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.workspace_premium, color: p.gold, size: size);
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    this.note,
    this.valueColor,
    this.noteColor,
    required this.p,
  });
  final String value;
  final String label;
  final String? note;
  final Color? valueColor;
  final Color? noteColor;
  final StickerPalette p;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: -0.5,
          color: valueColor,
        ),
      ),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 11, color: p.muted)),
      if (note != null)
        Text(
          note!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: noteColor ?? p.accent,
          ),
        ),
    ],
  );
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.fill,
    required this.color,
    required this.p,
    this.marker,
    this.height = 9,
  });
  final double fill;
  final Color color;
  final StickerPalette p;

  /// Línea de lo que pide el programa (0–1)
  final double? marker;
  final double height;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => SizedBox(
      height: height + 6,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              color: p.track,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
          Container(
            height: height,
            width: c.maxWidth * fill.clamp(0, 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
          if (marker != null)
            Positioned(
              left: (c.maxWidth * marker!.clamp(0, 1)) - 1,
              top: 0,
              bottom: 0,
              child: Container(width: 2, color: p.ink),
            ),
        ],
      ),
    ),
  );
}

// ------------------------------------------------------------ Día

String _dayKicker(ShareDayData d) =>
    '${d.title} · ${formatShortDate(d.date)}';

class _DayRecord extends StatelessWidget {
  const _DayRecord(this.d, this.u, this.p);
  final ShareDayData d;
  final WeightUnit u;
  final StickerPalette p;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final r = d.records.firstOrNull;
    final best = d.best;
    final name = r?.name ?? best!.name;
    final value = r?.e1RmKg ?? best!.e1RmKg!;
    return Column(
      children: [
        _kicker(_dayKicker(d), p, align: TextAlign.center),
        const SizedBox(height: 8),
        _Medal(p, size: 34),
        Text(
          stickerWeight(value, u),
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          r == null
              ? l.shareBestE1Rm
              : l.shareNewRecordGain(stickerWeight(r.gainKg ?? 0, u)),
          style: TextStyle(
            fontSize: 11,
            color: r == null ? p.muted : p.gold,
            fontWeight: r == null ? FontWeight.w400 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DaySummary extends StatelessWidget {
  const _DaySummary(this.d, this.u, this.p);
  final ShareDayData d;
  final WeightUnit u;
  final StickerPalette p;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final change = d.volumeChange;
    final best = d.best;
    return Column(
      children: [
        _kicker(_dayKicker(d), p, align: TextAlign.center),
        const SizedBox(height: 12),
        _Stat(
          value: stickerVolume(d.volumeKg, u),
          label: l.shareVolume,
          note: change == null ? null : l.shareVsLastWeek(stickerPercent(change)),
          noteColor: change != null && change < 0 ? p.muted : p.accent,
          p: p,
        ),
        const SizedBox(height: 12),
        _Stat(
          value: l.shareSetsOf(d.sets, d.setsTotal),
          label: l.shareSetsLabel,
          note: d.sets >= d.setsTotal ? l.shareAllSetsDone : null,
          p: p,
        ),
        if (d.records.isNotEmpty || best != null) ...[
          const SizedBox(height: 12),
          if (d.records.isNotEmpty)
            _Stat(
              value: '${d.records.length} ★',
              label: l.shareRecordsLabel,
              note: d.records
                  .take(2)
                  .map((r) => '${r.name} ${stickerWeight(r.e1RmKg, u)}')
                  .join(' · '),
              valueColor: p.gold,
              noteColor: p.gold,
              p: p,
            )
          else
            _Stat(
              value: stickerWeight(best!.e1RmKg!, u),
              label: l.shareBestE1Rm,
              note: best.name,
              noteColor: p.ink,
              p: p,
            ),
        ],
      ],
    );
  }
}

class _DayMuscles extends StatelessWidget {
  const _DayMuscles(this.d, this.u, this.p);
  final ShareDayData d;
  final WeightUnit u;
  final StickerPalette p;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final top = d.muscles.first.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kicker(formatShortDate(d.date), p),
        _title(d.title),
        const SizedBox(height: 8),
        for (final m in d.muscles)
          _MuscleRow(
            name: muscleName(m.key),
            value: stickerSets(m.value),
            fill: m.value / top,
            p: p,
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (d.duration != null)
              _Mini(stickerDuration(d.duration!), l.shareDuration, p),
            _Mini(stickerVolume(d.volumeKg, u), l.shareVolume, p),
            _Mini('${d.sets}', l.shareSetsLabel, p),
          ],
        ),
      ],
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini(this.value, this.label, this.p);
  final String value;
  final String label;
  final StickerPalette p;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: p.muted)),
      ],
    ),
  );
}

class _MuscleRow extends StatelessWidget {
  const _MuscleRow({
    required this.name,
    required this.value,
    required this.fill,
    required this.p,
    this.marker,
    this.color,
  });
  final String name;
  final String value;
  final double fill;
  final double? marker;
  final Color? color;
  final StickerPalette p;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Expanded(
          child: _Bar(
            fill: fill,
            color: color ?? p.accent,
            marker: marker,
            p: p,
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _DayExercises extends StatelessWidget {
  const _DayExercises(this.d, this.u, this.p);
  final ShareDayData d;
  final WeightUnit u;
  final StickerPalette p;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _title(d.title)),
        Center(
          child: _kicker(
            [
              formatShortDate(d.date),
              if (d.duration != null) stickerDuration(d.duration!),
            ].join(' · '),
            p,
          ),
        ),
        const SizedBox(height: 8),
        for (final e in d.exercises)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${e.sets}×',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: p.accent,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    e.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  e.e1RmKg != null
                      ? '${stickerWeight(e.e1RmKg!, u)}${e.isPr ? ' ★' : ''}'
                      : l.shareReps(e.bestReps ?? 0),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: e.isPr ? p.gold : p.ink,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Text(
          l.shareE1RmNote,
          style: TextStyle(fontSize: 10, color: p.muted),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ Semana / Mes

class _WeekDays extends StatelessWidget {
  const _WeekDays(this.w, this.p);
  final ShareWeekData w;
  final StickerPalette p;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final prog = w.program;
    return Column(
      children: [
        _kicker(
          [
            stickerWeekRange(w.start),
            if (prog != null) l.shareWeekOf(prog.week, prog.weeks),
          ].join(' · '),
          p,
          align: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            text: '${w.done}',
            children: [
              if (w.planned > 0)
                TextSpan(
                  text: ' ${l.shareOfTotal(w.planned)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: p.muted,
                  ),
                ),
            ],
          ),
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          l.shareWorkoutsDone,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 7; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  children: [
                    Text(
                      weekdayLetter(i + 1),
                      style: TextStyle(fontSize: 10, color: p.muted),
                    ),
                    const SizedBox(height: 4),
                    _DayDot(w.marks[i], p),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          l.shareWeekLegend,
          style: TextStyle(fontSize: 10, color: p.muted),
        ),
        if ((w.streakWeeks ?? 0) > 0) ...[
          const SizedBox(height: 6),
          Text(
            l.shareStreak(w.streakWeeks!),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: p.gold,
            ),
          ),
        ],
      ],
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot(this.mark, this.p);
  final WeekMark mark;
  final StickerPalette p;

  @override
  Widget build(BuildContext context) {
    const size = 24.0;
    return switch (mark) {
      WeekMark.done => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: ShareStoryColors.doneFill,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 15, color: ShareStoryColors.onDone),
      ),
      WeekMark.missed => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: p.warn, width: 1.5),
        ),
        child: Icon(Icons.close, size: 14, color: p.warn),
      ),
      WeekMark.pending => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: p.muted, width: 1.5),
        ),
      ),
      WeekMark.rest => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: p.rest, shape: BoxShape.circle),
      ),
    };
  }
}

class _Numbers extends StatelessWidget {
  const _Numbers({
    required this.kicker,
    required this.title,
    required this.now,
    required this.before,
    required this.footer,
    required this.unit,
    required this.p,
  });
  final String kicker;
  final String title;
  final PeriodTotals now;
  final PeriodTotals before;
  final String footer;
  final WeightUnit unit;
  final StickerPalette p;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget cell(String label, String value, num a, num b, String Function(num) f) {
      final up = a > b;
      final same = (a - b).abs() < 0.0001;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: p.muted)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          Text(
            stickerDelta(a, b, f),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: same ? p.ink : (up ? p.accent : p.muted),
            ),
          ),
        ],
      );
    }

    Widget row(Widget a, Widget b) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: a), const SizedBox(width: 12), Expanded(child: b)],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kicker(kicker, p),
        _title(title),
        row(
          cell(l.shareWorkoutsLabel, '${now.workouts}', now.workouts, before.workouts, (v) => '${v.round()}'),
          cell(
            l.shareTime,
            stickerDuration(now.duration),
            now.duration.inMinutes,
            before.duration.inMinutes,
            (v) => stickerDuration(Duration(minutes: v.round())),
          ),
        ),
        row(
          cell(
            l.shareVolume,
            stickerVolume(now.volumeKg, unit),
            now.volumeKg,
            before.volumeKg,
            (v) => stickerVolume(v.toDouble(), unit),
          ),
          cell(l.shareSetsLabel, '${now.sets}', now.sets, before.sets, (v) => '${v.round()}'),
        ),
        const SizedBox(height: 6),
        Text(footer, style: TextStyle(fontSize: 10, color: p.muted)),
      ],
    );
  }
}

class _Records extends StatelessWidget {
  const _Records({
    required this.kicker,
    required this.title,
    required this.records,
    required this.unit,
    required this.p,
    this.max = 4,
  });
  final String kicker;
  final String title;
  final List<PersonalRecordDto> records;
  final WeightUnit unit;
  final StickerPalette p;
  final int max;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final rest = records.length - max;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kicker(kicker, p),
        _title(title),
        for (final r in records.take(max))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                _Medal(p),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.exerciseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l.shareE1RmGain(
                          stickerWeight(
                            r.e1RmKg - (r.previousE1RmKg ?? r.e1RmKg),
                            unit,
                          ),
                        ),
                        style: TextStyle(fontSize: 11, color: p.muted),
                      ),
                    ],
                  ),
                ),
                Text(
                  stickerWeight(r.e1RmKg, unit),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: p.gold,
                  ),
                ),
              ],
            ),
          ),
        if (rest > 0) ...[
          const SizedBox(height: 6),
          Text(
            l.shareMoreRecords(rest),
            style: TextStyle(fontSize: 11, color: p.muted),
          ),
        ],
      ],
    );
  }
}

class _Muscles extends StatelessWidget {
  const _Muscles({required this.kicker, required this.lines, required this.p});
  final String kicker;
  final List<MuscleLine> lines;
  final StickerPalette p;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final top = lines.fold<double>(
      1,
      (a, m) => [a, m.sets, (m.target ?? 0).toDouble()].reduce(
        (x, y) => x > y ? x : y,
      ),
    );
    final anyTarget = lines.any((m) => m.target != null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kicker(kicker, p),
        _title(l.shareSetsPerMuscle),
        const SizedBox(height: 6),
        for (final m in lines)
          _MuscleRow(
            name: muscleName(m.key),
            value: m.target == null
                ? stickerSets(m.sets)
                : '${stickerSets(m.sets)}/${m.target}',
            fill: m.sets / top,
            marker: m.target == null ? null : m.target! / top,
            color: m.target != null && m.sets < m.target! ? p.warn : p.accent,
            p: p,
          ),
        if (anyTarget) ...[
          const SizedBox(height: 4),
          Text(
            l.shareTargetLine,
            style: TextStyle(fontSize: 10, color: p.muted),
          ),
        ],
      ],
    );
  }
}

class _Program extends StatelessWidget {
  const _Program(this.g, this.u, this.p);
  final ProgramProgress g;
  final WeightUnit u;
  final StickerPalette p;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      children: [
        _kicker(g.name, p, align: TextAlign.center),
        const SizedBox(height: 2),
        _title(l.shareWeekOf(g.week, g.weeks)),
        const SizedBox(height: 8),
        SizedBox(
          width: 210,
          child: Row(
            children: [
              for (var i = 0; i < g.weekFill.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: _Bar(
                    fill: g.weekFill[i],
                    color: p.accent,
                    p: p,
                    height: 8,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(l.shareProgramWorkouts(g.done, g.total)),
        if (g.adherence != null) ...[
          const SizedBox(height: 8),
          Text(
            '${(g.adherence! * 100).round()} %',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          Text(l.shareOfDue, style: TextStyle(fontSize: 11, color: p.muted)),
        ],
        if (g.gainName != null) ...[
          const SizedBox(height: 6),
          Text(
            l.shareBlockGain(g.gainName!, stickerWeight(g.gainKg!, u)),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: p.gold,
            ),
          ),
        ],
      ],
    );
  }
}
