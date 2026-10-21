import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';

part 'streak_dto.g.dart';

// GET progress/{clientId}/streak: racha de semanas cumpliendo los entrenos que
// pide el programa (la calcula la API, ver haki-api Domain/WeeklyStreak.cs).

enum StreakWeekState { met, missed, current, off }

class StreakWeekDto {
  const StreakWeekDto({
    required this.weekStart,
    required this.target,
    required this.completed,
    required this.state,
  });

  final DateTime weekStart;
  final int target;
  final int completed;
  final StreakWeekState state;

  factory StreakWeekDto.fromJson(Map<String, dynamic> j) => StreakWeekDto(
    weekStart: DateTime.parse(j['weekStart'] as String),
    target: j['target'] as int? ?? 0,
    completed: j['completed'] as int? ?? 0,
    state:
        StreakWeekState.values.asNameMap()[j['state']] ?? StreakWeekState.off,
  );
}

class StreakDto {
  const StreakDto({
    required this.currentWeeks,
    required this.bestWeeks,
    required this.weeks,
  });

  final int currentWeeks;
  final int bestWeeks;

  /// Últimas semanas, de la más vieja a la actual.
  final List<StreakWeekDto> weeks;

  /// La semana actual si todavía no se cumplió (para "Esta semana: 2 de 4").
  StreakWeekDto? get thisWeekPending =>
      weeks.lastOrNull?.state == StreakWeekState.current ? weeks.last : null;

  factory StreakDto.fromJson(Map<String, dynamic> j) => StreakDto(
    currentWeeks: j['currentWeeks'] as int? ?? 0,
    bestWeeks: j['bestWeeks'] as int? ?? 0,
    weeks: [
      for (final w in j['weeks'] as List? ?? const [])
        StreakWeekDto.fromJson(w as Map<String, dynamic>),
    ],
  );
}

class StreakRepository {
  StreakRepository(this._api);

  final Dio _api;

  Future<StreakDto> get(String clientId) async {
    final res = await _api.get<Map<String, dynamic>>(
      '/progress/$clientId/streak',
    );
    return StreakDto.fromJson(res.data!);
  }
}

@Riverpod(keepAlive: true)
StreakRepository streakRepository(Ref ref) =>
    StreakRepository(ref.watch(apiClientProvider));
