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

/// Semana (1-based) en la que cae [today] para un programa con fecha de inicio.
int weekNumberFor(DateTime startDate, DateTime today) =>
    dateOnly(today).difference(startDate).inDays ~/ 7 + 1;

TodayPlan resolveToday(AssignmentDetailDto p, DateTime today) {
  final t = dateOnly(today);

  // Sin fechas: el primer día sin completar de todo el programa
  if (!p.hasDates) {
    for (final w in p.weeks) {
      for (final d in w.days) {
        if (d.sessionStatus != SessionStatus.completed) {
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
    final mapping = p.dayMappings
        .where((m) => m.weekDay == t.weekday)
        .firstOrNull;
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
    if (d.sessionStatus != SessionStatus.completed) {
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
    final mapping = p.dayMappings
        .where((m) => m.weekDay == d.weekday)
        .firstOrNull;
    if (mapping == null) continue;
    final week = p.weeks
        .where((w) => w.weekNumber == weekNumberFor(p.startDate!, d))
        .firstOrNull;
    final day = week?.days
        .where((x) => x.dayNumber == mapping.dayNumber)
        .firstOrNull;
    if (day != null) return (day, d);
  }
  return (null, null);
}

enum StripDayKind { none, done, planned }

class StripDay {
  const StripDay({
    required this.date,
    required this.kind,
    required this.isToday,
  });

  final DateTime date;

  /// none = sin entreno ese día; planned = hay entreno sin completar.
  final StripDayKind kind;
  final bool isToday;
}

/// Lunes a domingo de la semana calendario de [today], para programas con
/// fechas y día de la semana por entreno. null si no aplica.
List<StripDay>? weekStrip(AssignmentDetailDto p, DateTime today) {
  if (!p.hasDates || p.dayMappings.isEmpty) return null;
  final t = dateOnly(today);
  final monday = t.subtract(Duration(days: t.weekday - 1));
  return [
    for (var i = 0; i < 7; i++)
      () {
        final d = monday.add(Duration(days: i));
        return StripDay(date: d, kind: _kindOn(p, d), isToday: d == t);
      }(),
  ];
}

StripDayKind _kindOn(AssignmentDetailDto p, DateTime d) {
  if (d.isBefore(p.startDate!)) return StripDayKind.none;
  final mapping = p.dayMappings
      .where((m) => m.weekDay == d.weekday)
      .firstOrNull;
  if (mapping == null) return StripDayKind.none;
  final week = p.weeks
      .where((w) => w.weekNumber == weekNumberFor(p.startDate!, d))
      .firstOrNull;
  final day = week?.days
      .where((x) => x.dayNumber == mapping.dayNumber)
      .firstOrNull;
  if (day == null) return StripDayKind.none;
  return day.sessionStatus == SessionStatus.completed
      ? StripDayKind.done
      : StripDayKind.planned;
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
    if (w.days.any((d) => d.sessionStatus != SessionStatus.completed)) {
      return w.weekNumber;
    }
  }
  return p.weeks.isEmpty ? 1 : p.weeks.last.weekNumber;
}

/// Fecha en la que toca [dayNumber] en la semana [weekNumber] (programas con
/// fechas y día de la semana por entreno). null si no aplica.
DateTime? dateOfDay(AssignmentDetailDto p, int weekNumber, int dayNumber) {
  if (!p.hasDates) return null;
  final m = p.dayMappings.where((m) => m.dayNumber == dayNumber).firstOrNull;
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

/// Adherencia del programa: (hechos, que ya tocaban) contando solo los días
/// con fecha hasta [today] inclusive y con ejercicios. null si el programa no
/// tiene calendario (sin fechas o sin día de la semana por entreno): ahí ningún
/// día "vence".
(int, int)? adherenceOf(AssignmentDetailDto p, DateTime today) {
  if (!p.hasDates || p.dayMappings.isEmpty) return null;
  var done = 0, due = 0;
  for (final w in p.weeks) {
    for (final d in w.days) {
      final date = dateOfDay(p, w.weekNumber, d.dayNumber);
      if (date == null || date.isAfter(today) || d.exercises.isEmpty) continue;
      due++;
      if (d.sessionStatus == SessionStatus.completed) done++;
    }
  }
  return (done, due);
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
