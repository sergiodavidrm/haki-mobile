import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/back_header.dart';
import '../data/records.dart';
import '../providers/profile_providers.dart';

// Récords personales (mockup "Récords personales"): mejor e1RM por ejercicio.
// Arriba los PRs de esta semana (dorado, con la mejora); abajo los del
// programa en curso ("Este bloque") o todos ("Histórico"). Necesita red.
class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  bool? _blockOnly;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final records = ref.watch(recordsProvider);
    final current = ref.watch(currentAssignmentIdProvider).value;
    // Sin programa en curso no hay "Este bloque"
    final blockOnly = current != null && (_blockOnly ?? true);
    final today = DateTime.now();

    Widget section(String label) => Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: c.textMuted,
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(recordsProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              const BackHeader(title: 'Récords personales', titleSize: 22),
              const SizedBox(height: 12),
              if (current != null) ...[
                Wrap(
                  spacing: 8,
                  children: [
                    _RangeChip(
                      label: 'Este bloque',
                      selected: blockOnly,
                      onTap: () => setState(() => _blockOnly = true),
                    ),
                    _RangeChip(
                      label: 'Histórico',
                      selected: !blockOnly,
                      onTap: () => setState(() => _blockOnly = false),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'Mejor e1RM estimado por ejercicio, calculado de tus series '
                'registradas.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: c.textMuted,
                ),
              ),
              const SizedBox(height: 14),
              ...switch (records) {
                AsyncData(:final value) => () {
                  final s = recordSections(
                    value,
                    today: today,
                    currentAssignmentId: current,
                    blockOnly: blockOnly,
                  );
                  return [
                    if (s.thisWeek.isNotEmpty) ...[
                      section('ESTA SEMANA'),
                      for (final r in s.thisWeek)
                        _RecordRow(record: r, today: today, highlight: true),
                    ],
                    if (s.rest.isNotEmpty) ...[
                      section(blockOnly ? 'EN ESTE BLOQUE' : 'ANTERIORES'),
                      for (final r in s.rest)
                        _RecordRow(record: r, today: today),
                    ],
                    if (s.rest.isEmpty || value.isEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: c.border),
                        ),
                        child: Text(
                          'Seguí registrando tus series: cada vez que superás '
                          'tu mejor marca aparece acá.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: c.textMuted,
                          ),
                        ),
                      ),
                  ];
                }(),
                AsyncError() => [
                  Text(
                    'No se pudieron cargar tus récords. Revisá tu conexión.',
                    style: TextStyle(fontSize: 13, color: c.textMuted),
                  ),
                ],
                _ => [
                  const Padding(
                    padding: EdgeInsets.only(top: 32),
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
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
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
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: selected ? c.turquoise : c.textMuted,
      ),
      backgroundColor: c.background,
      selectedColor: c.turquoiseSurface,
      side: BorderSide(color: selected ? c.turquoise : c.border),
      shape: const StadiumBorder(),
    );
  }
}

/// Ejercicio · e1RM / serie que lo logró · fecha (+ mejora si es de esta
/// semana, en dorado).
class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.record,
    required this.today,
    this.highlight = false,
  });

  final PersonalRecordDto record;
  final DateTime today;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final r = record;
    final accent = highlight ? c.goldBright : null;
    final date = [
      recordDateLabel(r.date, today),
      if (highlight) ?r.improvementLabel,
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: highlight ? c.goldSurface : c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: highlight ? c.gold : c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.exerciseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.text,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                r.e1RmLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: accent ?? c.text,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  r.setLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: c.textMuted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Text(
                date,
                style: TextStyle(fontSize: 12, color: accent ?? c.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
