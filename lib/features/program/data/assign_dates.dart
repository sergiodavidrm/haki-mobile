import 'assignment_dtos.dart';
import 'program_schedule.dart';

// Lógica pura de "Asignar fechas": día de inicio + qué día de la semana se
// hace cada entreno. Se repite igual todas las semanas desde la que se elige
// ("Aplicar desde": S1 = todo el programa y el inicio; SN = de ahí en adelante,
// sin tocar las anteriores).

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

/// Día de la semana inicial de cada entreno: el que ya tenía asignado en la
/// semana [fromWeek] si todos tienen uno; si no, el reparto sugerido. Vacío si
/// hay más de 7.
Map<int, int> defaultWeekdays(AssignmentDetailDto p, [int fromWeek = 1]) {
  final days = trainingDaysOf(p).keys.toList();
  final current = {
    for (final m in mappingsForWeek(p, fromWeek)) m.dayNumber: m.weekDay,
  };
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

/// Entrenos ya hechos en la semana del programa que corre hoy: ya tienen fecha,
/// así que su día de la semana no se cambia. Solo si el cambio la incluye
/// ([fromWeek] es esta semana o el inicio; desde una semana siguiente no toca
/// nada hecho). Solo con fechas y día por entreno (si no, no hay día que fijar).
Set<int> lockedDays(AssignmentDetailDto p, DateTime today, [int fromWeek = 1]) {
  if (!p.hasDates || p.dayMappings.isEmpty) return const {};
  final n = weekNumberFor(p.startDate!, today);
  if (fromWeek > n) return const {};
  final week = p.weeks.where((w) => w.weekNumber == n).firstOrNull;
  if (week == null) return const {};
  final mapped = {for (final m in mappingsForWeek(p, n)) m.dayNumber};
  return {
    for (final d in week.days)
      if (d.sessionStatus == SessionStatus.completed &&
          mapped.contains(d.dayNumber))
        d.dayNumber,
  };
}

/// Se puede asignar [weekDay] a [dayNumber]: el entreno no está bloqueado y el
/// día no es de uno bloqueado (el intercambio de [pickWeekday] lo movería).
bool canPickWeekday(
  Map<int, int> map,
  Set<int> locked,
  int dayNumber,
  int weekDay,
) =>
    !locked.contains(dayNumber) &&
    !map.entries.any((e) => e.value == weekDay && locked.contains(e.key));

/// Último día del programa (mismo cálculo que el backend: semanas × 7 − 1).
DateTime endDateFor(DateTime start, int totalWeeks) =>
    start.add(Duration(days: (totalWeeks < 1 ? 1 : totalWeeks) * 7 - 1));

/// Primera fecha desde [start] (inclusive) que cae en [weekDay].
DateTime firstOn(DateTime start, int weekDay) =>
    start.add(Duration(days: (weekDay - start.weekday + 7) % 7));

/// Fechas de inicio que se pueden elegir. Sin entrenos hechos: desde hoy (o el
/// inicio que ya tenía). Con entrenos hechos, el programa tiene que seguir
/// en curso: inicio entre hoy y el día en que hoy sería el último del programa
/// (un inicio futuro lo mandaba a PRÓXIMO con entrenos ya hechos; uno muy
/// atrás lo daba por terminado). Misma regla en la API.
(DateTime, DateTime?) startRange(AssignmentDetailDto p, DateTime today) {
  final t = dateOnly(today);
  if (dayCountsOf(p).$1 > 0) {
    final weeks = p.totalWeeks < 1 ? 1 : p.totalWeeks;
    return (t.subtract(Duration(days: weeks * 7 - 1)), t);
  }
  final min = p.startDate != null && p.startDate!.isBefore(t)
      ? p.startDate!
      : t;
  return (min, null);
}

/// [d] se puede elegir como inicio (ver [startRange]).
bool canStartOn(AssignmentDetailDto p, DateTime today, DateTime d) {
  final (min, max) = startRange(p, today);
  if (max != null) return !d.isBefore(min) && !d.isAfter(max);
  return d == p.startDate || !d.isBefore(dateOnly(today));
}

/// Inicio propuesto: el que ya tiene, o el próximo lunes (hoy si es lunes).
DateTime defaultStart(AssignmentDetailDto p, DateTime today) {
  if (p.startDate != null) return p.startDate!;
  return firstOn(dateOnly(today), DateTime.monday);
}

/// Semanas que se pueden elegir en "Aplicar desde": S1 (todo el programa, y el
/// único que cambia el inicio) y de la que corre hoy en adelante. Vacío si no
/// hace falta elegir: sin fechas o sin días todavía, programa que no empezó o
/// de una sola semana.
List<int> fromWeekOptions(AssignmentDetailDto p, DateTime today) {
  final total = p.totalWeeks;
  if (!p.hasDates || p.dayMappings.isEmpty || total < 2) return const [];
  final t = dateOnly(today);
  if (p.startDate!.isAfter(t)) return const [];
  final n = weekNumberFor(p.startDate!, t);
  if (n > total) return const [];
  return [1, for (var w = n < 2 ? 2 : n; w <= total; w++) w];
}

/// "Aplicar desde" por defecto: la semana que corre hoy; si ya hiciste algún
/// entreno de esa semana, la siguiente (cambiar los días es para lo que viene).
int defaultFromWeek(AssignmentDetailDto p, DateTime today) {
  final options = fromWeekOptions(p, today);
  if (options.isEmpty) return 1;
  final n = weekNumberFor(p.startDate!, dateOnly(today));
  final week = p.weeks.where((w) => w.weekNumber == n).firstOrNull;
  final started =
      week?.days.any((d) => d.sessionStatus == SessionStatus.completed) ??
      false;
  final pick = started && options.contains(n + 1) ? n + 1 : n;
  return options.contains(pick) ? pick : 1;
}

/// Primera fecha de [weekDay] en la semana [fromWeek] del programa que empieza
/// en [start].
DateTime firstOnFromWeek(DateTime start, int fromWeek, int weekDay) =>
    firstOn(start.add(Duration(days: (fromWeek - 1) * 7)), weekDay);
