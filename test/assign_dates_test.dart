import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/program/data/assign_dates.dart';
import 'package:haki_mobile/features/program/data/assignment_dtos.dart';
import 'package:haki_mobile/features/program/data/program_schedule.dart';

DayDto day(int n, {String? name}) => DayDto(
  id: 'd$n',
  dayNumber: n,
  name: name,
  sessionStatus: SessionStatus.pending,
  workoutSessionId: null,
  exercises: const [],
);

AssignmentDetailDto detail(
  List<List<DayDto>> weeks, {
  List<DayMappingDto> mappings = const [],
  DateTime? start,
}) => AssignmentDetailDto(
  assignmentId: 'a',
  blockName: 'Bloque',
  startDate: start,
  endDate: null,
  numberOfWeeks: weeks.length,
  weeks: [
    for (var i = 0; i < weeks.length; i++)
      WeekDto(weekNumber: i + 1, days: weeks[i]),
  ],
  dayMappings: mappings,
  blockUpdatedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  test('trainingDaysOf: todos los DayNumber, con el nombre de la 1.ª vez', () {
    final p = detail([
      [day(2, name: 'Pecho'), day(1, name: 'Pierna')],
      [day(1), day(2), day(3, name: 'Espalda')],
    ]);
    expect(trainingDaysOf(p), {
      1: 'Día 1 · Pierna',
      2: 'Día 2 · Pecho',
      3: 'Día 3 · Espalda',
    });
  });

  test('defaultWeekdays: respeta los que ya tenía, si no reparte', () {
    final days = [
      [day(1), day(2), day(3), day(4)],
    ];
    expect(defaultWeekdays(detail(days)), {1: 1, 2: 2, 3: 4, 4: 5});
    final mapped = detail(
      days,
      mappings: const [
        DayMappingDto(dayNumber: 1, weekDay: 2),
        DayMappingDto(dayNumber: 2, weekDay: 3),
        DayMappingDto(dayNumber: 3, weekDay: 5),
        DayMappingDto(dayNumber: 4, weekDay: 6),
      ],
    );
    expect(defaultWeekdays(mapped), {1: 2, 2: 3, 3: 5, 4: 6});
    // Más de 7 entrenos por semana no se pueden mapear
    expect(
      defaultWeekdays(
        detail([
          [for (var i = 1; i <= 8; i++) day(i)],
        ]),
      ),
      isEmpty,
    );
  });

  test('pickWeekday intercambia si el día ya estaba ocupado', () {
    expect(pickWeekday({1: 1, 2: 3}, 1, 3), {1: 3, 2: 1});
    expect(pickWeekday({1: 1, 2: 3}, 1, 6), {1: 6, 2: 3});
  });

  test('fechas: fin, primera ocurrencia e inicio propuesto', () {
    final mon = DateTime.utc(2026, 10, 26);
    expect(endDateFor(mon, 4), DateTime.utc(2026, 11, 22));
    expect(firstOn(mon, DateTime.saturday), DateTime.utc(2026, 10, 31));
    expect(firstOn(mon, DateTime.monday), mon);
    // Viernes 23 → lunes 26
    expect(defaultStart(detail([]), DateTime(2026, 10, 23, 8)), mon);
    final withStart = detail([], start: DateTime.utc(2026, 9, 14));
    expect(
      defaultStart(withStart, DateTime(2026, 10, 23)),
      DateTime.utc(2026, 9, 14),
    );
  });

  group('días bloqueados (hechos esta semana)', () {
    final start = DateTime.utc(2026, 10, 26); // lunes
    DayDto done(int n) => DayDto(
      id: 'd$n',
      dayNumber: n,
      name: null,
      sessionStatus: SessionStatus.completed,
      workoutSessionId: 's$n',
      exercises: const [],
    );
    const mappings = [
      DayMappingDto(dayNumber: 1, weekDay: 1),
      DayMappingDto(dayNumber: 2, weekDay: 3),
      DayMappingDto(dayNumber: 3, weekDay: 5),
    ];
    final p = detail(
      [
        [day(1), day(2), done(3)],
        [day(1), day(2), day(3)],
      ],
      mappings: mappings,
      start: start,
    );

    test('semana 1 con el día 3 hecho: queda fijo', () {
      expect(lockedDays(p, DateTime(2026, 10, 31)), {3});
    });

    test('en la semana 2 ya se puede cambiar', () {
      expect(lockedDays(p, DateTime(2026, 11, 3)), isEmpty);
    });

    test('nadie puede tomar el día de uno bloqueado', () {
      final map = {1: 1, 2: 3, 3: 5};
      expect(canPickWeekday(map, {3}, 3, 6), isFalse);
      expect(canPickWeekday(map, {3}, 1, 5), isFalse);
      expect(canPickWeekday(map, {3}, 1, 2), isTrue);
      expect(canPickWeekday(map, {3}, 1, 3), isTrue);
    });

    test('sin fechas no hay nada bloqueado', () {
      final undated = detail([
        [done(1)],
      ]);
      expect(lockedDays(undated, DateTime(2026, 10, 31)), isEmpty);
    });
  });

  group('aplicar desde una semana', () {
    // Caso de Sergio: empieza martes 27-oct, 2 semanas, hoy lunes 2-nov
    // (último día de la semana 1) con entrenos hechos.
    final start = DateTime.utc(2026, 10, 27);
    DayDto done(int n) => DayDto(
      id: 'w1d$n',
      dayNumber: n,
      name: null,
      sessionStatus: SessionStatus.completed,
      workoutSessionId: 's$n',
      exercises: const [],
    );
    const week1 = [
      DayMappingDto(dayNumber: 1, weekDay: 2),
      DayMappingDto(dayNumber: 2, weekDay: 3),
    ];
    final p = detail(
      [
        [done(1), day(2)],
        [day(1), day(2)],
      ],
      mappings: week1,
      start: start,
    );
    final today = DateTime(2026, 11, 2);

    test('opciones: S1 y desde la semana actual; por defecto la siguiente', () {
      expect(fromWeekOptions(p, today), [1, 2]);
      expect(defaultFromWeek(p, today), 2);
    });

    test('desde la semana 2 no hay candados', () {
      expect(lockedDays(p, today, 2), isEmpty);
      expect(lockedDays(p, today), {1});
    });

    test('sin empezar, sin fechas o de una semana no se elige', () {
      expect(fromWeekOptions(p, DateTime(2026, 10, 20)), isEmpty);
      expect(
        fromWeekOptions(
          detail(
            [
              [day(1)],
            ],
            mappings: week1,
            start: start,
          ),
          today,
        ),
        isEmpty,
      );
      expect(
        defaultFromWeek(
          detail([
            [day(1)],
            [day(1)],
          ]),
          today,
        ),
        1,
      );
    });

    test('cada semana usa su juego de días', () {
      final changed = detail(
        [
          [done(1), day(2)],
          [day(1), day(2)],
        ],
        mappings: const [
          ...week1,
          DayMappingDto(dayNumber: 1, weekDay: 1, fromWeek: 2),
          DayMappingDto(dayNumber: 2, weekDay: 4, fromWeek: 2),
        ],
        start: start,
      );
      expect(defaultWeekdays(changed), {1: 2, 2: 3});
      expect(defaultWeekdays(changed, 2), {1: 1, 2: 4});
      // Semana 1 intacta; semana 2 (mar 3 → lun 9): lunes 9 y jueves 5
      expect(dateOfDay(changed, 1, 2), DateTime.utc(2026, 10, 28));
      expect(dateOfDay(changed, 2, 1), DateTime.utc(2026, 11, 9));
      expect(dateOfDay(changed, 2, 2), DateTime.utc(2026, 11, 5));
      expect(
        firstOnFromWeek(start, 2, DateTime.monday),
        DateTime.utc(2026, 11, 9),
      );
    });
  });

  test('con entrenos hechos el inicio no puede ir al futuro', () {
    // Caso real: elegir el 4-nov desde S1 mandó el programa a PRÓXIMO
    final p = detail(
      [
        [
          DayDto(
            id: 'x',
            dayNumber: 1,
            name: null,
            sessionStatus: SessionStatus.completed,
            workoutSessionId: 's',
            exercises: const [],
          ),
        ],
        [day(1)],
      ],
      mappings: const [DayMappingDto(dayNumber: 1, weekDay: 2)],
      start: DateTime.utc(2026, 11, 4),
    );
    final today = DateTime(2026, 11, 2);
    expect(canStartOn(p, today, DateTime.utc(2026, 11, 4)), isFalse);
    expect(canStartOn(p, today, DateTime.utc(2026, 10, 27)), isTrue);
    expect(canStartOn(p, today, DateTime.utc(2026, 10, 20)), isTrue);
    expect(canStartOn(p, today, DateTime.utc(2026, 10, 19)), isFalse);
    // Sin entrenos hechos sigue como antes: desde hoy
    final fresh = detail([
      [day(1)],
    ], start: DateTime.utc(2026, 11, 4));
    expect(canStartOn(fresh, today, DateTime.utc(2026, 11, 9)), isTrue);
    expect(canStartOn(fresh, today, DateTime.utc(2026, 10, 27)), isFalse);
  });
}
