import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/profile/data/streak_dto.dart';

StreakDto _s(int streak, StreakWeekState state, int target, int done) =>
    StreakDto(
      currentWeeks: streak,
      bestWeeks: streak,
      weeks: [
        StreakWeekDto(
          weekStart: DateTime(2026, 11, 2),
          target: target,
          completed: done,
          state: state,
          required: target >= 4 ? target - 1 : target,
        ),
      ],
    );

void main() {
  test('3 de 5 en curso con racha 1: falta 1 para sumar la semana 2', () {
    final h = streakHintOf(_s(1, StreakWeekState.current, 5, 3));
    expect(h.kind, StreakHintKind.remaining);
    expect(h.n, 1);
    expect(h.week, 2);
  });

  test('4 de 5 cumplida: asegurada, queda 1', () {
    final h = streakHintOf(_s(2, StreakWeekState.met, 5, 4));
    expect(h.kind, StreakHintKind.secured);
    expect(h.n, 1);
  });

  test('5 de 5: completa', () {
    expect(
      streakHintOf(_s(2, StreakWeekState.met, 5, 5)).kind,
      StreakHintKind.full,
    );
  });

  test('racha 0 sin nada hecho: hacé 4 (de 5)', () {
    final h = streakHintOf(_s(0, StreakWeekState.current, 5, 0));
    expect(h.kind, StreakHintKind.start);
    expect(h.n, 4);
  });

  test('racha 0 con 2 de 3: falta 1 para arrancar', () {
    final h = streakHintOf(_s(0, StreakWeekState.current, 3, 2));
    expect(h.kind, StreakHintKind.remainingStart);
    expect(h.n, 1);
  });

  test('semana sin programa: textos de antes', () {
    expect(
      streakHintOf(_s(3, StreakWeekState.off, 0, 0)).kind,
      StreakHintKind.next,
    );
    expect(streakHintOf(null).kind, StreakHintKind.finish);
  });

  test('API vieja sin required: todos', () {
    final w = StreakWeekDto.fromJson({
      'weekStart': '2026-11-02',
      'target': 5,
      'completed': 3,
      'state': 'current',
    });
    expect(w.required, 5);
  });
}
