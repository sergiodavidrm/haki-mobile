import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/cache/api_cache.dart';
import '../../../core/format/dates.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/haki_card.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../data/body_measures.dart';
import '../providers/body_providers.dart';
import 'body_widgets.dart';
import '../../../l10n/l10n.dart';

// Medidas que eligió el coach: último valor de cada una y la diferencia con
// su registro anterior. Tocar una abre su historial; abajo, los registros
// anteriores por fecha.
class MeasuresScreen extends ConsumerWidget {
  const MeasuresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final me = ref.watch(authMeProvider).value;
    final logs = ref.watch(bodyLogsProvider);
    final unit = ref.watch(bodyWeightUnitProvider);
    final measures = me?.bodyMeasurements ?? const <BodyMeasure>[];

    final rows = [
      for (final m in measures)
        (m, lastTwo(seriesOf(logs.value ?? const [], m.key))),
    ];
    final lastDate = rows
        .map((r) => r.$2?.last.date)
        .nonNulls
        .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: BackHeader(title: context.l10n.measuresTitle, titleSize: 22),
            ),
            Expanded(
              child: switch (logs) {
                AsyncData() => RefreshIndicator(
                  // Vuelve a pedir /auth/me (medidas del coach) y con él bodyLogs
                  onRefresh: () {
                    ref.read(apiCacheProvider).expire(wait: true);
                    ref.invalidate(authMeProvider);
                    return ref.read(bodyLogsProvider.future);
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      if (measures.isEmpty)
                        Text(
                          context.l10n.measuresNoneChosen,
                          style: TextStyle(color: c.textMuted),
                        )
                      else ...[
                        if (me?.coachName case final coach?) ...[
                          _CoachNote(coach: coach),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          lastDate == null
                              ? context.l10n.measuresNoneYet
                              : context.l10n.lastEntry(formatDayMonth(lastDate)),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: c.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        HakiCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              for (final (i, (m, v)) in rows.indexed)
                                InkWell(
                                  onTap: () =>
                                      context.push(Routes.bodySeries(m.key)),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 56,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      border: i == rows.length - 1
                                          ? null
                                          : Border(
                                              bottom: BorderSide(
                                                color: c.surfaceHigh,
                                              ),
                                            ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            m.label,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: c.text,
                                            ),
                                          ),
                                        ),
                                        if (v == null)
                                          Text(
                                            '–',
                                            style: TextStyle(
                                              color: c.textMuted,
                                            ),
                                          )
                                        else
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: formatMeasure(
                                                    m.display(
                                                      v.last.value,
                                                      unit,
                                                    ),
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: ' ${m.unitLabel(unit)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: c.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: c.text,
                                            ),
                                          ),
                                        SizedBox(
                                          width: 64,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: v?.previous == null
                                                ? null
                                                : DeltaText(
                                                    m.display(
                                                          v!.last.value,
                                                          unit,
                                                        ) -
                                                        m.display(
                                                          v.previous!.value,
                                                          unit,
                                                        ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => context.push(Routes.measureLogs),
                            style: TextButton.styleFrom(
                              foregroundColor: c.turquoise,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 44),
                            ),
                            child: Text(context.l10n.measuresSeePrevious),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AsyncError() => _Message(
                  context.l10n.measuresLoadError,
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
            if (measures.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton(
                  onPressed: () => context.push(Routes.logMeasures()),
                  child: Text(context.l10n.measuresLog),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoachNote extends StatelessWidget {
  const _CoachNote({required this.coach});

  final String coach;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final first = coach.trim().split(RegExp(r'\s+')).first;
    return HakiCard(
      tone: HakiCardTone.turquoise,
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: c.turquoiseSurface,
            child: Text(
              first.isEmpty ? '?' : first[0].toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.turquoise,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.measuresChosenBy(first),
              style: TextStyle(fontSize: 13, height: 1.4, color: c.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(text, style: TextStyle(color: context.colors.textMuted)),
  );
}
