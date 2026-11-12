import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../l10n/l10n.dart';
import '../../body/providers/body_providers.dart';
import '../data/progress_report.dart';
import '../providers/progress_providers.dart';
import 'progress_screen.dart';
import 'value_line_chart.dart';

// Detalle de un ejercicio desde Tu progreso: e1RM (o reps) de cada semana
// del período con el número en cada punto, récords en dorado y la mejor
// serie semana a semana. El período se cambia acá también.
class ExerciseProgressScreen extends ConsumerWidget {
  const ExerciseProgressScreen({
    super.key,
    required this.exerciseId,
    this.place,
  });

  final String exerciseId;

  /// Fila de un lugar del programa ("5-1" = día 5, 1.ª vez; el ejercicio está
  /// en 2+ lugares): solo esas series
  final String? place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final period = ref.watch(selectedProgressPeriodProvider);
    final program = ref.watch(selectedProgressProgramProvider);
    final report = ref.watch(progressReportProvider(period, program)).value;
    final unit = ref.watch(bodyWeightUnitProvider);
    final ex = report?.exercises
        .where(
          (e) =>
              e.exerciseId == exerciseId &&
              (place == null || e.placeKey == null || e.placeKey == place),
        )
        .firstOrNull;
    // Con otro período puede que ya no esté en dos lugares: entonces una fila
    final placeShown = ex?.placeKey == null ? null : placeTitle(ex!);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            BackHeader(
              title: ex == null
                  ? context.l10n.progressTitle
                  : placeShown == null
                  ? ex.name
                  : '${ex.name} · $placeShown',
              titleSize: 22,
            ),
            const SizedBox(height: 12),
            const ProgressPeriodPicker(),
            const SizedBox(height: 14),
            if (report == null)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (ex == null || ex.values.every((v) => v == null))
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  context.l10n.progressNoDataExercise,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: c.textMuted),
                ),
              )
            else
              ..._detail(context, report, ex, unit, period),
          ],
        ),
      ),
    );
  }

  List<Widget> _detail(
    BuildContext context,
    ProgressReport report,
    ExerciseProgress ex,
    WeightUnit unit,
    ProgressPeriod period,
  ) {
    final c = context.colors;
    String show(double v) =>
        ex.bodyweight ? v.round().toString() : formatWeight(unit.fromKg(v));
    final points = ex.values.nonNulls.toList();
    final first = points.first, last = points.last;
    final pct = points.length < 2 || first == 0
        ? null
        : ((last - first) * 100 / first).round();
    final prs = prMask(ex.values);
    final labels = [
      for (var i = 0; i < report.columns.length; i++)
        columnLabel(context, report, i),
    ];
    final kicker =
        (ex.bodyweight
                ? context.l10n.progressDetailRepsKicker(
                    periodLabel(context, period),
                  )
                : context.l10n.progressDetailKicker(
                    periodLabel(context, period),
                  ))
            .toUpperCase();

    final rows = <Widget>[];
    for (var i = report.columns.length - 1; i >= 0; i--) {
      final v = ex.values[i];
      if (v == null) continue;
      final best = ex.best[i];
      final prev = ex.values.sublist(0, i).nonNulls.lastOrNull;
      final diff = prev == null ? null : v - prev;
      final main = best == null
          ? show(v)
          : ex.bodyweight
          ? context.l10n.progressBestBw(best.reps)
          : context.l10n.progressBestSet(
              '${formatWeight(best.unit.fromKg(best.weightKg ?? 0))} ${best.unit.label}',
              best.reps,
              show(v),
            );
      rows.add(
        Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.surfaceHigh)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  labels[i] +
                      (report.columns[i].state == ColumnState.partial
                          ? '*'
                          : ''),
                  style: TextStyle(fontSize: 12, color: c.textMuted),
                ),
              ),
              Expanded(
                child: Text(
                  main,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.text,
                  ),
                ),
              ),
              if (prs[i])
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: c.goldSurface,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'PR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: c.goldBright,
                    ),
                  ),
                ),
              SizedBox(
                width: 64,
                child: Text(
                  diff == null
                      ? ''
                      : diff.abs() < 0.05
                      ? '='
                      : '${diff > 0 ? '+' : '−'}${show(diff.abs())}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    color: diff == null || diff.abs() < 0.05
                        ? c.textMuted
                        : diff > 0
                        ? c.turquoise
                        : c.danger,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return [
      HakiCard(
        radius: 18,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kicker,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: c.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  ex.bodyweight
                      ? context.l10n.progressRepsValue(show(last))
                      : '${show(last)} ${unit.label}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: c.text,
                  ),
                ),
                const SizedBox(width: 10),
                if (pct != null)
                  Text(
                    pct > 0 ? '+$pct%' : '=',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: pct > 0 ? c.turquoise : c.textMuted,
                    ),
                  ),
              ],
            ),
            Text(
              context.l10n.progressDetailSub,
              style: TextStyle(fontSize: 12, color: c.textMuted),
            ),
            if (ex.placeKey != null) ...[
              const SizedBox(height: 4),
              Text(
                context.l10n.progressPlaceOnly(placeTitle(ex)),
                style: TextStyle(fontSize: 12, color: c.textMuted),
              ),
            ],
            const SizedBox(height: 10),
            ValueLineChart(
              values: ex.values,
              xLabels: labels,
              prs: prs,
              format: show,
              semanticLabel: context.l10n.progressOpenChart(ex.name),
            ),
            if (prs.contains(true)) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: c.goldBright,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.progressPrLegend,
                    style: TextStyle(fontSize: 12, color: c.textMuted),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 14),
      HakiCard(
        radius: 18,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.progressWeekByWeek,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: c.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            ...rows,
          ],
        ),
      ),
    ];
  }
}
