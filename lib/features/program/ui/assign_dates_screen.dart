import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/section_label.dart';
import '../data/assign_dates.dart';
import '../data/assignment_dtos.dart';
import '../data/program_schedule.dart';
import '../providers/program_providers.dart';

// Asignar (o cambiar) fechas: día de inicio + qué día de la semana se hace
// cada entreno. Opcional: "Ahora no" deja el programa sin fechas.
class AssignDatesScreen extends ConsumerStatefulWidget {
  const AssignDatesScreen({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  ConsumerState<AssignDatesScreen> createState() => _AssignDatesScreenState();
}

class _AssignDatesScreenState extends ConsumerState<AssignDatesScreen> {
  DateTime? _start;
  Map<int, int>? _weekDays;
  DateTime? _month;

  void _init(AssignmentDetailDto p) {
    if (_start != null) return;
    _start = defaultStart(p, DateTime.now());
    _weekDays = defaultWeekdays(p);
    _month = DateTime.utc(_start!.year, _start!.month);
  }

  Future<void> _save(AssignmentDetailDto p) async {
    final ok = await ref
        .read(scheduleSaverProvider.notifier)
        .save(p.assignmentId, _start!, _weekDays!);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(const SnackBar(content: Text('Fechas guardadas')));
      context.pop();
    } else {
      final error = ref.read(scheduleSaverProvider).error;
      messenger.showSnackBar(
        SnackBar(content: Text(apiErrorMessage(error ?? 'error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final detail = ref.watch(programDetailProvider(widget.assignmentId));
    final saving = ref.watch(scheduleSaverProvider).isLoading;

    final p = detail.value;
    if (p != null) _init(p);
    final canSave = p != null && _weekDays!.isNotEmpty && !saving;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            BackHeader(
              title: p?.hasDates == true ? 'Cambiar fechas' : 'Asignar fechas',
              subtitle: p == null ? null : '${p.blockName} · opcional',
              titleSize: 24,
            ),
            const SizedBox(height: 16),
            if (p != null)
              ..._form(p)
            else if (detail.hasError)
              Text(
                'No pudimos cargar el programa. Revisá tu conexión.',
                style: TextStyle(color: c.textMuted),
              )
            else
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: c.navBar,
          border: Border(top: BorderSide(color: c.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: canSave ? () => _save(p) : null,
                  child: saving
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: c.background,
                          ),
                        )
                      : const Text('Guardar fechas'),
                ),
                TextButton(
                  onPressed: saving ? null : () => context.pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: c.textSecondary,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: Text(
                    p?.hasDates == true
                        ? 'Cancelar'
                        : 'Ahora no · entrenar sin fechas',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _form(AssignmentDetailDto p) {
    final c = context.colors;
    final start = _start!;
    final end = endDateFor(start, p.totalWeeks);
    final today = dateOnly(DateTime.now());
    // Se puede elegir desde hoy, o mantener el inicio que ya tenía
    final minDate = p.startDate != null && p.startDate!.isBefore(today)
        ? p.startDate!
        : today;
    final titles = trainingDaysOf(p);
    final moved =
        p.startDate != null && start != p.startDate && dayCountsOf(p).$1 > 0;

    return [
      HakiCard(
        radius: 22,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(child: SectionLabel('1 · ¿Cuándo empezás?')),
                _MonthNav(
                  month: _month!,
                  canBack: _month!.isAfter(
                    DateTime.utc(minDate.year, minDate.month),
                  ),
                  onChange: (m) => setState(() => _month = m),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Calendar(
              month: _month!,
              selected: start,
              isEnabled: (d) => d == p.startDate || !d.isBefore(today),
              onPick: (d) => setState(() => _start = d),
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 13, color: c.textSecondary),
                children: [
                  const TextSpan(text: 'Empieza el '),
                  TextSpan(
                    text: formatShortDate(start),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.goldBright,
                    ),
                  ),
                  TextSpan(text: ' · termina el ${formatShortDate(end)}'),
                ],
              ),
            ),
            if (moved) ...[
              const SizedBox(height: 8),
              Text(
                'Cambiar el inicio mueve en qué semana del programa estás.',
                style: TextStyle(fontSize: 12, color: c.textMuted),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 20),
      const SectionLabel('2 · ¿Qué día hacés cada entreno?'),
      const SizedBox(height: 6),
      Text(
        'Se repite igual todas las semanas del bloque.',
        style: TextStyle(fontSize: 13, height: 1.45, color: c.textMuted),
      ),
      const SizedBox(height: 10),
      if (_weekDays!.isEmpty)
        Text(
          titles.isEmpty
              ? 'Tu coach todavía no armó los entrenos de este programa.'
              : 'Este programa tiene más de 7 entrenos por semana: pedile a tu coach que asigne las fechas.',
          style: TextStyle(fontSize: 14, color: c.textSecondary),
        )
      else
        for (final e in titles.entries) ...[
          _DayWeekdayCard(
            title: e.value,
            weekDay: _weekDays![e.key]!,
            first: firstOn(start, _weekDays![e.key]!),
            onPick: (wd) =>
                setState(() => _weekDays = pickWeekday(_weekDays!, e.key, wd)),
          ),
          const SizedBox(height: 10),
        ],
    ];
  }
}

class _MonthNav extends StatelessWidget {
  const _MonthNav({
    required this.month,
    required this.canBack,
    required this.onChange,
  });

  final DateTime month;
  final bool canBack;
  final ValueChanged<DateTime> onChange;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget arrow(IconData icon, String tip, int delta, bool enabled) =>
        IconButton(
          tooltip: tip,
          visualDensity: VisualDensity.compact,
          onPressed: enabled
              ? () => onChange(DateTime.utc(month.year, month.month + delta))
              : null,
          icon: Icon(icon, size: 20),
          color: c.textSecondary,
          disabledColor: c.border,
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        arrow(Icons.chevron_left, 'Mes anterior', -1, canBack),
        Text(
          formatMonthYear(month),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: c.text,
          ),
        ),
        arrow(Icons.chevron_right, 'Mes siguiente', 1, true),
      ],
    );
  }
}

/// Mes con las semanas empezando el lunes.
class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.month,
    required this.selected,
    required this.isEnabled,
    required this.onPick,
  });

  final DateTime month;
  final DateTime selected;
  final bool Function(DateTime) isEnabled;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final offset = month.weekday - 1;
    final days = DateTime.utc(month.year, month.month + 1, 0).day;
    final cells = <Widget>[
      for (final l in 'LMXJVSD'.split(''))
        Center(
          child: Text(
            l,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c.textMuted,
            ),
          ),
        ),
      for (var i = 0; i < offset; i++) const SizedBox.shrink(),
      for (var d = 1; d <= days; d++)
        () {
          final date = DateTime.utc(month.year, month.month, d);
          final on = date == selected;
          final enabled = isEnabled(date);
          return Semantics(
            button: true,
            selected: on,
            enabled: enabled,
            label: formatLongDate(date),
            excludeSemantics: true,
            child: Material(
              color: on ? c.gold : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: enabled ? () => onPick(date) : null,
                child: Center(
                  child: Text(
                    '$d',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: on
                          ? c.background
                          : enabled
                          ? c.text
                          : c.textMuted.withValues(alpha: .45),
                    ),
                  ),
                ),
              ),
            ),
          );
        }(),
    ];

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: 1.05,
      children: cells,
    );
  }
}

class _DayWeekdayCard extends StatelessWidget {
  const _DayWeekdayCard({
    required this.title,
    required this.weekDay,
    required this.first,
    required this.onPick,
  });

  final String title;
  final int weekDay;
  final DateTime first;
  final ValueChanged<int> onPick;

  static const _names = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return HakiCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 12, color: c.textMuted),
                  children: [
                    const TextSpan(text: '1.º: '),
                    TextSpan(
                      text: formatShortDate(first),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: c.turquoise,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var wd = 1; wd <= 7; wd++) ...[
                if (wd > 1) const SizedBox(width: 5),
                Expanded(
                  child: Semantics(
                    inMutuallyExclusiveGroup: true,
                    checked: wd == weekDay,
                    button: true,
                    label: '$title el ${_names[wd - 1]}',
                    excludeSemantics: true,
                    child: Material(
                      color: wd == weekDay
                          ? c.turquoiseSurface
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: wd == weekDay ? c.turquoise : c.border,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => onPick(wd),
                        child: SizedBox(
                          height: 36,
                          child: Center(
                            child: Text(
                              'LMXJVSD'[wd - 1],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: wd == weekDay
                                    ? c.turquoise
                                    : c.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
