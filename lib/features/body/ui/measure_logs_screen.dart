import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/haki_card.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../data/body_measures.dart';
import '../providers/body_providers.dart';

// Registros anteriores: un registro por día con alguna de las medidas que
// pidió el coach, del más nuevo al más viejo. Tocar uno abre Registrar
// medidas en esa fecha (ver o corregir).
class MeasureLogsScreen extends ConsumerWidget {
  const MeasureLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final logs = ref.watch(bodyLogsProvider);
    final unit = ref.watch(bodyWeightUnitProvider);
    final measures = measuresFor(
      ref.watch(authMeProvider).value?.bodyMeasurements ?? const [],
    );
    final rows = measureLogsOf(logs.value ?? const [], measures);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: BackHeader(title: 'Registros de medidas', titleSize: 22),
            ),
            Expanded(
              child: switch (logs) {
                AsyncData() when rows.isEmpty => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Todavía no registraste medidas.',
                    style: TextStyle(color: c.textMuted),
                  ),
                ),
                AsyncData() => RefreshIndicator(
                  onRefresh: () => ref.refresh(bodyLogsProvider.future),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final log = rows[i];
                      final n = measures
                          .where((m) => log.measures.containsKey(m.key))
                          .toList();
                      return HakiCard(
                        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                        onTap: () =>
                            context.push(Routes.logMeasures(date: log.date)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    capitalize(formatShortDate(log.date)),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: c.text,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // "Cintura 84 cm · Cadera 98.5 cm · …"
                                  Text(
                                    n
                                        .map(
                                          (m) =>
                                              '${m.label} ${formatMeasure(m.display(log.measures[m.key]!, unit))} ${m.unitLabel(unit)}',
                                        )
                                        .join(' · '),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: c.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: c.textMuted),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                AsyncError() => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No pudimos cargar tus medidas. Revisá tu conexión.',
                    style: TextStyle(color: c.textMuted),
                  ),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }
}
