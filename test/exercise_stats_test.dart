import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/core/units/weight_unit.dart';
import 'package:haki_mobile/features/exercise/data/exercise_history.dart';
import 'package:haki_mobile/features/exercise/data/exercise_stats.dart';
import 'package:haki_mobile/features/program/data/assignment_dtos.dart';

LoggedSetDto set(int n, double? kg, int? reps, [int? rir]) => LoggedSetDto(
  setNumber: n,
  weightKg: kg,
  weightUnit: 'KG',
  reps: reps,
  rir: rir,
);

LastPerformanceDto last(String a, int week) => LastPerformanceDto(
  assignmentId: a,
  weekNumber: week,
  date: DateTime.utc(2026, 9, 25, 15),
  sets: [set(1, 50, 12)],
);

void main() {
  test('e1RM y volumen', () {
    final sets = [set(1, 100, 5), set(2, 90, 10), set(3, null, 12)];
    expect(bestE1rmKg(sets), closeTo(120, 1e-9)); // 90 × (1 + 10/30)
    expect(volumeKg(sets), 1400);
    expect(bestE1rmKg([set(1, null, 10)]), isNull);
  });

  test('setsSummary: peso único, rango, sin peso y en lb', () {
    expect(
      setsSummary([set(1, 50, 12), set(2, 50, 12)], WeightUnit.kg),
      '50 kg × 12·12',
    );
    expect(
      setsSummary([set(1, 50, 12), set(2, 55, 10)], WeightUnit.kg),
      '50–55 kg × 12·10',
    );
    expect(
      setsSummary([set(1, null, 15), set(2, null, 12)], WeightUnit.kg),
      '15·12 reps',
    );
    expect(setsSummary([set(1, 45.359237, 8)], WeightUnit.lb), '100 lb × 8');
  });

  test('lastTimeLabel: semana pasada, otra semana u otro programa', () {
    expect(
      lastTimeLabel(last('a', 2), assignmentId: 'a', weekNumber: 3),
      'Sem. pasada',
    );
    expect(
      lastTimeLabel(last('a', 1), assignmentId: 'a', weekNumber: 3),
      'Sem. 1',
    );
    expect(
      lastTimeLabel(last('b', 6), assignmentId: 'a', weekNumber: 1),
      '25 sep',
    );
  });

  test('setChip: peso × reps @RIR, sin peso y en lb', () {
    expect(setChip(set(1, 50, 12, 1), WeightUnit.kg), '50 kg × 12 @1');
    expect(setChip(set(1, 50, 12), WeightUnit.kg), '50 kg × 12');
    expect(setChip(set(1, null, 15, 2), WeightUnit.kg), '15 @2');
    expect(setChip(set(1, 45.359237, 8), WeightUnit.lb), '100 lb × 8');
  });

  test('isNewPr: supera a todas las anteriores', () {
    expect(
      isNewPr([
        [set(1, 105, 5)],
        [set(1, 100, 5)],
        [set(1, 90, 5)],
      ]),
      isTrue,
    );
    expect(
      isNewPr([
        [set(1, 95, 5)],
        [set(1, 100, 5)],
      ]),
      isFalse,
    );
    expect(
      isNewPr([
        [set(1, 100, 5)],
      ]),
      isFalse,
    );
  });

  test('historyItems: hoy arriba, sin el mismo día de la API, y sin red usa la última vez', () {
    const e = DayExerciseDto(
      id: 'x',
      exerciseName: 'Jalón',
      supersetGroupId: null,
    );
    final api = [
      ExerciseHistoryEntryDto(
        assignmentId: 'a',
        blockName: 'B',
        weekNumber: 3,
        blockDayId: 'hoy',
        date: DateTime.utc(2026, 10, 2),
        sets: [set(1, 55, 12)],
      ),
      ExerciseHistoryEntryDto(
        assignmentId: 'otro',
        blockName: 'Fuerza',
        weekNumber: 4,
        blockDayId: 'd1',
        date: DateTime.utc(2026, 8, 2, 15),
        sets: [set(1, 50, 12)],
      ),
    ];
    final items = historyItems(
      history: api,
      exercise: e,
      assignmentId: 'a',
      dayId: 'hoy',
      weekNumber: 3,
      today: [set(1, 55, 12)],
      now: DateTime.utc(2026, 10, 2),
    );
    expect(items.map((i) => i.title), [
      'Semana 3 · hoy',
      'Fuerza · S4 · 2 ago',
    ]);
    expect(items.first.isToday, isTrue);
    expect(items.last.inThisProgram, isFalse);

    final offline = historyItems(
      history: null,
      exercise: DayExerciseDto(
        id: 'x',
        exerciseName: 'Jalón',
        supersetGroupId: null,
        lastPerformance: last('a', 2),
      ),
      assignmentId: 'a',
      dayId: 'hoy',
      weekNumber: 3,
      today: const [],
      now: DateTime.utc(2026, 10, 2),
    );
    expect(offline.map((i) => i.title), ['Semana 2 · 25 sep']);
  });

  test('LastPerformanceDto y campos nuevos del ejercicio desde JSON', () {
    final e = DayExerciseDto.fromJson({
      'id': 'x',
      'exerciseId': 'ex1',
      'exerciseName': 'Jalón',
      'supersetGroupId': null,
      'exerciseDescription': 'Tirá hacia el pecho',
      'videoUrl': null,
      'exerciseVideoUrl': 'https://v',
      'lastPerformance': {
        'assignmentId': 'a',
        'weekNumber': 2,
        'date': '2026-09-25T15:00:00Z',
        'sets': [
          {
            'setNumber': 1,
            'weight': 50,
            'weightUnit': 'LB',
            'reps': 12,
            'rir': 1,
          },
        ],
      },
    });
    expect(e.exerciseId, 'ex1');
    expect(e.description, 'Tirá hacia el pecho');
    expect(e.techniqueVideoUrl, 'https://v');
    expect(e.lastPerformance!.weekNumber, 2);
    expect(e.lastPerformance!.sets.single.weightUnit, 'LB');
  });
}
