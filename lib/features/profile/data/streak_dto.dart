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
    int? required,
  }) : required = required ?? target;

  final DateTime weekStart;
  final int target;
  final int completed;
  final StreakWeekState state;

  /// Entrenos para que la semana cuente (la API tolera faltar a uno en
  /// semanas de 4+: 5 → 4). Sin el campo (API vieja) = todos.
  final int required;

  factory StreakWeekDto.fromJson(Map<String, dynamic> j) => StreakWeekDto(
    weekStart: DateTime.parse(j['weekStart'] as String),
    target: j['target'] as int? ?? 0,
    completed: j['completed'] as int? ?? 0,
    state:
        StreakWeekState.values.asNameMap()[j['state']] ?? StreakWeekState.off,
    required: j['required'] as int?,
  );
}

/// Qué dice el subtítulo de la tarjeta de racha.
enum StreakHintKind {
  /// En curso, faltan `n` para sumar la semana `week`.
  remaining,

  /// Racha en 0, la semana ya empezó: faltan `n` para arrancarla.
  remainingStart,

  /// Racha en 0 y nada hecho esta semana: hacer `n` para arrancarla.
  start,

  /// Llegó al mínimo pero quedan `n` entrenos de la semana.
  secured,

  /// Hizo todos los de la semana.
  full,

  /// Sin datos de la semana actual: "Completá esta y van `week`".
  next,

  /// Sin datos y sin racha: "Completá esta semana".
  finish,
}

typedef StreakHint = ({StreakHintKind kind, int n, int week});

StreakHint streakHintOf(StreakDto? s) {
  final streak = s?.currentWeeks ?? 0;
  final w = s?.weeks.lastOrNull;
  if (w != null && w.target > 0) {
    switch (w.state) {
      case StreakWeekState.met:
        final left = w.target - w.completed;
        return left > 0
            ? (kind: StreakHintKind.secured, n: left, week: streak)
            : (kind: StreakHintKind.full, n: 0, week: streak);
      case StreakWeekState.current:
        final left = (w.required - w.completed).clamp(1, w.required);
        if (streak > 0) {
          return (kind: StreakHintKind.remaining, n: left, week: streak + 1);
        }
        return w.completed == 0
            ? (kind: StreakHintKind.start, n: w.required, week: 1)
            : (kind: StreakHintKind.remainingStart, n: left, week: 1);
      case StreakWeekState.missed:
      case StreakWeekState.off:
        break;
    }
  }
  return streak > 0
      ? (kind: StreakHintKind.next, n: 0, week: streak + 1)
      : (kind: StreakHintKind.finish, n: 0, week: 1);
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
