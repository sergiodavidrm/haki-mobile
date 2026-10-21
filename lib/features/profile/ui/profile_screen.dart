import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../../body/data/body_log_dto.dart';
import '../../body/data/body_measures.dart';
import '../../body/providers/body_providers.dart';
import '../../body/ui/body_widgets.dart';
import '../../program/data/program_schedule.dart';
import '../../program/providers/program_providers.dart';
import '../data/streak_dto.dart';
import '../providers/profile_providers.dart';

// Tab Perfil: cuenta (engranaje → Ajustes) + racha de semanas + tarjetas de
// Peso, Medidas y Adherencia. Niveles y Récords del mockup se suman cuando
// tengan backend.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final auth = ref.watch(authRepositoryProvider);
    final me = ref.watch(authMeProvider).value;
    final logs = ref.watch(bodyLogsProvider).value ?? const <BodyLogDto>[];
    final unit = ref.watch(bodyWeightUnitProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(programSectionsProvider);
            ref.invalidate(streakProvider);
            // /auth/me trae las medidas que pidió el coach (puede cambiarlas);
            // bodyLogs depende de él, así que también se vuelve a pedir
            ref.invalidate(authMeProvider);
            await ref
                .read(bodyLogsProvider.future)
                .catchError((_) => <BodyLogDto>[]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            children: [
              Row(
                children: [
                  UserAvatar(
                    name: auth.displayName,
                    size: 60,
                    highlighted: true,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.displayName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: c.text,
                          ),
                        ),
                        if (me?.coachName ?? auth.email case final sub?)
                          Text(
                            me?.coachName != null ? 'Coach: $sub' : sub,
                            style: TextStyle(fontSize: 13, color: c.textMuted),
                          ),
                      ],
                    ),
                  ),
                  IconButton.outlined(
                    tooltip: 'Ajustes',
                    onPressed: () => context.push(Routes.settings),
                    icon: Icon(Icons.settings_outlined, color: c.textSecondary),
                    style: IconButton.styleFrom(
                      backgroundColor: c.surfaceHigh,
                      side: BorderSide(color: c.border),
                      fixedSize: const Size(44, 44),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _StreakCard(),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _WeightTile(logs: logs, unit: unit),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MeasuresTile(
                        logs: logs,
                        measures: me?.bodyMeasurements ?? const [],
                        unit: unit,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(child: _AdherenceTile()),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Racha de semanas (mockup: llama, "5 semanas seguidas", la mejor racha y
/// una barrita por semana). Sin red o sin programas no se muestra.
class _StreakCard extends ConsumerWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final s = ref.watch(streakProvider).value;
    if (s == null || s.weeks.every((w) => w.state == StreakWeekState.off)) {
      return const SizedBox.shrink();
    }

    String weeks(int n) => '$n ${n == 1 ? 'semana' : 'semanas'}';
    final pending = s.thisWeekPending;
    final title = s.currentWeeks > 0
        ? '${weeks(s.currentWeeks)} ${s.currentWeeks == 1 ? 'seguida' : 'seguidas'}'
        : 'Arrancá tu racha';
    final subtitle = [
      if (pending != null)
        'Esta semana: ${pending.completed} de ${pending.target}',
      if (s.bestWeeks > 0) 'Tu mejor racha: ${weeks(s.bestWeeks)}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        label: '$title. $subtitle',
        excludeSemantics: true,
        child: HakiCard(
          radius: 22,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department_outlined,
                size: 30,
                color: s.currentWeeks > 0 ? c.goldBright : c.textMuted,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: c.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Una barrita por semana: dorada = cumplida
              Row(
                children: [
                  for (final w in s.weeks)
                    Container(
                      width: 8,
                      height: 22,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: w.state == StreakWeekState.met
                            ? c.goldBright
                            : c.border,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta chica del Perfil: título, valor grande, [middle] opcional y pie.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.title,
    required this.value,
    this.valueSuffix,
    this.middle,
    required this.footer,
    this.onTap,
  });

  final String title;
  final String value;
  final String? valueSuffix;
  final Widget? middle;
  final Widget footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return HakiCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: value),
                  if (valueSuffix != null)
                    TextSpan(
                      text: valueSuffix,
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
            if (middle != null) ...[const SizedBox(height: 6), middle!],
            const Spacer(),
            const SizedBox(height: 6),
            DefaultTextStyle.merge(
              style: TextStyle(fontSize: 12, color: c.textMuted),
              child: footer,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightTile extends StatelessWidget {
  const _WeightTile({required this.logs, required this.unit});

  final List<BodyLogDto> logs;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final series = [
      for (final p in seriesOf(logs, null))
        (date: p.date, value: unit.fromKg(p.value)),
    ];
    final recent = inRange(
      series,
      WeightRange.weeks4,
      dateOnly(DateTime.now()),
    );
    final change = changeOf(recent);
    return _Tile(
      title: 'Peso corporal',
      value: series.isEmpty ? '–' : formatWeight(series.last.value),
      valueSuffix: series.isEmpty ? null : ' ${unit.label}',
      middle: recent.length < 2
          ? null
          : BodyLineChart(points: recent, height: 26, grid: false),
      footer: switch ((series.isEmpty, change)) {
        (true, _) => const Text('Registrá tu peso'),
        (_, final double ch) => Row(
          children: [
            DeltaText(ch, suffix: ' ${unit.label}', size: 12),
            const Text(' en 4 sem'),
          ],
        ),
        _ => Text(formatDayMonth(series.last.date)),
      },
      onTap: () => context.push(Routes.weight),
    );
  }
}

class _MeasuresTile extends StatelessWidget {
  const _MeasuresTile({
    required this.logs,
    required this.measures,
    required this.unit,
  });

  final List<BodyLogDto> logs;
  final List<BodyMeasure> measures;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    // Cintura como valor principal si el coach la pidió; si no, la primera
    final main =
        measures.where((m) => m.key == 'waist').firstOrNull ??
        measures.firstOrNull;
    final last = main == null ? null : seriesOf(logs, main.key).lastOrNull;
    final lastDate = measures
        .map((m) => seriesOf(logs, m.key).lastOrNull?.date)
        .nonNulls
        .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);
    final n = measures.length;
    return _Tile(
      title: 'Medidas',
      value: last == null
          ? '–'
          : formatMeasure(main!.display(last.value, unit)),
      valueSuffix: last == null
          ? null
          : ' ${main!.unitLabel(unit)} ${main.label.toLowerCase()}',
      footer: Text(
        lastDate == null
            ? '$n ${n == 1 ? 'medida' : 'medidas'} · sin registros'
            : '$n ${n == 1 ? 'medida' : 'medidas'} · ${formatDayMonth(lastDate)}',
      ),
      onTap: () => context.push(Routes.measures),
    );
  }
}

class _AdherenceTile extends ConsumerWidget {
  const _AdherenceTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(currentAdherenceProvider).value;
    return switch (a) {
      null => const _Tile(
        title: 'Adherencia',
        value: '–',
        footer: Text('Sin programa en curso'),
      ),
      (done: final done, due: final int due, total: _) when due > 0 => _Tile(
        title: 'Adherencia',
        value: '${(100 * done / due).round().clamp(0, 100)}',
        valueSuffix: '%',
        footer: Text('$done de $due entrenos en el programa'),
        onTap: () => context.go(Routes.program),
      ),
      (done: final done, due: _, total: final total) => _Tile(
        title: 'Adherencia',
        value: '$done',
        valueSuffix: ' de $total',
        footer: const Text('entrenos hechos'),
        onTap: () => context.go(Routes.program),
      ),
    };
  }
}
