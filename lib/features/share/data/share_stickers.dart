import '../../../core/units/weight_unit.dart';
import '../../profile/data/records.dart';
import '../../program/data/assignment_dtos.dart';
import '../../program/data/program_schedule.dart';
import '../../session/data/session_plan.dart';
import '../../session/data/session_store.dart';
import '../../session/data/workout_prs.dart';

// Stickers para historias (2026-11-12, idea de Hevy). El atleta elige Día /
// Semana / Mes y un sticker; sale como PNG (sin fondo o con color + opacidad)
// para pegar sobre su foto en Instagram. Solo datos, nada que escriba el atleta.
// Canvas https://claude.ai/artifact/XgxAnMeTfAh9gdVjzmFy2t

enum SharePeriod { day, week, month }

enum StickerKind {
  dayRecord(SharePeriod.day),
  daySummary(SharePeriod.day),
  dayMuscles(SharePeriod.day),
  dayExercises(SharePeriod.day),
  weekDays(SharePeriod.week),
  weekNumbers(SharePeriod.week),
  weekRecords(SharePeriod.week),
  weekMuscles(SharePeriod.week),
  weekProgram(SharePeriod.week),
  monthMuscles(SharePeriod.month),
  monthWorkouts(SharePeriod.month),
  monthRecords(SharePeriod.month);

  const StickerKind(this.period);
  final SharePeriod period;

  static List<StickerKind> of(SharePeriod p) =>
      values.where((k) => k.period == p).toList();
}

/// Un entreno hecho (cualquier programa), con lo que suman los stickers.
class TrainedDay {
  const TrainedDay({
    required this.assignmentId,
    required this.weekNumber,
    required this.day,
    required this.date,
    required this.sets,
    required this.setsTotal,
    required this.volumeKg,
    required this.muscleSets,
    required this.bestE1RmKg,
    this.duration,
  });

  final String assignmentId;
  final int weekNumber;
  final DayDto day;

  /// Día en que se hizo (sin hora)
  final DateTime date;

  /// Series de fuerza con reps / series del día
  final int sets;
  final int setsTotal;
  final double volumeKg;

  /// Clave del músculo → series (principal 1, secundario ½, como el web)
  final Map<String, double> muscleSets;

  /// exerciseId → mejor e1RM del día
  final Map<String, double> bestE1RmKg;
  final Duration? duration;
}

/// Los días completados de un programa. [local] = series del teléfono del
/// programa entero (por `setKey`).
List<TrainedDay> trainedDaysOf(
  AssignmentDetailDto p,
  Map<String, LocalSetEntry> local,
) {
  final out = <TrainedDay>[];
  for (final w in p.weeks) {
    for (final d in w.days) {
      if (d.sessionStatus != SessionStatus.completed) continue;
      final at = d.completedAt ?? d.startedAt;
      if (at == null) continue;
      final ids = {for (final e in d.exercises) e.id};
      final dayLocal = {
        for (final x in local.entries)
          if (ids.contains(x.value.dayExerciseId)) x.key: x.value,
      };
      var sets = 0, total = 0;
      var volume = 0.0;
      final muscles = <String, double>{};
      final best = <String, double>{};
      for (final e in d.exercises.where((e) => e.isStrength)) {
        for (var n = 1; n <= setCountOf(e); n++) {
          total++;
          final s = savedSetFor(e, n, dayLocal);
          final reps = s?.reps;
          if (s == null || reps == null || reps <= 0) continue;
          sets++;
          for (final m in e.primaryMuscles) {
            muscles[m] = (muscles[m] ?? 0) + 1;
          }
          for (final m in e.secondaryMuscles) {
            muscles[m] = (muscles[m] ?? 0) + 0.5;
          }
          final w = s.weight;
          if (w == null || w <= 0) continue;
          final kg = s.unit.toKg(w);
          volume += kg * reps;
          final e1 = e1RmKgOf(kg, reps);
          final key = e.exerciseId.isEmpty ? e.id : e.exerciseId;
          if (e1 > (best[key] ?? 0)) best[key] = e1;
        }
      }
      out.add(
        TrainedDay(
          assignmentId: p.assignmentId,
          weekNumber: w.weekNumber,
          day: d,
          date: dateOnly(at.toLocal()),
          sets: sets,
          setsTotal: total,
          volumeKg: volume,
          muscleSets: muscles,
          bestE1RmKg: best,
          duration: summarize(
            d.exercises,
            dayLocal,
            unit: WeightUnit.kg,
            startedAt: d.startedAt,
            completedAt: d.completedAt,
          ).duration,
        ),
      );
    }
  }
  return out;
}

// ---------------------------------------------------------------- Día

class DayRecordLine {
  const DayRecordLine(this.name, this.e1RmKg, this.gainKg);
  final String name;
  final double e1RmKg;

  /// Contra el récord anterior; null = el mejor del día sin récord
  final double? gainKg;
}

class DayExerciseLine {
  const DayExerciseLine({
    required this.name,
    required this.sets,
    this.e1RmKg,
    this.bestReps,
    this.isPr = false,
  });
  final String name;
  final int sets;
  final double? e1RmKg;
  final int? bestReps;
  final bool isPr;
}

class ShareDayData {
  const ShareDayData({
    required this.title,
    required this.date,
    required this.sets,
    required this.setsTotal,
    required this.volumeKg,
    required this.records,
    required this.exercises,
    required this.muscles,
    this.duration,
    this.volumeChange,
  });

  /// "Día 3 · Pierna"
  final String title;
  final DateTime date;
  final int sets;
  final int setsTotal;
  final double volumeKg;
  final Duration? duration;

  /// Volumen vs. el mismo día de la semana anterior del programa, solo en
  /// los ejercicios en común (como el Resumen del web). null = sin dato.
  final double? volumeChange;

  /// PRs del día, el que más subió primero
  final List<DayRecordLine> records;
  final List<DayExerciseLine> exercises;

  /// Músculo → series, de más a menos
  final List<MapEntry<String, double>> muscles;

  /// El mejor e1RM del día (sticker Récord sin récords)
  DayExerciseLine? get best {
    DayExerciseLine? b;
    for (final e in exercises) {
      if (e.e1RmKg != null && (b == null || e.e1RmKg! > b.e1RmKg!)) b = e;
    }
    return b;
  }
}

ShareDayData buildShareDay({
  required AssignmentDetailDto program,
  required TrainedDay trained,
  required Map<String, LocalSetEntry> local,
  required List<WorkoutPr> prs,
  TrainedDay? sameDayLastWeek,
}) {
  final d = trained.day;
  final prIds = {for (final p in prs) p.dayExerciseId};
  final lines = <DayExerciseLine>[];
  for (final e in d.exercises.where((e) => e.isStrength)) {
    var done = 0;
    double? bestKg;
    int? bestReps;
    for (var n = 1; n <= setCountOf(e); n++) {
      final s = savedSetFor(e, n, local);
      final reps = s?.reps;
      if (s == null || reps == null || reps <= 0) continue;
      done++;
      final w = s.weight;
      if (w != null && w > 0) {
        final e1 = e1RmKgOf(s.unit.toKg(w), reps);
        if (bestKg == null || e1 > bestKg) bestKg = e1;
      } else if (bestReps == null || reps > bestReps) {
        bestReps = reps;
      }
    }
    if (done == 0) continue;
    lines.add(
      DayExerciseLine(
        name: e.exerciseName,
        sets: done,
        e1RmKg: bestKg,
        bestReps: bestKg == null ? bestReps : null,
        isPr: prIds.contains(e.id),
      ),
    );
  }

  double? change;
  final prev = sameDayLastWeek;
  if (prev != null) {
    final common = prev.bestE1RmKg.keys.toSet().intersection(
      trained.bestE1RmKg.keys.toSet(),
    );
    final now = _volumeOf(trained.day, local, common);
    final before = _volumeOf(prev.day, local, common);
    if (common.isNotEmpty && before > 0) change = (now - before) / before;
  }

  final sorted = [...prs]
    ..sort(
      (a, b) => (b.e1RmKg - b.previousE1RmKg).compareTo(
        a.e1RmKg - a.previousE1RmKg,
      ),
    );
  return ShareDayData(
    title: d.title,
    date: trained.date,
    sets: trained.sets,
    setsTotal: trained.setsTotal,
    volumeKg: trained.volumeKg,
    duration: trained.duration,
    volumeChange: change,
    records: [
      for (final p in sorted)
        DayRecordLine(p.exerciseName, p.e1RmKg, p.e1RmKg - p.previousE1RmKg),
    ],
    exercises: lines,
    muscles: _sortedMuscles(trained.muscleSets),
  );
}

double _volumeOf(DayDto d, Map<String, LocalSetEntry> local, Set<String> ids) {
  var v = 0.0;
  for (final e in d.exercises.where((e) => e.isStrength)) {
    final key = e.exerciseId.isEmpty ? e.id : e.exerciseId;
    if (!ids.contains(key)) continue;
    for (var n = 1; n <= setCountOf(e); n++) {
      final s = savedSetFor(e, n, local);
      if (s?.weight == null || s?.reps == null) continue;
      v += s!.unit.toKg(s.weight!) * s.reps!;
    }
  }
  return v;
}

/// El mismo día del programa en la semana anterior, si se hizo.
TrainedDay? sameDayLastWeekOf(TrainedDay t, List<TrainedDay> all) => all
    .where(
      (x) =>
          x.assignmentId == t.assignmentId &&
          x.weekNumber == t.weekNumber - 1 &&
          x.day.dayNumber == t.day.dayNumber,
    )
    .firstOrNull;

List<MapEntry<String, double>> _sortedMuscles(Map<String, double> m) =>
    m.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

// ---------------------------------------------------------------- Totales

class PeriodTotals {
  const PeriodTotals({
    required this.workouts,
    required this.duration,
    required this.volumeKg,
    required this.sets,
  });
  final int workouts;
  final Duration duration;
  final double volumeKg;
  final int sets;

  static PeriodTotals of(Iterable<TrainedDay> days) => PeriodTotals(
    workouts: days.length,
    duration: days.fold(Duration.zero, (a, d) => a + (d.duration ?? Duration.zero)),
    volumeKg: days.fold(0.0, (a, d) => a + d.volumeKg),
    sets: days.fold(0, (a, d) => a + d.sets),
  );
}

Map<String, double> muscleSetsOf(Iterable<TrainedDay> days) {
  final m = <String, double>{};
  for (final d in days) {
    for (final x in d.muscleSets.entries) {
      m[x.key] = (m[x.key] ?? 0) + x.value;
    }
  }
  return m;
}

/// Récords (PRs, no primeras veces) logrados en [from, to).
List<PersonalRecordDto> recordsIn(
  List<PersonalRecordDto> records,
  DateTime from,
  DateTime to,
) {
  final out = [
    for (final r in records)
      if (r.isPr) ...[
        if (!dateOnly(r.date.toLocal()).isBefore(from) &&
            dateOnly(r.date.toLocal()).isBefore(to))
          r,
      ],
  ];
  out.sort(
    (a, b) => (b.e1RmKg - (b.previousE1RmKg ?? b.e1RmKg)).compareTo(
      a.e1RmKg - (a.previousE1RmKg ?? a.e1RmKg),
    ),
  );
  return out;
}

Iterable<TrainedDay> trainedIn(
  List<TrainedDay> all,
  DateTime from,
  DateTime to,
) => all.where((d) => !d.date.isBefore(from) && d.date.isBefore(to));

// ---------------------------------------------------------------- Semana

enum WeekMark { done, missed, pending, rest }

class MuscleLine {
  const MuscleLine(this.key, this.sets, this.target);
  final String key;
  final double sets;

  /// Series por semana que pide el programa; null si no pide para este músculo
  final int? target;
}

class ProgramProgress {
  const ProgramProgress({
    required this.name,
    required this.week,
    required this.weeks,
    required this.weekFill,
    required this.done,
    required this.total,
    this.adherence,
    this.gainName,
    this.gainKg,
  });
  final String name;
  final int week;
  final int weeks;

  /// Por semana: hechos / días (0–1)
  final List<double> weekFill;
  final int done;
  final int total;

  /// Hechos de los que tocaban (0–1); null si todavía no tocaba ninguno
  final double? adherence;

  /// Ejercicio que más subió su e1RM en el bloque
  final String? gainName;
  final double? gainKg;
}

class ShareWeekData {
  const ShareWeekData({
    required this.start,
    required this.marks,
    required this.done,
    required this.planned,
    required this.totals,
    required this.previous,
    required this.records,
    required this.muscles,
    this.program,
    this.streakWeeks,
  });

  /// Lunes
  final DateTime start;

  /// Lunes a domingo
  final List<WeekMark> marks;
  final int done;

  /// Entrenos que tocaban esta semana (0 = programa sin días fijos)
  final int planned;
  final PeriodTotals totals;
  final PeriodTotals previous;
  final List<PersonalRecordDto> records;
  final List<MuscleLine> muscles;
  final ProgramProgress? program;
  final int? streakWeeks;

  bool get complete => planned > 0 && done >= planned;
}

/// Lunes de la semana de [d] (UTC sin hora, como `dateOnly`).
DateTime mondayOf(DateTime d) =>
    dateOnly(d).subtract(Duration(days: d.weekday - 1));

/// Semana a mostrar: la de [anchor]; si es hoy y todavía no entrenó nada esta
/// semana (un lunes temprano), la anterior.
DateTime weekToShare(DateTime anchor, List<TrainedDay> all, DateTime today) {
  final start = mondayOf(anchor);
  final isThisWeek = start == mondayOf(today);
  if (isThisWeek &&
      trainedIn(all, start, start.add(const Duration(days: 7))).isEmpty) {
    return start.subtract(const Duration(days: 7));
  }
  return start;
}

ShareWeekData buildShareWeek({
  required DateTime start,
  required DateTime today,
  required List<AssignmentDetailDto> programs,
  required List<TrainedDay> trained,
  required List<PersonalRecordDto> records,
  AssignmentDetailDto? mainProgram,
  int? streakWeeks,
}) {
  final end = start.add(const Duration(days: 7));
  final t = dateOnly(today);
  final inWeek = trainedIn(trained, start, end).toList();

  // Lo que tocaba cada día (programas con fechas y días de la semana)
  final plannedOn = <DateTime, List<DayDto>>{};
  for (final p in programs) {
    if (!p.hasDates || p.dayMappings.isEmpty) continue;
    for (final w in p.weeks) {
      for (final d in w.days) {
        if (d.exercises.isEmpty) continue;
        final date = dateOfDay(p, w.weekNumber, d.dayNumber);
        if (date == null || date.isBefore(start) || !date.isBefore(end)) {
          continue;
        }
        plannedOn.putIfAbsent(dateOnly(date), () => []).add(d);
      }
    }
  }
  final marks = <WeekMark>[];
  for (var i = 0; i < 7; i++) {
    final date = start.add(Duration(days: i));
    final trainedHere = inWeek.any((x) => x.date == date);
    final planned = plannedOn[date] ?? const [];
    if (trainedHere ||
        (planned.isNotEmpty &&
            planned.every((d) => d.sessionStatus == SessionStatus.completed))) {
      marks.add(WeekMark.done);
    } else if (planned.isEmpty) {
      marks.add(WeekMark.rest);
    } else {
      marks.add(date.isBefore(t) ? WeekMark.missed : WeekMark.pending);
    }
  }
  final plannedDays = plannedOn.values.expand((x) => x).toList();
  final plannedIds = {for (final d in plannedDays) d.id};
  // Hechos fuera de lo planificado (programas sin fechas) también tocaban
  final extra = inWeek.where((x) => !plannedIds.contains(x.day.id)).length;

  // Series por músculo contra lo que pide el programa (suma de los programas
  // con entrenos o días esta semana)
  final targets = <String, int>{};
  final involved = {
    ...inWeek.map((x) => x.assignmentId),
    for (final p in programs)
      if (p.weeks.any((w) => w.days.any((d) => plannedIds.contains(d.id))))
        p.assignmentId,
  };
  for (final p in programs.where((p) => involved.contains(p.assignmentId))) {
    for (final x in p.muscleTargets.entries) {
      if (x.value > 0) targets[x.key] = (targets[x.key] ?? 0) + x.value;
    }
  }
  final sets = muscleSetsOf(inWeek);
  final keys = {...sets.keys, ...targets.keys};
  final muscles = [
    for (final k in keys) MuscleLine(k, sets[k] ?? 0, targets[k]),
  ]..sort((a, b) {
      final c = b.sets.compareTo(a.sets);
      return c != 0 ? c : (b.target ?? 0).compareTo(a.target ?? 0);
    });

  return ShareWeekData(
    start: start,
    marks: marks,
    done: inWeek.length,
    planned: plannedDays.isEmpty ? 0 : plannedDays.length + extra,
    totals: PeriodTotals.of(inWeek),
    previous: PeriodTotals.of(
      trainedIn(trained, start.subtract(const Duration(days: 7)), start),
    ),
    records: recordsIn(records, start, end),
    muscles: muscles,
    program: mainProgram == null
        ? null
        : programProgressOf(mainProgram, trained, today),
    streakWeeks: streakWeeks,
  );
}

ProgramProgress programProgressOf(
  AssignmentDetailDto p,
  List<TrainedDay> trained,
  DateTime today,
) {
  final (done, total) = dayCountsOf(p);
  final (dueDone, due) = adherenceOf(p, dateOnly(today));
  final mine = trained.where((x) => x.assignmentId == p.assignmentId).toList()
    ..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));
  // Del primer e1RM del bloque al mejor
  final first = <String, double>{};
  final best = <String, double>{};
  for (final x in mine) {
    for (final e in x.bestE1RmKg.entries) {
      first.putIfAbsent(e.key, () => e.value);
      if (e.value > (best[e.key] ?? 0)) best[e.key] = e.value;
    }
  }
  String? gainId;
  var gain = 0.0;
  for (final id in best.keys) {
    final g = best[id]! - first[id]!;
    if (g > gain) {
      gain = g;
      gainId = id;
    }
  }
  String? gainName;
  if (gainId != null) {
    for (final d in p.weeks.expand((w) => w.days)) {
      for (final e in d.exercises) {
        if (e.exerciseId == gainId || e.id == gainId) gainName = e.exerciseName;
      }
    }
  }
  return ProgramProgress(
    name: p.blockName,
    week: currentWeekOf(p, today),
    weeks: p.weeks.isEmpty ? p.numberOfWeeks : p.weeks.last.weekNumber,
    weekFill: [
      for (final w in p.weeks)
        w.days.isEmpty
            ? 0
            : w.days
                      .where((d) => d.sessionStatus == SessionStatus.completed)
                      .length /
                  w.days.length,
    ],
    done: done,
    total: total,
    adherence: due == 0 ? null : dueDone / due,
    gainName: gainName,
    gainKg: gainName == null ? null : gain,
  );
}

// ---------------------------------------------------------------- Mes

class ShareMonthData {
  const ShareMonthData({
    required this.month,
    required this.toDate,
    required this.totals,
    required this.previous,
    required this.records,
    required this.muscles,
  });

  /// Día 1 del mes
  final DateTime month;

  /// Mes en curso (hasta hoy) vs. el que terminó
  final bool toDate;
  final PeriodTotals totals;

  /// El mes anterior: entero si [toDate] es false; hasta el mismo día si es true
  final PeriodTotals previous;
  final List<PersonalRecordDto> records;
  final List<MapEntry<String, double>> muscles;
}

/// Del 1 al 7 se comparte el mes que terminó (completo); del 8 en adelante,
/// el mes en curso hasta hoy.
/// Fechas en UTC sin hora, como `dateOnly`.
({DateTime month, bool toDate}) monthToShare(DateTime today) => today.day <= 7
    ? (month: DateTime.utc(today.year, today.month - 1), toDate: false)
    : (month: DateTime.utc(today.year, today.month), toDate: true);

ShareMonthData buildShareMonth({
  required DateTime today,
  required List<TrainedDay> trained,
  required List<PersonalRecordDto> records,
}) {
  final (:month, :toDate) = monthToShare(today);
  final end = toDate
      ? dateOnly(today).add(const Duration(days: 1))
      : DateTime.utc(month.year, month.month + 1);
  final prevStart = DateTime.utc(month.year, month.month - 1);
  final prevEnd = toDate
      ? DateTime.utc(prevStart.year, prevStart.month, today.day + 1)
      : month;
  final inMonth = trainedIn(trained, month, end).toList();
  return ShareMonthData(
    month: month,
    toDate: toDate,
    totals: PeriodTotals.of(inMonth),
    previous: PeriodTotals.of(
      trainedIn(trained, prevStart, prevEnd.isAfter(month) ? month : prevEnd),
    ),
    records: recordsIn(records, month, end),
    muscles: _sortedMuscles(muscleSetsOf(inMonth)),
  );
}
