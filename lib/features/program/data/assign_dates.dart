import 'assignment_dtos.dart';
import 'program_schedule.dart';

// Lógica pura de "Asignar fechas": día de inicio + qué día de la semana se
// hace cada entreno (se repite igual todas las semanas).

/// Entrenos del programa (DayNumber) con su título, en orden. Toma el nombre
/// de la primera semana en la que aparece cada uno.
Map<int, String> trainingDaysOf(AssignmentDetailDto p) {
  final titles = <int, String>{};
  for (final w in p.weeks) {
    for (final d in w.days) {
      titles.putIfAbsent(d.dayNumber, () => d.title);
    }
  }
  return Map.fromEntries(
    titles.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

// Reparto sugerido según cuántos entrenos por semana (1 = lunes … 7 = domingo)
const _spread = {
  1: [1],
  2: [1, 4],
  3: [1, 3, 5],
  4: [1, 2, 4, 5],
  5: [1, 2, 3, 4, 5],
  6: [1, 2, 3, 4, 5, 6],
  7: [1, 2, 3, 4, 5, 6, 7],
};

/// Día de la semana inicial de cada entreno: el que ya tenía asignado si
/// todos tienen uno; si no, el reparto sugerido. Vacío si hay más de 7.
Map<int, int> defaultWeekdays(AssignmentDetailDto p) {
  final days = trainingDaysOf(p).keys.toList();
  final current = {for (final m in p.dayMappings) m.dayNumber: m.weekDay};
  if (days.isNotEmpty && days.every(current.containsKey)) {
    return {for (final d in days) d: current[d]!};
  }
  final spread = _spread[days.length];
  if (spread == null) return const {};
  return {for (var i = 0; i < days.length; i++) days[i]: spread[i]};
}

/// Asigna [weekDay] a [dayNumber]; si otro entreno ya lo tenía, intercambian.
Map<int, int> pickWeekday(Map<int, int> map, int dayNumber, int weekDay) {
  final old = map[dayNumber];
  return {
    for (final e in map.entries)
      e.key: e.key == dayNumber
          ? weekDay
          : (e.value == weekDay && old != null ? old : e.value),
  };
}

/// Último día del programa (mismo cálculo que el backend: semanas × 7 − 1).
DateTime endDateFor(DateTime start, int totalWeeks) =>
    start.add(Duration(days: (totalWeeks < 1 ? 1 : totalWeeks) * 7 - 1));

/// Primera fecha desde [start] (inclusive) que cae en [weekDay].
DateTime firstOn(DateTime start, int weekDay) =>
    start.add(Duration(days: (weekDay - start.weekday + 7) % 7));

/// Inicio propuesto: el que ya tiene, o el próximo lunes (hoy si es lunes).
DateTime defaultStart(AssignmentDetailDto p, DateTime today) {
  if (p.startDate != null) return p.startDate!;
  return firstOn(dateOnly(today), DateTime.monday);
}
