import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/program/data/assignment_dtos.dart';
import 'package:haki_mobile/features/program/data/program_schedule.dart';
import 'package:haki_mobile/features/program/providers/program_providers.dart';
import 'package:haki_mobile/features/session/data/session_store.dart';

DayDto day(
  int week,
  int n, {
  SessionStatus status = SessionStatus.pending,
  int exercises = 3,
  DateTime? startedAt,
  DateTime? completedAt,
}) => DayDto(
  id: 'w${week}d$n',
  dayNumber: n,
  name: null,
  sessionStatus: status,
  workoutSessionId: null,
  exercises: [
    for (var i = 0; i < exercises; i++)
      DayExerciseDto(id: 'e$i', exerciseName: 'Ej $i', supersetGroupId: null),
  ],
  startedAt: startedAt,
  completedAt: completedAt,
);

AssignmentDetailDto detail({
  DateTime? start,
  required List<WeekDto> weeks,
  List<DayMappingDto> mappings = const [],
}) => AssignmentDetailDto(
  assignmentId: 'a',
  blockName: 'Bloque',
  startDate: start,
  endDate: start?.add(Duration(days: weeks.length * 7 - 1)),
  numberOfWeeks: weeks.length,
  weeks: weeks,
  dayMappings: mappings,
  blockUpdatedAt: DateTime.utc(2026, 1, 1),
);

List<WeekDto> plainWeeks(int n, {Set<String> done = const {}}) => [
  for (var w = 1; w <= n; w++)
    WeekDto(
      weekNumber: w,
      days: [
        for (var d = 1; d <= 3; d++)
          day(
            w,
            d,
            status: done.contains('w${w}d$d')
                ? SessionStatus.completed
                : SessionStatus.pending,
          ),
      ],
    ),
];

// Lunes 28 sep 2026; el "hoy" de los tests es el viernes 2 oct 2026.
final monday = DateTime.utc(2026, 9, 28);
final friday = DateTime(2026, 10, 2, 9, 30);

// Lun / Mié / Vie
const mappings = [
  DayMappingDto(dayNumber: 1, weekDay: 1),
  DayMappingDto(dayNumber: 2, weekDay: 3),
  DayMappingDto(dayNumber: 3, weekDay: 5),
];

void main() {
  group('currentWeekOf', () {
    test('con fechas: semana del calendario, acotada al programa', () {
      final weeks = plainWeeks(4);
      final start = monday.subtract(const Duration(days: 14));
      expect(currentWeekOf(detail(start: start, weeks: weeks), friday), 3);
      // Antes de empezar → S1; después de terminar → la última
      expect(
        currentWeekOf(
          detail(start: monday.add(const Duration(days: 7)), weeks: weeks),
          friday,
        ),
        1,
      );
      expect(
        currentWeekOf(
          detail(start: DateTime.utc(2026, 1, 5), weeks: weeks),
          friday,
        ),
        4,
      );
    });

    test('sin fechas: la del primer día sin completar', () {
      final weeks = plainWeeks(3, done: {'w1d1', 'w1d2', 'w1d3', 'w2d1'});
      expect(currentWeekOf(detail(weeks: weeks), friday), 2);
      final all = plainWeeks(
        2,
        done: {'w1d1', 'w1d2', 'w1d3', 'w2d1', 'w2d2', 'w2d3'},
      );
      expect(currentWeekOf(detail(weeks: all), friday), 2);
    });
  });

  test('dateOfDay: inicio + semanas + día de la semana del mapping', () {
    // Empieza un miércoles: el día 1 (lunes) de la semana 1 cae el lunes siguiente
    final p = detail(
      start: DateTime.utc(2026, 9, 30),
      weeks: plainWeeks(2),
      mappings: mappings,
    );
    expect(dateOfDay(p, 1, 2), DateTime.utc(2026, 9, 30));
    expect(dateOfDay(p, 1, 3), DateTime.utc(2026, 10, 2));
    expect(dateOfDay(p, 1, 1), DateTime.utc(2026, 10, 5));
    expect(dateOfDay(p, 2, 2), DateTime.utc(2026, 10, 7));
    expect(dateOfDay(detail(weeks: plainWeeks(1)), 1, 1), isNull);
  });

  group('weekRows', () {
    test('con fechas: hecho, el de hoy, pendiente y en preparación', () {
      final p = detail(
        start: monday,
        weeks: [
          WeekDto(
            weekNumber: 1,
            days: [
              day(1, 1, status: SessionStatus.completed),
              day(1, 2, exercises: 0),
              day(1, 3),
            ],
          ),
          WeekDto(weekNumber: 2, days: [day(2, 1), day(2, 2), day(2, 3)]),
        ],
        mappings: mappings,
      );
      final rows = weekRows(p, p.weeks[0], friday);
      expect(rows.map((r) => r.kind), [
        DayRowKind.done,
        DayRowKind.preparing,
        DayRowKind.next,
      ]);
      expect(rows[0].date, monday);
      expect(rows[2].isToday, isTrue);

      final next = weekRows(p, p.weeks[1], friday);
      expect(next.map((r) => r.kind), everyElement(DayRowKind.pending));
      expect(next[0].date, DateTime.utc(2026, 10, 5));
    });

    test('día de descanso: resalta el próximo entreno', () {
      final p = detail(
        start: monday,
        weeks: plainWeeks(2),
        mappings: const [
          DayMappingDto(dayNumber: 1, weekDay: 1),
          DayMappingDto(dayNumber: 2, weekDay: 3),
          DayMappingDto(dayNumber: 3, weekDay: 6),
        ],
      );
      final rows = weekRows(p, p.weeks[0], friday);
      expect(rows[2].kind, DayRowKind.next);
      expect(rows[2].isToday, isFalse);
    });

    test('sin fechas: el siguiente es el primero sin completar', () {
      final p = detail(weeks: plainWeeks(2, done: {'w1d1'}));
      final rows = weekRows(p, p.weeks[0], friday);
      expect(rows.map((r) => r.kind), [
        DayRowKind.done,
        DayRowKind.next,
        DayRowKind.pending,
      ]);
      expect(rows[1].date, isNull);
    });

    test('hecho: la fecha es cuando se completó', () {
      final p = detail(
        start: monday,
        weeks: [
          WeekDto(
            weekNumber: 1,
            days: [
              day(
                1,
                1,
                status: SessionStatus.completed,
                completedAt: DateTime(2026, 9, 29, 19),
              ),
            ],
          ),
        ],
        mappings: mappings,
      );
      expect(
        weekRows(p, p.weeks[0], friday).single.date,
        DateTime.utc(2026, 9, 29),
      );
    });

    test('programa que no está en curso: sin "el que toca"', () {
      final p = detail(weeks: plainWeeks(1));
      final rows = weekRows(p, p.weeks[0], friday, highlightNext: false);
      expect(rows.map((r) => r.kind), everyElement(DayRowKind.pending));
    });
  });

  test('durationOf descarta lo no creíble', () {
    final s = DateTime(2026, 10, 2, 18);
    Duration? of(Duration d) =>
        durationOf(day(1, 1, startedAt: s, completedAt: s.add(d)));
    expect(of(const Duration(minutes: 58)), const Duration(minutes: 58));
    expect(of(const Duration(seconds: 20)), isNull);
    expect(of(const Duration(hours: 7)), isNull);
  });

  test('mergeLocalSessions: lo local manda salvo completado en la API', () {
    final remote = detail(
      weeks: [
        WeekDto(
          weekNumber: 1,
          days: [
            day(1, 1, status: SessionStatus.completed),
            day(1, 2),
            day(1, 3),
          ],
        ),
      ],
    );
    final started = DateTime(2026, 10, 2, 18);
    final merged = mergeLocalSessions(remote, [
      LocalSessionInfo(dayId: 'w1d1', startedAt: started),
      LocalSessionInfo(dayId: 'w1d2', startedAt: started),
      LocalSessionInfo(
        dayId: 'w1d3',
        startedAt: started,
        completedAt: started.add(const Duration(minutes: 50)),
      ),
    ]);
    final days = merged.weeks.single.days;
    expect(days.map((d) => d.sessionStatus), [
      SessionStatus.completed,
      SessionStatus.inProgress,
      SessionStatus.completed,
    ]);
    expect(durationOf(days[2]), const Duration(minutes: 50));
    expect(dayCountsOf(merged), (2, 3));
  });
}
