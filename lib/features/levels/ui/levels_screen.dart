import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/dates.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/theme/rank_colors.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../l10n/l10n.dart';
import '../data/level_dto.dart';
import '../providers/level_providers.dart';
import 'level_widgets.dart';
import 'rank_icon.dart';

// Nivel y logros (canvas "Haki · Niveles y logros", App · Nivel y logros):
// anillo con el ícono del rango, camino de rangos, cómo sumar XP y logros.
class LevelsScreen extends ConsumerWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final level = ref.watch(levelProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(levelProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              BackHeader(title: l.levelsTitle, titleSize: 22),
              const SizedBox(height: 16),
              switch (level) {
                AsyncData(:final value) => _Body(level: value),
                AsyncError() => Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Text(
                    l.levelsOffline,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.textMuted),
                  ),
                ),
                _ => const Padding(
                  padding: EdgeInsets.only(top: 64),
                  child: Center(child: CircularProgressIndicator()),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.level});

  final LevelDto level;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final color = rankColor(context, level.rank);

    Widget section(String label) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: c.textMuted,
        ),
      ),
    );

    final ways = [
      (l.xpWayWorkout, '+100'),
      (l.xpWayAllSets, '+20'),
      (l.xpWayPr, '+50'),
      (l.xpWayWeek, '+150'),
      (l.xpWayStreak, '+25'),
      (l.xpWayQuestionnaire, '+30'),
      (l.xpWayBodyLog, '+20'),
      (l.xpWayProgram, '+300'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: LevelRing(level: level)),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '${l.levelN(level.level)} · '),
              TextSpan(text: rankName(l, level.rank), style: TextStyle(color: color)),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c.text),
        ),
        const SizedBox(height: 4),
        Text(
          l.levelXpOf(level.levelXp, level.levelCost, level.xp),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: c.textMuted),
        ),
        if (level.nextRank case final next?) ...[
          const SizedBox(height: 2),
          Text(
            l.levelNextRank(rankName(l, next), level.nextRankLevel ?? 0),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: c.textMuted),
          ),
        ],
        const SizedBox(height: 20),

        // Camino de rangos
        HakiCard(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              section(l.levelsRanks),
              for (final r in Rank.values)
                _RankRow(rank: r, current: level.rank),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Cómo sumar XP
        HakiCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              section(l.levelsHowToEarn),
              for (final (label, xp) in ways)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(label, style: TextStyle(fontSize: 13, color: c.textSecondary)),
                      ),
                      Text(xp, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: c.goldBright)),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Text(l.levelsNeverLose, style: TextStyle(fontSize: 12, color: c.textMuted)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Logros
        section(l.levelsBadges(level.unlockedCount, level.badges.length)),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.82,
          children: [
            for (final b in _sorted(level.badges)) _BadgeTile(badge: b),
          ],
        ),
      ],
    );
  }

  // Desbloqueados primero (el más reciente arriba), después los que faltan
  // en el orden del catálogo
  static List<BadgeDto> _sorted(List<BadgeDto> badges) => [
    ...badges.where((b) => b.unlocked).toList()
      ..sort((a, b) => b.unlockedOn!.compareTo(a.unlockedOn!)),
    ...badges.where((b) => !b.unlocked),
  ];
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.rank, required this.current});

  final Rank rank;
  final Rank current;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final reached = rank.index <= current.index;
    final now = rank == current;
    final start = rankStartLevel[rank]!;
    final end = rank == Rank.shogun ? null : rankStartLevel[Rank.values[rank.index + 1]]! - 1;
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: now ? rankSoft(context, rank) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Opacity(opacity: reached ? 1 : 0.45, child: RankIcon(rank, size: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rankName(l, rank),
              style: TextStyle(
                fontSize: 14,
                fontWeight: now ? FontWeight.w800 : FontWeight.w500,
                color: reached ? c.text : c.textMuted,
              ),
            ),
          ),
          Text(
            end == null ? l.levelFrom(start) : l.levelRange(start, end),
            style: TextStyle(fontSize: 12, color: c.textMuted),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final BadgeDto badge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final on = badge.unlocked;
    final value = badge.value > badge.target ? badge.target : badge.value;
    final sub = on
        ? formatDayMonth(badge.unlockedOn!)
        : l.badgeProgress(value.floor(), badge.target.floor());
    return Semantics(
      label: '${badgeName(l, badge.key)}. $sub',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: on ? c.goldBorder : c.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: on ? c.goldSurface : c.surfaceHigh,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(badgeIcon(badge.group), color: on ? c.goldBright : c.textMuted, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              badgeName(l, badge.key),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: on ? c.text : c.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 10, color: c.textMuted)),
          ],
        ),
      ),
    );
  }
}
