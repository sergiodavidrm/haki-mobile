import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/program/data/assign_dates.dart';
import 'package:haki_mobile/features/program/data/assignment_dtos.dart';

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
}
