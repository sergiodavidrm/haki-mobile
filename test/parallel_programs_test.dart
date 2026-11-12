import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/program/data/assignment_dtos.dart';
import 'package:haki_mobile/features/program/data/program_schedule.dart';

// Programas en paralelo (2026-11-11): varios con fechas en curso a la vez,
// los sin fechas de a uno, y una sola tira de la semana.

AssignmentSummaryDto a(
  String id, {
  DateTime? start,
  DateTime? end,
  DateTime? activatedAt,
}) => AssignmentSummaryDto(
  assignmentId: id,
  blockName: id,
  status: 'active',
  startDate: start,
  endDate: end,
  totalWeeks: 4,
  completedWeeks: 0,
  blockUpdatedAt: DateTime.utc(2026, 1, 1),
  activatedAt: activatedAt,
);

StripDay d(int i, StripDayKind kind, {double? partial}) => StripDay(
  date: DateTime.utc(2026, 11, 9 + i),
  kind: kind,
  isToday: i == 2,
  partialProgress: partial,
);

void main() {
  final today = DateTime(2026, 11, 11);

  test('dos con fechas que cubren hoy quedan en curso, por activación', () {
    final s = classifyPrograms([
      a('movilidad', start: DateTime.utc(2026, 11, 9), end: DateTime.utc(2026, 12, 6), activatedAt: DateTime.utc(2026, 11, 8)),
      a('fuerza', start: DateTime.utc(2026, 10, 26), end: DateTime.utc(2026, 11, 15), activatedAt: DateTime.utc(2026, 10, 25)),
    ], today);
    expect(s.currents.map((x) => x.assignmentId), ['fuerza', 'movilidad']);
    expect(s.current?.assignmentId, 'fuerza');
    expect(s.isCurrent('movilidad'), isTrue);
  });

  test('los sin fechas siguen de a uno y no se suman a los con fechas', () {
    final s = classifyPrograms([
      a('fuerza', start: DateTime.utc(2026, 10, 26), end: DateTime.utc(2026, 11, 15)),
      a('b', activatedAt: DateTime.utc(2026, 10, 1)),
      a('c', activatedAt: DateTime.utc(2026, 10, 2)),
    ], today);
    expect(s.currents.map((x) => x.assignmentId), ['fuerza']);
    expect(s.upcoming.map((x) => x.assignmentId), ['b', 'c']);

    final undated = classifyPrograms([
      a('c', activatedAt: DateTime.utc(2026, 10, 2)),
      a('b', activatedAt: DateTime.utc(2026, 10, 1)),
    ], today);
    expect(undated.currents.map((x) => x.assignmentId), ['b']);
    expect(undated.upcoming.map((x) => x.assignmentId), ['c']);
  });

  test('tira combinada: hecho solo con todos; 1/2 si falta uno', () {
    final fuerza = [
      d(0, StripDayKind.done), d(1, StripDayKind.done), d(2, StripDayKind.done),
      d(3, StripDayKind.planned), d(4, StripDayKind.none), d(5, StripDayKind.none), d(6, StripDayKind.none),
    ];
    final movilidad = [
      d(0, StripDayKind.done), d(1, StripDayKind.none), d(2, StripDayKind.planned),
      d(3, StripDayKind.none), d(4, StripDayKind.planned), d(5, StripDayKind.none), d(6, StripDayKind.none),
    ];
    final s = combineStrips([fuerza, movilidad])!;
    expect(s[0].kind, StripDayKind.done);
    expect(s[1].kind, StripDayKind.done);
    expect(s[2].kind, StripDayKind.planned);
    expect(s[2].fraction, (1, 2));
    expect(s[3].kind, StripDayKind.planned);
    expect(s[3].fraction, isNull);
    expect(s[4].kind, StripDayKind.planned);
    expect(s[5].kind, StripDayKind.none);
  });

  test('con un solo programa la tira es la misma', () {
    final one = [d(0, StripDayKind.done, partial: .4)];
    expect(combineStrips([one, null]), same(one));
    expect(combineStrips([null]), isNull);
  });
}
