import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/cache/api_cache.dart';
import '../../../core/format/dates.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/dashed_border.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/segmented_progress.dart';
import '../../home/ui/today_widgets.dart';
import '../data/assignment_dtos.dart';
import '../data/program_schedule.dart';
import '../providers/program_providers.dart';
import '../../../l10n/l10n.dart';

// Mis programas: EN CURSO / PRÓXIMO / ANTERIORES. Con [asTab] es la raíz del
// tab Programa (cuando no hay programa en curso): sin botón de volver.
class ProgramsListScreen extends ConsumerWidget {
  const ProgramsListScreen({super.key, this.asTab = false});

  final bool asTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(programSectionsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            ref.read(apiCacheProvider).expire(wait: true);
            ref.invalidate(programSectionsProvider);
            return ref.read(programSectionsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              if (asTab)
                Text(
                  context.l10n.programsMine,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: context.colors.text,
                  ),
                )
              else
                BackHeader(title: context.l10n.programsMine),
              const SizedBox(height: 14),
              ...switch (sections) {
                AsyncData(:final value) => _content(context, value),
                AsyncError() => [
                  TodayInfoCard(
                    label: context.l10n.commonOffline,
                    title: context.l10n.programsLoadError,
                    body: context.l10n.homeLoadErrorBody,
                  ),
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
      ),
    );
  }

  List<Widget> _content(BuildContext context, ProgramSections s) {
    if (s.count == 0) {
      return [
        TodayInfoCard(
          label: context.l10n.programsYours,
          title: context.l10n.programsNoneTitle,
          body: context.l10n.homeNoProgramBody,
        ),
      ];
    }
    const gap = SizedBox(height: 10);
    return [
      if (s.current != null) ...[
        SectionLabel(context.l10n.programInProgress),
        gap,
        _CurrentCard(
          program: s.current!,
          onTap: () => context.go(Routes.program),
        ),
        const SizedBox(height: 20),
      ],
      if (s.upcoming.isNotEmpty) ...[
        SectionLabel(context.l10n.programsUpcoming(s.upcoming.length)),
        gap,
        for (final a in s.upcoming) ...[
          _UpcomingCard(
            program: a,
            onTap: () => context.push(
              a.hasDates
                  ? Routes.programView(a.assignmentId)
                  : Routes.assignDates(a.assignmentId),
            ),
          ),
          gap,
        ],
        const SizedBox(height: 10),
      ],
      if (s.past.isNotEmpty) ...[
        SectionLabel(context.l10n.programsPast),
        gap,
        for (var i = 0; i < s.past.length; i++)
          _PastRow(
            program: s.past[i],
            last: i == s.past.length - 1,
            onTap: () =>
                context.push(Routes.programView(s.past[i].assignmentId)),
          ),
      ],
    ];
  }
}

String _weeks(int n) => l10n.weeksCount(n);

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({required this.program, required this.onTap});

  final AssignmentSummaryDto program;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = program;
    final total = p.totalWeeks < 1 ? 1 : p.totalWeeks;
    final week = p.hasDates
        ? weekNumberFor(p.startDate!, DateTime.now()).clamp(1, total)
        : (p.completedWeeks + 1).clamp(1, total);
    final l = context.l10n;
    final subtitle = p.hasDates
        ? '${l.programSince(formatDayMonth(p.startDate!))} · ${l.weekOfTotal(week, p.totalWeeks)}'
        : '${l.commonNoDates} · ${l.workoutsDoneOf(p.completedDays, p.totalDays)}';

    return HakiCard(
      tone: HakiCardTone.gold,
      radius: 22,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  p.blockName,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: c.text,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: c.goldBright),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: c.goldBright.withValues(alpha: .75),
            ),
          ),
          if (p.totalWeeks > 0) ...[
            const SizedBox(height: 10),
            SegmentedProgress(
              total: p.totalWeeks,
              done: week - 1,
              highlightCurrent: true,
              height: 5,
              trackColor: c.goldBorder,
            ),
          ],
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.program, required this.onTap});

  final AssignmentSummaryDto program;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = program;
    final content = Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: c.surfaceHigh,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: c.textMuted,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.blockName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                p.hasDates
                    ? '${_weeks(p.totalWeeks)} · ${context.l10n.programStartsOn(formatShortDate(p.startDate!))}'
                    : '${_weeks(p.totalWeeks)} · ${context.l10n.commonNoDates}',
                style: TextStyle(fontSize: 12, color: c.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (p.hasDates)
          Icon(Icons.chevron_right, color: c.textMuted)
        else
          Text(
            context.l10n.assignDates,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c.turquoise,
            ),
          ),
      ],
    );

    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);
    if (p.hasDates) {
      return HakiCard(padding: padding, onTap: onTap, child: content);
    }
    return DashedBorder(
      color: c.border,
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: content),
        ),
      ),
    );
  }
}

/// Fila de la línea de tiempo: fecha de inicio + punto + tarjeta.
class _PastRow extends StatelessWidget {
  const _PastRow({
    required this.program,
    required this.last,
    required this.onTap,
  });

  final AssignmentSummaryDto program;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = program;
    final date = p.startDate ?? p.endDate;
    final pct = p.adherencePct;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: date == null
                  ? null
                  : Column(
                      children: [
                        Text(
                          monthShortUpper(date),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .8,
                            color: c.textMuted,
                          ),
                        ),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 14,
            child: Column(
              children: [
                const SizedBox(height: 22),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.turquoise,
                  ),
                ),
                if (!last)
                  Expanded(child: Container(width: 2, color: c.surfaceHigh)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 10),
              child: HakiCard(
                radius: 18,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.blockName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 12, color: c.textMuted),
                        children: [
                          TextSpan(text: _weeks(p.totalWeeks)),
                          if (pct != null) ...[
                            TextSpan(text: ' · ${context.l10n.programAdherence} '),
                            TextSpan(
                              text: '$pct%',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: c.turquoise,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
