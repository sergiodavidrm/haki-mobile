import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/cache/api_cache.dart';
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
import '../../../l10n/l10n.dart';

// Tab Perfil: cuenta (engranaje → Ajustes) + racha de semanas + tarjetas de
// Peso, Medidas, Adherencia y Récords + PRs recientes. Niveles del mockup se
// suma cuando tenga backend.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final auth = ref.watch(authRepositoryProvider);
    final me = ref.watch(authMeProvider).value;
    final name = ref.watch(displayNameProvider);
    final logs = ref.watch(bodyLogsProvider).value ?? const <BodyLogDto>[];
    final unit = ref.watch(bodyWeightUnitProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.read(apiCacheProvider).expire(wait: true);
            ref.invalidate(programSectionsProvider);
            ref.invalidate(streakProvider);
            ref.invalidate(recordsProvider);
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
                  UserAvatar(name: name, size: 60, highlighted: true),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: c.text,
                          ),
                        ),
                        if (me?.coachName ?? auth.email case final sub?)
                          Text(
                            me?.coachName != null
                                ? context.l10n.coachLabel(sub)
                                : sub,
                            style: TextStyle(fontSize: 13, color: c.textMuted),
                          ),
                      ],
                    ),
                  ),
                  IconButton.outlined(
                    tooltip: context.l10n.settingsTitle,
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
              const _ProgressCard(),
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
              if (me?.coachName != null)
                _CoachCard(
                  name: me!.coach?.fullName ?? me.coachName!,
                  years: me.coach?.experienceYears(DateTime.now()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tu progreso (mockup "A · Una tarjeta de progreso" del canvas Haki · Perfil
/// del atleta): la puerta a /perfil/progreso. Racha, una barrita por semana y
/// el último PR; sin porcentajes (el período se elige en Tu progreso).
class _ProgressCard extends ConsumerWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final s = ref.watch(streakProvider).value;
    final lastPr = (ref.watch(recordsProvider).value ?? const [])
        .where((r) => r.isPr)
        .firstOrNull;
    final streak = s?.currentWeeks ?? 0;
    final title = streak > 0 ? l.streakComplete(streak) : l.streakStart;
    final hint = streakHintOf(s);
    final subtitle = switch (hint.kind) {
      StreakHintKind.remaining => l.streakRemaining(hint.n, hint.week),
      StreakHintKind.remainingStart => l.streakRemainingStart(hint.n),
      StreakHintKind.start => l.streakStartWeek(hint.n),
      StreakHintKind.secured => l.streakSecured(hint.n),
      StreakHintKind.full => l.streakThisWeekDone,
      StreakHintKind.next => l.streakNext(hint.week),
      StreakHintKind.finish => l.streakCompleteThisWeek,
    };
    final weeks = (s?.weeks ?? const <StreakWeekDto>[]).reversed
        .take(6)
        .toList()
        .reversed
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        label: '${l.progressTitle}. $title. $subtitle',
        excludeSemantics: true,
        child: Material(
          color: c.goldSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: c.goldBorder),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => context.push(Routes.progress),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.progressTitle.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: c.goldBright,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 20, color: c.goldBright),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_outlined,
                        size: 30,
                        color: streak > 0 ? c.goldBright : c.textMuted,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: c.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (weeks.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    // Una barrita por semana: dorada = cumplida
                    Row(
                      children: [
                        for (final (i, w) in weeks.indexed) ...[
                          if (i > 0) const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: switch (w.state) {
                                  StreakWeekState.met => c.goldBright,
                                  StreakWeekState.current => c.goldBorder,
                                  StreakWeekState.missed => c.border,
                                  StreakWeekState.off => Colors.transparent,
                                },
                                border: w.state == StreakWeekState.off
                                    ? Border.all(color: c.border)
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  if (lastPr != null) ...[
                    const SizedBox(height: 12),
                    Divider(height: 1, color: c.goldBorder),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.goldBright,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l.progressLastPr(lastPr.exerciseName),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lastPr.e1RmLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: c.goldBright,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta "Tu coach" (abajo de todo): iniciales, nombre y experiencia → pantalla Tu coach.
class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.name, this.years});

  final String name;
  final int? years;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: HakiCard(
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () => context.push(Routes.coach),
        child: Row(
          children: [
            UserAvatar(name: name, size: 40, highlighted: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      l.yourCoach,
                      if (years != null) l.coachExperience(years!),
                    ].join(' · '),
                    style: TextStyle(fontSize: 12, color: c.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: c.textMuted),
          ],
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
      title: context.l10n.bodyWeight,
      value: series.isEmpty ? '–' : formatWeight(series.last.value),
      valueSuffix: series.isEmpty ? null : ' ${unit.label}',
      middle: recent.length < 2
          ? null
          : BodyLineChart(points: recent, height: 26, grid: false),
      footer: switch ((series.isEmpty, change)) {
        (true, _) => Text(context.l10n.bodyLogWeight),
        (_, final double ch) => Row(
          children: [
            DeltaText(ch, suffix: ' ${unit.label}', size: 12),
            Text(' ${context.l10n.bodyIn4Weeks}'),
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
      title: context.l10n.measuresTitle,
      value: last == null
          ? '–'
          : formatMeasure(main!.display(last.value, unit)),
      valueSuffix: last == null
          ? null
          : ' ${main!.unitLabel(unit)} ${main.label.toLowerCase()}',
      footer: Text(
        lastDate == null
            ? '${context.l10n.measuresCount(n)} · ${context.l10n.measuresNoLogs}'
            : '${context.l10n.measuresCount(n)} · ${formatDayMonth(lastDate)}',
      ),
      onTap: () => context.push(Routes.measures),
    );
  }
}
