import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/theme/rank_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/level_dto.dart';
import 'rank_icon.dart';

String rankName(AppLocalizations l, Rank rank) => switch (rank) {
  Rank.awakening => l.rankAwakening,
  Rank.warrior => l.rankWarrior,
  Rank.samurai => l.rankSamurai,
  Rank.daimyo => l.rankDaimyo,
  Rank.shogun => l.rankShogun,
};

/// "Principiante" / "Intermedio" / "Avanzado" (la define el coach)
String? experienceName(AppLocalizations l, int? level) => switch (level) {
  1 => l.experienceBeginner,
  2 => l.experienceIntermediate,
  3 => l.experienceAdvanced,
  _ => null,
};

/// Anillo de progreso del nivel con el ícono del rango adentro. El degradado
/// va del color del rango actual al del siguiente (Shōgun, el último: liso).
class LevelRing extends StatelessWidget {
  const LevelRing({super.key, required this.level, this.size = 132, this.stroke = 8, this.child});

  final LevelDto level;
  final double size;
  final double stroke;

  /// Lo de adentro; por defecto el ícono del rango
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final from = rankColor(context, level.rank);
    final to = rankColor(context, level.nextRank ?? level.rank);
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: level.progress,
          from: from,
          to: to,
          track: context.colors.track,
          stroke: stroke,
        ),
        child: Center(child: child ?? RankIcon(level.rank, size: size * 0.45)),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.from, required this.to, required this.track, required this.stroke});

  final double progress;
  final Color from;
  final Color to;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (progress <= 0) return;
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: sweep,
          colors: [from, to],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.from != from || old.to != to || old.track != track;
}

/// Medallita del rango (avatar del Perfil, Entreno completado)
class RankMedal extends StatelessWidget {
  const RankMedal(this.rank, {super.key, this.size = 28});

  final Rank rank;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = rankColor(context, rank);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.background,
        border: Border.all(color: color, width: 2),
      ),
      alignment: Alignment.center,
      child: RankIcon(rank, size: size * 0.58, color: color),
    );
  }
}

/// Barra de XP del nivel (dorada, como el resto de la app)
class XpBar extends StatelessWidget {
  const XpBar({super.key, required this.progress, this.height = 8});

  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: height,
        color: c.goldBright,
        backgroundColor: c.track,
      ),
    );
  }
}

// ── Logros ───────────────────────────────────────────────────────────

String badgeName(AppLocalizations l, String key) {
  final n = int.tryParse(key.split('_').last);
  return switch (key.split('_').first) {
    'streak' => l.badgeStreak(n ?? 0),
    'workouts' => n == 1 ? l.badgeFirstWorkout : l.badgeWorkouts(n ?? 0),
    'prs' => n == 1 ? l.badgeFirstPr : l.badgePrs(n ?? 0),
    'tons' => l.badgeTons(n ?? 0),
    'questionnaires' => l.badgeQuestionnaires(n ?? 0),
    _ => key == 'program_perfect' ? l.badgeProgramPerfect : l.badgeProgramDone,
  };
}

IconData badgeIcon(String group) => switch (group) {
  'streak' => Icons.local_fire_department_outlined,
  'workouts' => Icons.fitness_center,
  'prs' => Icons.emoji_events_outlined,
  'tons' => Icons.scale_outlined,
  'programs' => Icons.flag_outlined,
  'programs_perfect' => Icons.verified_outlined,
  'questionnaires' => Icons.assignment_outlined,
  _ => Icons.star_outline,
};
