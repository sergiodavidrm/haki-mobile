import 'assignment_dtos.dart';

// Lógica pura (sin Flutter ni red) de "qué programa está en curso" y "qué
// toca hoy". Reglas en haki-mobile/CLAUDE.md § Programas y pantalla Hoy.

/// Fecha local de hoy normalizada como las de los DTOs (UTC a medianoche).
DateTime dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

class ProgramSections {
  const ProgramSections({
    this.current,
    this.upcoming = const [],
    this.past = const [],
  });

  /// EN CURSO. Sin fechas = modo "SIGUIENTE".
  final AssignmentSummaryDto? current;

  /// PRÓXIMO, en el orden en que se van a hacer.
  final List<AssignmentSummaryDto> upcoming;

  /// ANTERIORES, el más reciente primero.
  final List<AssignmentSummaryDto> past;

  int get count => (current == null ? 0 : 1) + upcoming.length + past.length;

  AssignmentSummaryDto? find(String assignmentId) => [
    ?current,
    ...upcoming,
    ...past,
  ].where((a) => a.assignmentId == assignmentId).firstOrNull;

  bool isPast(String assignmentId) =>
      past.any((a) => a.assignmentId == assignmentId);
}

ProgramSections classifyPrograms(
  List<AssignmentSummaryDto> all,
  DateTime today,
) {
  final t = dateOnly(today);
  final past = <AssignmentSummaryDto>[];
  final datedNow = <AssignmentSummaryDto>[];
  final datedFuture = <AssignmentSummaryDto>[];
  final undated = <AssignmentSummaryDto>[];

  for (final a in all) {
    if (a.status == 'completed' ||
        (a.endDate != null && a.endDate!.isBefore(t))) {
      past.add(a);
    } else if (a.status != 'active') {
      continue;
    } else if (!a.hasDates) {
      undated.add(a);
    } else if (a.startDate!.isAfter(t)) {
      datedFuture.add(a);
    } else {
      datedNow.add(a);
    }
  }

  // Los activos sin fechas se hacen en el orden en que el coach los activó
  final epoch = DateTime.fromMillisecondsSinceEpoch(0);
  undated.sort(
    (a, b) => (a.activatedAt ?? epoch).compareTo(b.activatedAt ?? epoch),
  );
  datedFuture.sort((a, b) => a.startDate!.compareTo(b.startDate!));
  past.sort(
    (a, b) => (b.endDate ?? b.blockUpdatedAt).compareTo(
      a.endDate ?? a.blockUpdatedAt,
    ),
  );

  // La API no deja superponer fechas, así que hay a lo sumo uno con fechas en curso
  final current = datedNow.isNotEmpty
      ? datedNow.first
      : (undated.isNotEmpty ? undated.first : null);
  final upcoming = [...datedFuture, ...undated.where((a) => a != current)];

  return ProgramSections(current: current, upcoming: upcoming, past: past);
}

/// Resultado de "qué toca hoy" dentro del programa en curso.
sealed class TodayPlan {
  const TodayPlan();
}

/// Hay un día para hacer. [isScheduledToday] false = programa sin fechas (modo
/// "SIGUIENTE"): es el próximo día sin completar, no uno con fecha de hoy.
class TrainingDay extends TodayPlan {
  const TrainingDay({
    required this.week,
    required this.day,
    required this.isScheduledToday,
  });

  final WeekDto week;
  final DayDto day;
  final bool isScheduledToday;
}

/// Hoy no hay entreno asignado. [next] = próximo día con mapping, si existe.
class RestDay extends TodayPlan {
  const RestDay({required this.week, this.next, this.nextDate});

  final WeekDto? week;
  final DayDto? next;
  final DateTime? nextDate;
}

/// Ya se hicieron todos los entrenos de esta semana (con fechas, sin mappings).
class WeekDone extends TodayPlan {
  const WeekDone({required this.week});

  final WeekDto week;
}

/// Pasó la última semana o se completaron todos los días.
class ProgramFinished extends TodayPlan {
  const ProgramFinished();
}

/// Día de la semana de cada entreno en la semana [weekNumber]: el juego con el
/// fromWeek más alto que no la pasa (igual que ProgramCalendar.Schedule en la
/// API). Vacío si el programa no tiene días asignados.
List<DayMappingDto> mappingsForWeek(AssignmentDetailDto p, int weekNumber) {
  var from = 0;
  for (final m in p.dayMappings) {
    if (m.fromWeek <= weekNumber && m.fromWeek > from) from = m.fromWeek;
  }
  return [
    for (final m in p.dayMappings)
      if (m.fromWeek == from) m,
  ];
}

/// Semana (1-based) en la que cae [today] para un programa con fecha de inicio.
int weekNumberFor(DateTime startDate, DateTime today) =>
    dateOnly(today).difference(startDate).inDays ~/ 7 + 1;

TodayPlan resolveToday(AssignmentDetailDto p, DateTime today) {
  final t = dateOnly(today);

  // Sin fechas: el primer día sin completar (ni marcado "no lo hago") de todo
  // el programa
  if (!p.hasDates) {
    for (final w in p.weeks) {
      for (final d in w.days) {
        if (!d.isResolved) {
          return TrainingDay(week: w, day: d, isScheduledToday: false);
        }
      }
    }
    return const ProgramFinished();
  }

  final weekNumber = weekNumberFor(p.startDate!, t);
  if (weekNumber > p.totalWeeks) return const ProgramFinished();
  final week = p.weeks.where((w) => w.weekNumber == weekNumber).firstOrNull;

  // Con fechas y día de la semana por entreno
  if (p.dayMappings.isNotEmpty) {
    final mapping = mappingsForWeek(
      p,
      weekNumber,
    ).where((m) => m.weekDay == t.weekday).firstOrNull;
    final day = mapping == null
        ? null
        : week?.days.where((d) => d.dayNumber == mapping.dayNumber).firstOrNull;
    if (week != null && day != null) {
      return TrainingDay(week: week, day: day, isScheduledToday: true);
    }
    final (next, nextDate) = _nextMapped(p, t);
    return RestDay(week: week, next: next, nextDate: nextDate);
  }

  // Con fechas sin mappings: el primer día sin completar de la semana actual.
  // Una semana que el coach todavía no creó cuenta como "lo está preparando".
  if (week == null) return const RestDay(week: null);
  for (final d in week.days) {
    if (!d.isResolved) {
      return TrainingDay(week: week, day: d, isScheduledToday: false);
    }
  }
  return WeekDone(week: week);
}

/// Próximo entreno con fecha después de [t] (busca hasta el final del programa).
(DayDto?, DateTime?) _nextMapped(AssignmentDetailDto p, DateTime t) {
  final end = p.startDate!.add(Duration(days: p.totalWeeks * 7));
  for (
    var d = t.add(const Duration(days: 1));
    d.isBefore(end);
    d = d.add(const Duration(days: 1))
  ) {
    final n = weekNumberFor(p.startDate!, d);
    final mapping = mappingsForWeek(
      p,
      n,
    ).where((m) => m.weekDay == d.weekday).firstOrNull;
    if (mapping == null) continue;
    final week = p.weeks.where((w) => w.weekNumber == n).firstOrNull;
    final day = week?.days
        .where((x) => x.dayNumber == mapping.dayNumber)
        .firstOrNull;
    if (day != null) return (day, d);
  }
  return (null, null);
}

/// none = sin entreno; done = hecho; planned = hay entreno sin hacer;
/// skipped = "No voy a hacer este día".
enum StripDayKind { none, done, planned, skipped }

class StripDay {
  const StripDay({
    required this.date,
    required this.kind,
    required this.isToday,
    this.isSelected = false,
    this.partialProgress,
  });

  final DateTime date;

  /// Día parcial (hecho con menos de la mitad de las series): parte hecha
  /// 0–1 para el anillo. null = no es parcial.
  final double? partialProgress;

  /// none = sin entreno ese día; planned = hay entreno sin completar.
  final StripDayKind kind;
  final bool isToday;

  /// El día que el atleta tocó en Hoy (hoy si no tocó ninguno).
  final bool isSelected;
}

DateTime _mondayOf(DateTime d) => d.subtract(Duration(days: d.weekday - 1));

/// Lunes a domingo de la semana calendario de [selected] (hoy si es null),
/// para programas con fechas y día de la semana por entreno. null si no aplica.
List<StripDay>? weekStrip(
  AssignmentDetailDto p,
  DateTime today, {
  DateTime? selected,
}) {
  if (!p.hasDates || p.dayMappings.isEmpty) return null;
  final t = dateOnly(today);
  final s = selected == null ? t : dateOnly(selected);
  final monday = _mondayOf(s);
  return [
    for (var i = 0; i < 7; i++)
      () {
        final d = monday.add(Duration(days: i));
        final day = _dayOn(p, d);
        return StripDay(
          date: d,
          kind: day == null
              ? StripDayKind.none
              : day.sessionStatus == SessionStatus.completed
              ? StripDayKind.done
              : day.isSkipped
              ? StripDayKind.skipped
              : StripDayKind.planned,
          isToday: d == t,
          isSelected: d == s,
          partialProgress: day?.partialProgress,
        );
      }(),
  ];
}

/// Se puede pasar a la semana anterior (-1) o siguiente (+1) de la tira sin
/// salir del programa (de la semana de inicio a la del último día).
bool canMoveStrip(AssignmentDetailDto p, DateTime selected, int delta) {
  if (!p.hasDates) return false;
  final target = _mondayOf(dateOnly(selected)).add(Duration(days: 7 * delta));
  final first = _mondayOf(p.startDate!);
  final last = _mondayOf(
    p.startDate!.add(
      Duration(days: (p.totalWeeks < 1 ? 1 : p.totalWeeks) * 7 - 1),
    ),
  );
  return !target.isBefore(first) && !target.isAfter(last);
}

DayDto? _dayOn(AssignmentDetailDto p, DateTime d) {
  if (d.isBefore(p.startDate!)) return null;
  final n = weekNumberFor(p.startDate!, d);
  final mapping = mappingsForWeek(
    p,
    n,
  ).where((m) => m.weekDay == d.weekday).firstOrNull;
  if (mapping == null) return null;
  final week = p.weeks.where((w) => w.weekNumber == n).firstOrNull;
  return week?.days.where((x) => x.dayNumber == mapping.dayNumber).firstOrNull;
}

// ---------------------------------------------------------------------------
// Tab Programa

/// Semana que se abre por defecto en el selector S1…SN: con fechas, la del
/// calendario (acotada al programa); sin fechas, la del primer día sin
/// completar (o la última si ya se hizo todo).
int currentWeekOf(AssignmentDetailDto p, DateTime today) {
  final total = p.totalWeeks < 1 ? 1 : p.totalWeeks;
  if (p.hasDates) {
    return weekNumberFor(p.startDate!, today).clamp(1, total);
  }
  for (final w in p.weeks) {
    if (w.days.any((d) => !d.isResolved)) {
      return w.weekNumber;
    }
  }
  return p.weeks.isEmpty ? 1 : p.weeks.last.weekNumber;
}

/// Fecha en la que toca [dayNumber] en la semana [weekNumber] (programas con
/// fechas y día de la semana por entreno). null si no aplica.
DateTime? dateOfDay(AssignmentDetailDto p, int weekNumber, int dayNumber) {
  if (!p.hasDates) return null;
  final m = mappingsForWeek(
    p,
    weekNumber,
  ).where((m) => m.dayNumber == dayNumber).firstOrNull;
  if (m == null) return null;
  final start = p.startDate!;
  final offset = (m.weekDay - start.weekday + 7) % 7;
  return start.add(Duration(days: (weekNumber - 1) * 7 + offset));
}

/// (completados, total) de entrenos de todo el programa.
(int, int) dayCountsOf(AssignmentDetailDto p) {
  final days = p.weeks.expand((w) => w.days);
  return (
    days.where((d) => d.sessionStatus == SessionStatus.completed).length,
    days.length,
  );
}

/// Un entreno (con ejercicios) y desde cuándo "tocaba" ([dueOn] null =
/// todavía no toca). Misma regla que haki-api `ProgramCalendar.DueDays`.
class DueDay {
  const DueDay({required this.weekNumber, required this.day, this.dueOn});

  final int weekNumber;
  final DayDto day;
  final DateTime? dueOn;

  bool get done => day.sessionStatus == SessionStatus.completed;
}

/// Días que cierran una semana sin fechas después de su primer entreno.
const undatedWeekDays = 7;

/// Regla única (2026-11-04) de qué entrenos ya tocaban:
/// - Con fechas y día de la semana por entreno: en su fecha (hoy solo si ya
///   se hizo).
/// - Con fechas sin días de la semana: los no hechos al terminar su semana de
///   calendario; los hechos, el día que se hicieron.
/// - Sin fechas: la semana cierra con lo primero que pase: hizo todos sus
///   días, entrenó un día de una semana posterior, o pasaron 7 días desde su
///   primer entreno. Los no hechos de una semana cerrada tocan ese día
///   (faltó); los hechos, el día que se hicieron.
List<DueDay> dueDaysOf(AssignmentDetailDto p, DateTime today) {
  final t = dateOnly(today);
  final days = [
    for (final w in p.weeks)
      for (final d in w.days)
        if (d.exercises.isNotEmpty) (week: w.weekNumber, day: d),
  ];
  DateTime? doneOn(DayDto d) => d.sessionStatus != SessionStatus.completed
      ? null
      : dateOnly((d.completedAt ?? d.startedAt ?? t).toLocal());

  if (p.hasDates && p.dayMappings.isNotEmpty) {
    return [
      for (final x in days)
        () {
          final date = dateOfDay(p, x.week, x.day.dayNumber);
          final done = x.day.sessionStatus == SessionStatus.completed;
          final due =
              date != null && (date.isBefore(t) || (date == t && done));
          return DueDay(weekNumber: x.week, day: x.day, dueOn: due ? date : null);
        }(),
    ];
  }

  if (p.hasDates) {
    final start = dateOnly(p.startDate!);
    return [
      for (final x in days)
        () {
          final on = doneOn(x.day);
          if (on != null) return DueDay(weekNumber: x.week, day: x.day, dueOn: on);
          final weekEnd = start.add(Duration(days: x.week * 7 - 1));
          return DueDay(
            weekNumber: x.week,
            day: x.day,
            dueOn: weekEnd.isBefore(t) ? weekEnd : null,
          );
        }(),
    ];
  }

  // Sin fechas: fecha en que cerró cada semana (solo las cerradas hasta hoy)
  final closes = <int, DateTime>{};
  for (final week in days.map((x) => x.week).toSet()) {
    final weekDays = days.where((x) => x.week == week).toList();
    final dates = weekDays.map((x) => doneOn(x.day)).nonNulls.toList()..sort();
    final later =
        days
            .where((x) => x.week > week)
            .map((x) => doneOn(x.day))
            .nonNulls
            .toList()
          ..sort();
    final candidates = [
      if (dates.length == weekDays.length && dates.isNotEmpty) dates.last,
      if (dates.isNotEmpty) dates.first.add(const Duration(days: undatedWeekDays)),
      if (later.isNotEmpty) later.first,
    ]..sort();
    if (candidates.isNotEmpty && !candidates.first.isAfter(t)) {
      closes[week] = candidates.first;
    }
  }
  return [
    for (final x in days)
      DueDay(
        weekNumber: x.week,
        day: x.day,
        dueOn: doneOn(x.day) ?? closes[x.week],
      ),
  ];
}

/// Adherencia del programa: (hechos, que ya tocaban) hasta [today], con la
/// regla de [dueDaysOf] (también en programas sin fechas).
(int, int) adherenceOf(AssignmentDetailDto p, DateTime today) {
  final due = dueDaysOf(p, today).where((d) => d.dueOn != null).toList();
  return (due.where((d) => d.done).length, due.length);
}

/// Duración del entreno si se sabe y es creíble (1 min – 6 h).
Duration? durationOf(DayDto d) {
  if (d.startedAt == null || d.completedAt == null) return null;
  final x = d.completedAt!.difference(d.startedAt!);
  return x.inMinutes < 1 || x.inHours >= 6 ? null : x;
}

enum DayRowKind {
  /// Completado → Sesión pasada.
  done,

  /// El que toca (hoy, o el siguiente sin fechas).
  next,

  /// Empezado y sin terminar (no es el que toca).
  inProgress,

  /// Sin hacer todavía.
  pending,

  /// "No voy a hacer este día" (✕ gris; deslizar de nuevo lo deshace).
  skipped,

  /// Sin ejercicios: "Tu coach lo está preparando".
  preparing,
}

class DayRow {
  const DayRow({
    required this.day,
    required this.kind,
    this.date,
    this.isToday = false,
  });

  final DayDto day;
  final DayRowKind kind;

  /// Hecho: cuándo se completó (o la fecha programada); si no, la programada.
  final DateTime? date;
  final bool isToday;
}

/// Filas de una semana del tab Programa. [highlightNext] solo para el
/// programa en curso (en uno terminado o próximo no hay "el que toca").
List<DayRow> weekRows(
  AssignmentDetailDto p,
  WeekDto week,
  DateTime today, {
  bool highlightNext = true,
}) {
  final t = dateOnly(today);
  final nextId = !highlightNext
      ? null
      : switch (resolveToday(p, today)) {
          TrainingDay(:final day) => day.id,
          RestDay(:final next) => next?.id,
          _ => null,
        };
  return [
    for (final d in week.days)
      () {
        final scheduled = dateOfDay(p, week.weekNumber, d.dayNumber);
        if (d.sessionStatus == SessionStatus.completed) {
          final doneOn = d.completedAt == null
              ? scheduled
              : dateOnly(d.completedAt!);
          return DayRow(day: d, kind: DayRowKind.done, date: doneOn);
        }
        if (d.isSkipped) {
          return DayRow(
            day: d,
            kind: DayRowKind.skipped,
            date: scheduled,
            isToday: scheduled == t,
          );
        }
        final kind = d.exercises.isEmpty
            ? DayRowKind.preparing
            : d.id == nextId
            ? DayRowKind.next
            : d.sessionStatus == SessionStatus.inProgress
            ? DayRowKind.inProgress
            : DayRowKind.pending;
        return DayRow(
          day: d,
          kind: kind,
          date: scheduled,
          isToday: scheduled == t,
        );
      }(),
  ];
}
