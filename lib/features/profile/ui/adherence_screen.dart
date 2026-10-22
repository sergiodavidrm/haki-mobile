import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../l10n/l10n.dart';
import '../data/adherence.dart';
import '../providers/profile_providers.dart';

// Adherencia (mockup "Adherencia"): % del programa en curso, series
// completadas, bloque anterior, una fila por semana y los entrenos que ya
// tocaban y no se hicieron (→ Sesión pasada).
class AdherenceScreen extends ConsumerWidget {
  const AdherenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final data = ref.watch(adherenceDetailProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            BackHeader(title: l.adherenceTitle, titleSize: 22),
            const SizedBox(height: 12),
            ...switch (data) {
              AsyncData(value: null) => [
                Text(
                  l.adherenceNoProgram,
                  style: TextStyle(color: c.textMuted),
                ),
              ],
              AsyncData(value: (:final report, :final previous)?) => [
                _Summary(report: report),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _Mini(
                        label: l.adherenceSets,
                        value: report.setsPercent,
                        footer: l.adherenceSetsFooter(
                          report.setsDone,
                          report.setsTarget,
                          report.workoutsDone,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Mini(
                        label: l.adherencePrevious,
                        value: previous == null
                            ? null
                            : (100 *
                                      previous.completedDays /
                                      previous.totalDays)
                                  .round(),
                        footer: previous?.blockName ?? l.adherenceNoPrevious,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: SectionLabel(l.adherenceByWeek)),
                    Text(
                      l.adherenceProgramWorkouts,
                      style: TextStyle(fontSize: 12, color: c.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _WeekGrid(weeks: report.weeks),
                const SizedBox(height: 8),
                const _Legend(),
                if (report.missed.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  SectionLabel(l.adherenceMissed),
                  const SizedBox(height: 8),
                  for (final m in report.missed) ...[
                    HakiCard(
                      radius: 16,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      onTap: () => context.push(
                        Routes.pastSession(report.assignmentId, m.day.id),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: c.danger, width: 1.5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${l.weekShortN(m.weekNumber)} · ${m.day.title}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: c.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${capitalize(formatShortDate(m.date))} · ${l.adherenceNotLogged}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: c.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: c.textMuted),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ],
              AsyncError() => [
                Text(l.homeLoadErrorBody, style: TextStyle(color: c.textMuted)),
              ],
              _ => const [
                Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            },
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.report});

  final AdherenceReport report;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final pct = report.percent;
    return HakiCard(
      radius: 22,
      child: Row(
        children: [
          Semantics(
            label: pct == null ? null : '$pct%',
            excludeSemantics: true,
            child: SizedBox(
              width: 88,
              height: 88,
              child: CustomPaint(
                painter: _RingPainter(
                  value: (pct ?? 0) / 100,
                  track: c.surfaceHigh,
                  color: c.turquoise,
                ),
                child: Center(
                  child: Text(
                    pct == null ? '–' : '$pct%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(l.adherenceCurrentBlock),
                const SizedBox(height: 4),
                Text(
                  report.blockName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.due == null
                      ? l.adherenceDoneOfTotal(report.done, report.total)
                      : l.adherenceDoneUntilToday(report.done, report.due!),
                  style: TextStyle(fontSize: 13, color: c.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.track, required this.color});

  final double value;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arc, 0, 2 * math.pi, false, paint..color = track);
    if (value > 0) {
      canvas.drawArc(
        arc,
        -math.pi / 2,
        2 * math.pi * value,
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.track != track || old.color != color;
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value, required this.footer});

  final String label;
  final int? value;
  final String footer;

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
              text: value == null ? '–' : '$value',
              children: [
                if (value != null)
                  TextSpan(
                    text: '%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: c.textMuted,
                    ),
                  ),
              ],
            ),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            footer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: c.textMuted),
          ),
        ],
      ),
    );
  }
}

class _WeekGrid extends StatelessWidget {
  const _WeekGrid({required this.weeks});

  final List<AdherenceWeek> weeks;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final columns = weeks.fold(0, (n, w) => math.max(n, w.cells.length));
    return Column(
      children: [
        for (final w in weeks)
          Semantics(
            label:
                '${l.weekShortN(w.weekNumber)}: ${l.ofTotalShort(w.done, w.cells.length)}',
            excludeSemantics: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      'S${w.weekNumber}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: w.isCurrent
                            ? c.goldBright
                            : w.started
                            ? c.textSecondary
                            : c.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        for (var i = 0; i < columns; i++) ...[
                          if (i > 0) const SizedBox(width: 5),
                          Expanded(
                            child: i < w.cells.length
                                ? _Cell(kind: w.cells[i])
                                : const SizedBox(height: 22),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      w.started ? '${w.done}/${w.cells.length}' : '—',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 13, color: c.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.kind, this.size = 22});

  final AdherenceCell kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: size,
      width: size == 22 ? null : size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size == 22 ? 6 : 3),
        color: switch (kind) {
          AdherenceCell.done => c.turquoise,
          AdherenceCell.today => c.gold,
          AdherenceCell.missed => Colors.transparent,
          AdherenceCell.pending => c.surfaceHigh,
        },
        border: kind == AdherenceCell.missed
            ? Border.all(color: c.danger, width: 1.5)
            : null,
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    Widget item(AdherenceCell k, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Cell(kind: k, size: 12),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: c.textMuted)),
      ],
    );
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        item(AdherenceCell.done, l.adherenceLegendDone),
        item(AdherenceCell.missed, l.adherenceLegendMissed),
        item(AdherenceCell.today, l.commonToday),
        item(AdherenceCell.pending, l.adherenceLegendPending),
      ],
    );
  }
}
