import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/haki_card.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../../program/data/program_schedule.dart';
import '../data/body_measures.dart';
import '../providers/body_providers.dart';
import 'body_widgets.dart';

// Historial de una medida: peso corporal ([measureKey] null) o una de las
// medidas (cintura, % grasa…). Último valor, cambio en el rango, gráfico,
// historial y botón para registrar. Peso y masa muscular en la unidad del
// atleta.
class BodySeriesScreen extends ConsumerStatefulWidget {
  const BodySeriesScreen({super.key, this.measureKey});

  final String? measureKey;

  @override
  ConsumerState<BodySeriesScreen> createState() => _BodySeriesScreenState();
}

class _BodySeriesScreenState extends ConsumerState<BodySeriesScreen> {
  var _range = WeightRange.weeks4;

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(bodyLogsProvider);
    final unit = ref.watch(bodyWeightUnitProvider);
    final today = dateOnly(DateTime.now());
    final measure = [
      ...?ref.watch(authMeProvider).value?.bodyMeasurements,
      ...bodyMeasures,
    ].where((m) => m.key == widget.measureKey).firstOrNull;
    final isWeight = measure == null;
    final unitLabel = measure?.unitLabel(unit) ?? unit.label;

    final all = [
      for (final p in seriesOf(logs.value ?? const [], measure?.key))
        (
          date: p.date,
          value: isWeight
              ? unit.fromKg(p.value)
              : measure.display(p.value, unit),
        ),
    ];
    final shown = inRange(all, _range, today);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: BackHeader(
                title: measure?.label ?? 'Peso corporal',
                titleSize: 22,
              ),
            ),
            Expanded(
              child: switch (logs) {
                AsyncData() when all.isEmpty => _Empty(
                  text: isWeight
                      ? 'Todavía no registraste tu peso.'
                      : 'Todavía no registraste esta medida.',
                ),
                AsyncData() => RefreshIndicator(
                  onRefresh: () => ref.refresh(bodyLogsProvider.future),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      _Summary(
                        all: all,
                        shown: shown,
                        range: _range,
                        unitLabel: unitLabel,
                      ),
                      const SizedBox(height: 18),
                      _RangePicker(
                        value: _range,
                        onChanged: (r) => setState(() => _range = r),
                      ),
                      const SizedBox(height: 18),
                      _ChartCard(
                        points: shown,
                        unitLabel: unitLabel,
                        title: measure?.label ?? 'Peso',
                      ),
                      const SizedBox(height: 18),
                      _History(
                        points: all.reversed.toList(),
                        unitLabel: unitLabel,
                      ),
                    ],
                  ),
                ),
                AsyncError() => _Empty(
                  text: 'No pudimos cargar tus datos. Revisá tu conexión.',
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(
                onPressed: () => isWeight
                    ? showWeightSheet(context)
                    : context.push(Routes.logMeasures()),
                child: Text(isWeight ? 'Registrar peso' : 'Registrar medidas'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.all,
    required this.shown,
    required this.range,
    required this.unitLabel,
  });

  final List<DatedValue> all;
  final List<DatedValue> shown;
  final WeightRange range;
  final String unitLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final last = all.last;
    final change = changeOf(shown);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: formatWeight(last.value)),
                    TextSpan(
                      text: ' $unitLabel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: c.textMuted,
                      ),
                    ),
                  ],
                ),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Último registro · ${formatDayMonth(last.date)}',
                style: TextStyle(fontSize: 13, color: c.textMuted),
              ),
            ],
          ),
        ),
        if (change != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DeltaText(change, suffix: ' $unitLabel', size: 15),
              Text(switch (range) {
                WeightRange.weeks4 => 'en 4 semanas',
                WeightRange.months3 => 'en 3 meses',
                WeightRange.all => 'desde el inicio',
              }, style: TextStyle(fontSize: 12, color: c.textMuted)),
            ],
          ),
      ],
    );
  }
}

class _RangePicker extends StatelessWidget {
  const _RangePicker({required this.value, required this.onChanged});

  final WeightRange value;
  final ValueChanged<WeightRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Wrap(
      spacing: 8,
      children: [
        for (final r in WeightRange.values)
          ChoiceChip(
            label: Text(r.label),
            selected: r == value,
            showCheckmark: false,
            onSelected: (_) => onChanged(r),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: r == value ? c.turquoise : c.textMuted,
            ),
            backgroundColor: c.background,
            selectedColor: c.turquoiseSurface,
            side: BorderSide(color: r == value ? c.turquoise : c.border),
            shape: const StadiumBorder(),
          ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.points,
    required this.unitLabel,
    required this.title,
  });

  final List<DatedValue> points;
  final String unitLabel;
  final String title;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (points.length < 2) {
      return HakiCard(
        child: Text(
          'Con dos registros en este rango vas a ver el gráfico.',
          style: TextStyle(fontSize: 13, color: c.textMuted),
        ),
      );
    }
    // 4 fechas repartidas en el eje x
    final t0 = points.first.date;
    final span = points.last.date.difference(t0);
    final labels = [for (var i = 0; i < 4; i++) t0.add(span * (i / 3))];
    return HakiCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
      child: Column(
        children: [
          BodyLineChart(
            points: points,
            semanticLabel:
                '$title de ${formatWeight(points.first.value)} a '
                '${formatWeight(points.last.value)} $unitLabel',
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final d in labels)
                Text(
                  formatDayMonth(d),
                  style: TextStyle(fontSize: 11, color: c.textMuted),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.points, required this.unitLabel});

  /// Del más nuevo al más viejo.
  final List<DatedValue> points;
  final String unitLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Historial',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        for (var i = 0; i < points.length; i++)
          Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.surfaceHigh)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    capitalize(formatShortDate(points[i].date)),
                    style: TextStyle(fontSize: 14, color: c.text),
                  ),
                ),
                Text(
                  '${formatWeight(points[i].value)} $unitLabel',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: i + 1 < points.length
                        ? DeltaText(points[i].value - points[i + 1].value)
                        : null,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(text, style: TextStyle(color: context.colors.textMuted)),
  );
}

/// Hoja "Registrar peso" (hoy). También se abre desde la tarjeta del Perfil.
Future<void> showWeightSheet(BuildContext context) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: context.colors.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder: (_) => const _WeightSheet(),
);

class _WeightSheet extends ConsumerStatefulWidget {
  const _WeightSheet();

  @override
  ConsumerState<_WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends ConsumerState<_WeightSheet> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = parseMeasure(_input.text);
    if (value == null) return;
    final saver = ref.read(bodyLogSaverProvider.notifier);
    final ok = await saver.save(date: dateOnly(DateTime.now()), weight: value);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      final error = ref.read(bodyLogSaverProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorMessage(error ?? 'error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final unit = ref.watch(bodyWeightUnitProvider);
    final saving = ref.watch(bodyLogSaverProvider).isLoading;
    final last = seriesOf(
      ref.watch(bodyLogsProvider).value ?? const [],
      null,
    ).lastOrNull;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        28 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  'Registrar peso',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: c.text,
                  ),
                ),
              ),
              Text(
                'Hoy · ${formatDayMonth(DateTime.now())}',
                style: TextStyle(fontSize: 13, color: c.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _input,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
            decoration: InputDecoration(
              hintText: last == null
                  ? null
                  : formatWeight(unit.fromKg(last.value)),
              suffixText: unit.label,
              fillColor: c.background,
            ),
          ),
          if (last != null) ...[
            const SizedBox(height: 10),
            Text(
              'Último: ${formatWeight(unit.fromKg(last.value))} ${unit.label}'
              ' · ${formatDayMonth(last.date)}',
              style: TextStyle(fontSize: 13, color: c.textMuted),
            ),
          ],
          const SizedBox(height: 16),
          ListenableBuilder(
            listenable: _input,
            builder: (_, _) => FilledButton(
              onPressed: saving || parseMeasure(_input.text) == null
                  ? null
                  : _save,
              child: Text(saving ? 'Guardando…' : 'Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}
