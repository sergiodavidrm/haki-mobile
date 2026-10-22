import '../../program/data/assignment_dtos.dart';
import '../../program/data/program_schedule.dart';

// Pantalla Adherencia (mockup "Adherencia"): todo sale del detalle del
// programa en curso (con las sesiones del teléfono), así que funciona offline.

enum AdherenceCell {
  done,

  /// Ya tocaba (fecha pasada) y no se completó
  missed,

  /// Toca hoy y todavía no se hizo
  today,

  /// Más adelante, o programa sin calendario y sin hacer
  pending,
}

class AdherenceWeek {
  const AdherenceWeek({
    required this.weekNumber,
    required this.cells,
    required this.isCurrent,
    required this.started,
  });

  final int weekNumber;
  final List<AdherenceCell> cells;
  final bool isCurrent;

  /// false = semana futura (se muestra "—")
  final bool started;

  int get done => cells.where((c) => c == AdherenceCell.done).length;
}

class MissedDay {
  const MissedDay({
    required this.weekNumber,
    required this.day,
    required this.date,
  });

  final int weekNumber;
  final DayDto day;
  final DateTime date;
}

class AdherenceReport {
  const AdherenceReport({
    required this.assignmentId,
    required this.blockName,
    required this.done,
    required this.due,
    required this.total,
    required this.setsDone,
    required this.setsTarget,
    required this.workoutsDone,
    required this.weeks,
    required this.missed,
  });

  final String assignmentId;
  final String blockName;
  final int done;

  /// null = programa sin calendario (ningún día "vence"): se usa [total]
  final int? due;
  final int total;

  /// Series registradas / prescritas de los entrenos hechos
  final int setsDone;
  final int setsTarget;

  /// Entrenos completados (de los que salen [setsDone] / [setsTarget])
  final int workoutsDone;
  final List<AdherenceWeek> weeks;

  /// Entrenos que ya tocaban y no se hicieron, el más reciente primero
  final List<MissedDay> missed;

  /// 0–100, o null si todavía no tocaba ninguno
  int? get percent {
    final base = due ?? total;
    return base == 0 ? null : (100 * done / base).round().clamp(0, 100);
  }

  int? get setsPercent => setsTarget == 0
      ? null
      : (100 * setsDone / setsTarget).round().clamp(0, 100);
}

AdherenceReport adherenceReport(AssignmentDetailDto p, DateTime today) {
  final calendar = p.hasDates && p.dayMappings.isNotEmpty;
  final current = currentWeekOf(p, today);
  var done = 0, due = 0, total = 0, setsDone = 0, setsTarget = 0;
  var workoutsDone = 0;
  final weeks = <AdherenceWeek>[];
  final missed = <MissedDay>[];

  for (final w in p.weeks) {
    final cells = <AdherenceCell>[];
    for (final d in w.days) {
      // Día sin ejercicios: el coach lo está armando, no cuenta
      if (d.exercises.isEmpty) continue;
      total++;
      final completed = d.sessionStatus == SessionStatus.completed;
      final date = calendar ? dateOfDay(p, w.weekNumber, d.dayNumber) : null;
      final isDue = calendar ? date != null && !date.isAfter(today) : completed;
      // Con calendario cuenta como la tarjeta del Perfil: hechos de los que ya tocaban
      if (completed && isDue) done++;
      if (isDue) due++;
      // Series: solo de los entrenos hechos (los que no se hicieron ya bajan
      // el % de entrenos; contarlos acá los castigaría dos veces)
      if (completed) {
        workoutsDone++;
        for (final e in d.exercises) {
          setsTarget += e.targetSets.length;
          final logged = e.loggedSets.where((s) => s.reps != null).length;
          setsDone += logged > e.targetSets.length
              ? e.targetSets.length
              : logged;
        }
      }

      cells.add(switch ((completed, date)) {
        (true, _) => AdherenceCell.done,
        (false, final d?) when d == today => AdherenceCell.today,
        (false, final d?) when d.isBefore(today) => AdherenceCell.missed,
        _ => AdherenceCell.pending,
      });
      if (!completed && date != null && date.isBefore(today)) {
        missed.add(MissedDay(weekNumber: w.weekNumber, day: d, date: date));
      }
    }
    if (cells.isEmpty) continue;
    weeks.add(
      AdherenceWeek(
        weekNumber: w.weekNumber,
        cells: cells,
        isCurrent: w.weekNumber == current,
        started: w.weekNumber <= current,
      ),
    );
  }

  missed.sort((a, b) => b.date.compareTo(a.date));
  return AdherenceReport(
    assignmentId: p.assignmentId,
    blockName: p.blockName,
    done: done,
    due: calendar ? due : null,
    total: total,
    setsDone: setsDone,
    setsTarget: setsTarget,
    workoutsDone: workoutsDone,
    weeks: weeks,
    missed: missed,
  );
}
