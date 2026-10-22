import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../../program/data/program_schedule.dart';
import '../data/body_measures.dart';
import '../providers/body_providers.dart';
import '../../../l10n/l10n.dart';

// Registrar medidas (pantalla completa): fecha (hoy por defecto) y las medidas
// del coach agrupadas. Se mandan solo las que tienen valor; la API mergea con
// lo que ya hubiera ese día. Si el día ya tiene registro, arranca cargado.
class LogMeasuresScreen extends ConsumerStatefulWidget {
  const LogMeasuresScreen({super.key, this.initialDate});

  /// Desde Registros anteriores: el día a ver o corregir (null = hoy).
  final DateTime? initialDate;

  @override
  ConsumerState<LogMeasuresScreen> createState() => _LogMeasuresScreenState();
}

class _LogMeasuresScreenState extends ConsumerState<LogMeasuresScreen> {
  late var _date = widget.initialDate ?? dateOnly(DateTime.now());
  final _inputs = <String, TextEditingController>{};

  TextEditingController _input(String key) =>
      _inputs.putIfAbsent(key, TextEditingController.new);

  @override
  void initState() {
    super.initState();
    _fillFromDay();
  }

  @override
  void dispose() {
    for (final i in _inputs.values) {
      i.dispose();
    }
    super.dispose();
  }

  /// Carga los valores que ya tiene [_date] (o vacía los inputs).
  void _fillFromDay() {
    final unit = ref.read(bodyWeightUnitProvider);
    final logs = ref.read(bodyLogsProvider).value ?? const [];
    final day = logs.where((l) => l.date == _date).firstOrNull;
    for (final m
        in ref.read(authMeProvider).value?.bodyMeasurements ?? const []) {
      final v = day?.measures[m.key];
      _input(m.key).text = v == null ? '' : formatMeasure(m.display(v, unit));
    }
  }

  Future<void> _pickDate() async {
    final today = dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: today.subtract(const Duration(days: 365 * 3)),
      lastDate: today,
    );
    if (picked == null) return;
    setState(() => _date = dateOnly(picked));
    _fillFromDay();
  }

  Map<String, double> _values(List<BodyMeasure> measures) => {
    for (final m in measures) m.key: ?parseMeasure(_input(m.key).text),
  };

  Future<void> _save(List<BodyMeasure> measures) async {
    final ok = await ref
        .read(bodyLogSaverProvider.notifier)
        .save(date: _date, measures: _values(measures));
    if (!mounted) return;
    if (ok) {
      context.pop();
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
    final measures =
        ref.watch(authMeProvider).value?.bodyMeasurements ?? const [];
    final previous = previousBefore(
      ref.watch(bodyLogsProvider).value ?? const [],
      measures,
      _date,
    );
    final isToday = _date == dateOnly(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: context.l10n.commonCancel,
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.close, color: c.text),
                  ),
                  Text(
                    context.l10n.measuresLog,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: c.text,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ActionChip(
                      onPressed: _pickDate,
                      avatar: Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: c.text,
                      ),
                      label: Text(
                        isToday
                            ? '${context.l10n.commonToday} · ${formatDayMonth(_date)}'
                            : capitalize(formatShortDate(_date)),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.text,
                      ),
                      backgroundColor: c.surfaceHigh,
                      side: BorderSide(color: c.border),
                      shape: const StadiumBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.measuresBlankHint,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: c.textMuted,
                    ),
                  ),
                  for (final g in MeasureGroup.values)
                    if (measures.where((m) => m.group == g).toList()
                        case final inGroup when inGroup.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      SectionLabel(g.label),
                      const SizedBox(height: 8),
                      HakiCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (final (i, m) in inGroup.indexed)
                              _MeasureField(
                                measure: m,
                                controller: _input(m.key),
                                previous: previous[m.key] == null
                                    ? null
                                    : '${formatMeasure(m.display(previous[m.key]!, unit))} ${m.unitLabel(unit)}',
                                unitLabel: m.unitLabel(unit),
                                last: i == inGroup.length - 1,
                              ),
                          ],
                        ),
                      ),
                    ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.surfaceHigh)),
              ),
              child: ListenableBuilder(
                listenable: Listenable.merge(_inputs.values.toList()),
                builder: (_, _) => FilledButton(
                  onPressed: saving || _values(measures).isEmpty
                      ? null
                      : () => _save(measures),
                  child: Text(saving ? context.l10n.commonSaving : context.l10n.commonSave),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasureField extends StatelessWidget {
  const _MeasureField({
    required this.measure,
    required this.controller,
    required this.previous,
    required this.unitLabel,
    required this.last,
  });

  final BodyMeasure measure;
  final TextEditingController controller;
  final String? previous;
  final String unitLabel;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: c.surfaceHigh)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  measure.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.text,
                  ),
                ),
                if (previous != null)
                  Text(
                    context.l10n.measuresPrevious(previous!),
                    style: TextStyle(fontSize: 12, color: c.textMuted),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.right,
              textInputAction: TextInputAction.next,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: c.text,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: previous?.split(' ').first,
                suffixText: unitLabel,
                fillColor: c.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
