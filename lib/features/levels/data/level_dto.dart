import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/rank_colors.dart';

part 'level_dto.g.dart';

// api/v1/levels (haki-api LevelsController): el XP lo calcula la API desde el
// historial (Domain/XpRules.cs) y el nivel sale de la curva 400 + 100·n.

class BadgeDto {
  const BadgeDto({
    required this.key,
    required this.group,
    required this.target,
    required this.points,
    required this.value,
    this.unlockedOn,
  });

  /// streak_4, workouts_25, prs_10, tons_100, program_done…
  final String key;

  /// streak | workouts | prs | tons | programs | programs_perfect | questionnaires
  final String group;
  final num target;
  final int points;

  /// Avance del grupo (racha más larga, entrenos, récords, toneladas…)
  final num value;
  final DateTime? unlockedOn;

  bool get unlocked => unlockedOn != null;

  factory BadgeDto.fromJson(Map<String, dynamic> j) => BadgeDto(
    key: j['key'] as String,
    group: j['group'] as String? ?? '',
    target: j['target'] as num? ?? 0,
    points: j['points'] as int? ?? 0,
    value: j['value'] as num? ?? 0,
    unlockedOn: j['unlockedOn'] == null
        ? null
        : DateTime.parse(j['unlockedOn'] as String),
  );
}

class XpItemDto {
  const XpItemDto({
    required this.kind,
    required this.key,
    required this.points,
    required this.on,
    this.detail,
  });

  /// session | all_sets | pr | week | streak | questionnaire | body_log |
  /// video | program | badge | rank
  final String kind;
  final String key;
  final int points;
  final DateTime on;

  /// Ejercicio (pr, video)
  final String? detail;

  factory XpItemDto.fromJson(Map<String, dynamic> j) => XpItemDto(
    kind: j['kind'] as String,
    key: j['key'] as String? ?? '',
    points: j['points'] as int? ?? 0,
    on: DateTime.parse(j['on'] as String),
    detail: j['detail'] as String?,
  );
}

class LevelDto {
  const LevelDto({
    required this.xp,
    required this.level,
    required this.rank,
    required this.levelXp,
    required this.levelCost,
    this.nextRank,
    this.nextRankLevel,
    required this.weekXp,
    required this.showLevels,
    required this.badges,
    required this.recent,
  });

  final int xp;
  final int level;
  final Rank rank;

  /// XP dentro del nivel actual / lo que cuesta pasar al siguiente
  final int levelXp;
  final int levelCost;
  final Rank? nextRank;
  final int? nextRankLevel;
  final int weekXp;

  /// Del coach: apagado, la app no muestra niveles ni logros
  final bool showLevels;
  final List<BadgeDto> badges;
  final List<XpItemDto> recent;

  double get progress =>
      levelCost <= 0 ? 0 : (levelXp / levelCost).clamp(0.0, 1.0);

  int get unlockedCount => badges.where((b) => b.unlocked).length;

  factory LevelDto.fromJson(Map<String, dynamic> j) => LevelDto(
    xp: j['xp'] as int? ?? 0,
    level: j['level'] as int? ?? 1,
    rank: rankOf(j['rank'] as String?),
    levelXp: j['levelXp'] as int? ?? 0,
    levelCost: j['levelCost'] as int? ?? 500,
    nextRank: j['nextRank'] == null ? null : rankOf(j['nextRank'] as String),
    nextRankLevel: j['nextRankLevel'] as int?,
    weekXp: j['weekXp'] as int? ?? 0,
    showLevels: j['showLevels'] as bool? ?? true,
    badges: [
      for (final b in j['badges'] as List? ?? const [])
        BadgeDto.fromJson(b as Map<String, dynamic>),
    ],
    recent: [
      for (final r in j['recent'] as List? ?? const [])
        XpItemDto.fromJson(r as Map<String, dynamic>),
    ],
  );
}

/// Desglose de un entreno (Entreno completado). [pending] = la sesión todavía
/// no subió o no está completa en la API: volver a preguntar.
class SessionXpDto {
  const SessionXpDto({
    required this.points,
    required this.items,
    required this.levelBefore,
    required this.levelAfter,
    required this.rankBefore,
    required this.rankAfter,
    required this.level,
  });

  final int points;
  final List<XpItemDto> items;
  final int levelBefore;
  final int levelAfter;
  final Rank rankBefore;
  final Rank rankAfter;
  final LevelDto level;

  bool get pending => !items.any((i) => i.kind == 'session');
  bool get rankUp => rankAfter.index > rankBefore.index;
  bool get levelUp => levelAfter > levelBefore;

  factory SessionXpDto.fromJson(Map<String, dynamic> j) => SessionXpDto(
    points: j['points'] as int? ?? 0,
    items: [
      for (final i in j['items'] as List? ?? const [])
        XpItemDto.fromJson(i as Map<String, dynamic>),
    ],
    levelBefore: j['levelBefore'] as int? ?? 1,
    levelAfter: j['levelAfter'] as int? ?? 1,
    rankBefore: rankOf(j['rankBefore'] as String?),
    rankAfter: rankOf(j['rankAfter'] as String?),
    level: LevelDto.fromJson(j['level'] as Map<String, dynamic>),
  );
}

class LevelRepository {
  LevelRepository(this._api);

  final Dio _api;

  Future<LevelDto> get(String clientId) async {
    final res = await _api.get<Map<String, dynamic>>('/levels/$clientId');
    return LevelDto.fromJson(res.data!);
  }

  Future<SessionXpDto> day(
    String clientId,
    String assignmentId,
    String dayId,
  ) async {
    final res = await _api.get<Map<String, dynamic>>(
      '/levels/$clientId/assignments/$assignmentId/days/$dayId',
    );
    return SessionXpDto.fromJson(res.data!);
  }
}

@Riverpod(keepAlive: true)
LevelRepository levelRepository(Ref ref) =>
    LevelRepository(ref.watch(apiClientProvider));
