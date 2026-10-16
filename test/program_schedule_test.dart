import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/program/data/assignment_dtos.dart';
import 'package:haki_mobile/features/program/data/program_schedule.dart';

AssignmentSummaryDto summary(
  String id, {
  String status = 'active',
  DateTime? start,
  DateTime? end,
  DateTime? activatedAt,
}) => AssignmentSummaryDto(
  assignmentId: id,
  blockName: id,
  status: status,
  startDate: start,
  endDate: end,
  totalWeeks: 4,
  completedWeeks: 0,
  blockUpdatedAt: DateTime.utc(2026, 1, 1),
  activatedAt: activatedAt,
);

DayDto day(
  int n, {
  SessionStatus status = SessionStatus.pending,
  int exercises = 3,
}) => DayDto(
  id: 'd$n',
  dayNumber: n,
  name: null,
  sessionStatus: status,
  workoutSessionId: null,
  exercises: [
    for (var i = 0; i < exercises; i++)
      DayExerciseDto(id: 'e$i', exerciseName: 'Ej $i', supersetGroupId: null),
  ],
);

AssignmentDetailDto detail({
  DateTime? start,
  List<WeekDto>? weeks,
  List<DayMappingDto> mappings = const [],
}) => AssignmentDetailDto(
  assignmentId: 'a',
  blockName: 'Bloque',
  startDate: start,
  endDate: start?.add(const Duration(days: 27)),
  numberOfWeeks: 4,
  weeks:
      weeks ??
      [
        for (var w = 1; w <= 4; w++)
          WeekDto(weekNumber: w, days: [day(1), day(2), day(3)]),
      ],
  dayMappings: mappings,
  blockUpdatedAt: DateTime.utc(2026, 1, 1),
);

// Lunes 28 sep 2026 … el "hoy" de los tests es el viernes 2 oct 2026.
final monday = DateTime.utc(2026, 9, 28);
final friday = DateTime(2026, 10, 2, 9, 30);

void main() {
  group('classifyPrograms', () {
    test(
      'con fechas y hoy en rango es EN CURSO; sin fechas pasa a PRÓXIMO',
      () {
        final s = classifyPrograms([
          summary('sinFechas', activatedAt: DateTime.utc(2026, 9, 1)),
          summary(
            'conFechas',
            start: DateTime.utc(2026, 9, 14),
            end: DateTime.utc(2026, 10, 25),
          ),
        ], friday);
        expect(s.current?.assignmentId, 'conFechas');
        expect(s.upcoming.map((a) => a.assignmentId), ['sinFechas']);
      },
    );

    test(
      'sin ninguno con fechas en curso, el sin fechas más antiguo es EN CURSO',
      () {
        final s = classifyPrograms([
          summary('nuevo', activatedAt: DateTime.utc(2026, 9, 20)),
          summary('viejo', activatedAt: DateTime.utc(2026, 9, 1)),
          summary(
            'futuro',
            start: DateTime.utc(2026, 11, 2),
            end: DateTime.utc(2026, 11, 29),
          ),
        ], friday);
        expect(s.current?.assignmentId, 'viejo');
        expect(s.upcoming.map((a) => a.assignmentId), ['futuro', 'nuevo']);
      },
    );

    test('completados y con fin pasado van a ANTERIORES', () {
      final s = classifyPrograms([
        summary('hecho', status: 'completed'),
        summary(
          'vencido',
          start: DateTime.utc(2026, 8, 1),
          end: DateTime.utc(2026, 8, 28),
        ),
      ], friday);
      expect(s.current, isNull);
      expect(s.past.length, 2);
    });
  });

  group('resolveToday', () {
    test(
      'con mappings: hoy viernes = día mapeado a FRI de la semana actual',
      () {
        final p = detail(
          start: DateTime.utc(2026, 9, 21),
          mappings: const [
            DayMappingDto(dayNumber: 1, weekDay: 1),
            DayMappingDto(dayNumber: 2, weekDay: 3),
            DayMappingDto(dayNumber: 3, weekDay: 5),
          ],
        );
        final plan = resolveToday(p, friday);
        expect(plan, isA<TrainingDay>());
        plan as TrainingDay;
        expect(plan.week.weekNumber, 2);
        expect(plan.day.dayNumber, 3);
        expect(plan.isScheduledToday, isTrue);
      },
    );

    test('con mappings y sin entreno hoy: descanso con el próximo día', () {
      final p = detail(
        start: monday,
        mappings: const [
          DayMappingDto(dayNumber: 1, weekDay: 1),
          DayMappingDto(dayNumber: 2, weekDay: 6),
        ],
      );
      final plan = resolveToday(p, friday) as RestDay;
      expect(plan.next?.dayNumber, 2);
      expect(plan.nextDate, DateTime.utc(2026, 10, 3));
    });

    test('con fechas sin mappings: primer día sin completar de la semana', () {
      final p = detail(
        start: monday,
        weeks: [
          WeekDto(
            weekNumber: 1,
            days: [
              day(1, status: SessionStatus.completed),
              day(2),
              day(3),
            ],
          ),
        ],
      );
      final plan = resolveToday(p, friday) as TrainingDay;
      expect(plan.day.dayNumber, 2);
      expect(plan.isScheduledToday, isFalse);
    });

    test('con fechas sin mappings y todo hecho: semana completa', () {
      final p = detail(
        start: monday,
        weeks: [
          WeekDto(
            weekNumber: 1,
            days: [day(1, status: SessionStatus.completed)],
          ),
        ],
      );
      expect(resolveToday(p, friday), isA<WeekDone>());
    });

    test('sin fechas: primer día sin completar de todo el programa', () {
      final p = detail(
        weeks: [
          WeekDto(
            weekNumber: 1,
            days: [day(1, status: SessionStatus.completed)],
          ),
          WeekDto(
            weekNumber: 2,
            days: [
              day(1, status: SessionStatus.inProgress),
              day(2),
            ],
          ),
        ],
      );
      final plan = resolveToday(p, friday) as TrainingDay;
      expect(plan.week.weekNumber, 2);
      expect(plan.day.dayNumber, 1);
    });

    test('después de la última semana: programa terminado', () {
      final p = detail(start: DateTime.utc(2026, 8, 1));
      expect(resolveToday(p, friday), isA<ProgramFinished>());
    });
  });

  test('weekStrip marca hechos, planificados y hoy', () {
    final p = detail(
      start: monday,
      weeks: [
        WeekDto(
          weekNumber: 1,
          days: [
            day(1, status: SessionStatus.completed),
            day(2),
          ],
        ),
      ],
      mappings: const [
        DayMappingDto(dayNumber: 1, weekDay: 1),
        DayMappingDto(dayNumber: 2, weekDay: 5),
      ],
    );
    final strip = weekStrip(p, friday)!;
    expect(strip.map((d) => d.kind), [
      StripDayKind.done,
      StripDayKind.none,
      StripDayKind.none,
      StripDayKind.none,
      StripDayKind.planned,
      StripDayKind.none,
      StripDayKind.none,
    ]);
    expect(strip[4].isToday, isTrue);
  });
}
