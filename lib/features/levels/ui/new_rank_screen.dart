import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/theme/rank_colors.dart';
import '../../../l10n/l10n.dart';
import '../../auth/providers/auth_me_provider.dart';
import 'level_widgets.dart';
import 'rank_icon.dart';

// Festejo al cambiar de rango (canvas "Haki · Niveles y logros", App ·
// Subiste de nivel): todo en el color del rango al que entra. Solo al cambiar
// de rango; subir un nivel es un aviso dentro de Entreno completado.
class NewRankScreen extends ConsumerWidget {
  const NewRankScreen({super.key, required this.rank, required this.level});

  final Rank rank;
  final int level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final color = rankColor(context, rank);
    final coach = ref.watch(authMeProvider).value?.coachName;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
          child: Column(
            children: [
              Text(
                l.newRankTitle.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: color,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox.square(
                dimension: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (final (r, o) in [(100.0, 0.25), (78.0, 0.5)])
                      Container(
                        width: r * 2 - 8,
                        height: r * 2 - 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: color.withValues(alpha: o), width: 2),
                        ),
                      ),
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.12),
                        border: Border.all(color: color, width: 3),
                        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 24)],
                      ),
                    ),
                    RankIcon(rank, size: 72, stroke: 2.2),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                rankName(l, rank),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                l.newRankReached(level),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: c.textSecondary),
              ),
              if (coach != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: c.border),
                  ),
                  child: Text(
                    l.newRankCoachSees(coach.split(' ').first),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textSecondary),
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => context.pop(),
                  child: Text(l.newRankContinue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
