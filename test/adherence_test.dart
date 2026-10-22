import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/profile/data/adherence.dart';
import 'package:haki_mobile/features/program/data/assignment_dtos.dart';
import 'package:haki_mobile/features/program/data/program_schedule.dart';

DayDto day(int n, {bool done = false, int exercises = 1, int logged = 3}) =>
    DayDto(
      id: 'd$n',
      dayNumber: n,
      name: null,
      sessionStatus: done ? SessionStatus.completed : SessionStatus.pending,
      workoutSessionId: null,
      exercises: [
        for (var i = 0; i < exercises; i++)
          DayExerciseDto(
            id: 'e$n$i',
            exerciseName: 'Ej',
            supersetGroupId: null,
            targetSets: [
              for (var s = 1; s <= 3; s++)
                TargetSetDto(
                  setNumber: s,
                  weightKg: null,
                  reps: 10,
                  rir: null,
                  requestVideo: false,
                ),
            ],
            loggedSets: [
              if (done)
                for (var s = 1; s <= logged; s++)
                  LoggedSetDto(
                    id: 'l$s',
                    setNumber: s,
                    weightKg: 50,
                    weightUnit: 'KG',
                    reps: 10,
                    rir: null,
                  ),
            ],
          ),
      ],
    );

AssignmentDetailDto program(List<WeekDto> weeks, {bool dates = true}) =>
    AssignmentDetailDto(
      assignmentId: 'a',
      blockName: 'Bloque',
      startDate: dates ? DateTime.utc(2026, 9, 28) : null, // lunes
      endDate: dates ? DateTime.utc(2026, 10, 11) : null,
      numberOfWeeks: weeks.length,
      weeks: weeks,
      dayMappings: dates
          ? const [
              DayMappingDto(dayNumber: 1, weekDay: 1),
              DayMappingDto(dayNumber: 2, weekDay: 3),
              DayMappingDto(dayNumber: 3, weekDay: 5),
            ]
          : const [],
      blockUpdatedAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  final friday = dateOnly(DateTime(2026, 10, 2)); // semana 1, día 3 = hoy

  test('con calendario: hecho, no se hizo, hoy y pendiente', () {
    final r = adherenceReport(
      program([
        WeekDto(
          weekNumber: 1,
          days: [day(1, done: true, logged: 2), day(2), day(3)],
        ),
        WeekDto(weekNumber: 2, days: [day(1), day(2), day(3, exercises: 0)]),
      ]),
      friday,
    );
    expect(r.weeks.first.cells, [
      AdherenceCell.done,
      AdherenceCell.missed,
      AdherenceCell.today,
    ]);
    expect(r.weeks.last.cells, [
      AdherenceCell.pending,
      AdherenceCell.pending,
    ]); // día sin ejercicios no cuenta
    expect(r.weeks.last.started, isFalse);
    expect((r.done, r.due, r.total), (1, 3, 5));
    expect(r.percent, 33);
    expect((r.setsDone, r.setsTarget), (2, 3));
    expect(r.missed.single.day.id, 'd2');
  });

  test('sin calendario: hechos sobre el total', () {
    final r = adherenceReport(
      program([
        WeekDto(
          weekNumber: 1,
          days: [day(1, done: true), day(2, done: true), day(3)],
        ),
      ], dates: false),
      friday,
    );
    expect(r.due, isNull);
    expect(r.percent, 67);
    expect(r.weeks.single.cells.last, AdherenceCell.pending);
    expect(r.missed, isEmpty);
    expect((r.setsDone, r.setsTarget), (6, 6));
  });
}
