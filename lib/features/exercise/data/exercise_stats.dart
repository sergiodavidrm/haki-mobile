import 'dart:math';

import '../../../core/format/dates.dart';
import '../../../core/units/weight_unit.dart';
import '../../program/data/assignment_dtos.dart';
import '../../program/data/place_label.dart';
import '../../program/data/program_schedule.dart' show mappingsForWeek;
import '../../session/data/session_plan.dart';
import '../../session/data/session_store.dart';
import 'exercise_history.dart';
import '../../../l10n/l10n.dart';

// Lógica pura de rendimiento por ejercicio: "última vez" en la Sesión y el
// Detalle de ejercicio. Pesos de la API en kg; e1RM = peso × (1 + reps/30),
// igual que PerformanceService en la API.

/// Mejor e1RM (kg) de las series con peso y reps. null si ninguna.
double? bestE1rmKg(Iterable<LoggedSetDto> sets) {
  double? best;
  for (final s in sets) {
    final w = s.weightKg, r = s.reps;
    if (w == null || w <= 0 || r == null || r <= 0) continue;
    final e = w * (1 + r / 30);
    if (best == null || e > best) best = e;
  }
  return best;
}

/// Volumen (kg): Σ peso × reps.
double volumeKg(Iterable<LoggedSetDto> sets) =>
    sets.fold(0, (sum, s) => sum + (s.weightKg ?? 0) * (s.reps ?? 0));

/// "116 lb × 12·12·12·12", "110–116 lb × 12·12·11" si el peso cambió entre
/// series, o "12·12·12 reps" sin peso.
String setsSummary(List<LoggedSetDto> sets, WeightUnit unit) {
  final reps = sets.map((s) => s.reps).nonNulls.join('·');
  final kgs = sets.map((s) => s.weightKg).nonNulls.where((w) => w > 0);
  if (kgs.isEmpty) return '$reps ${l10n.repsShort}';
  final lo = formatWeight(unit.fromKg(kgs.reduce(min)));
  final hi = formatWeight(unit.fromKg(kgs.reduce(max)));
  return '${lo == hi ? hi : '$lo–$hi'} ${unit.label} × $reps';
}

/// "Sem. pasada" (semana anterior de este programa), "Sem. 2" (otra semana de
/// este programa) o "25 sep" (otro programa).
String lastTimeLabel(
  LastPerformanceDto lp, {
  required String assignmentId,
  required int weekNumber,
  AssignmentDetailDto? program,
}) {
  if (lp.assignmentId != assignmentId) return formatDayMonth(lp.date.toLocal());
  // De otro día del programa (el ejercicio es nuevo en este): "Lunes, sem. 6"
  if (!lp.samePlace && lp.dayNumber > 0) {
    final weekDay = program == null || program.startDate == null
        ? null
        : mappingsForWeek(
            program,
            lp.weekNumber,
          ).where((m) => m.dayNumber == lp.dayNumber).firstOrNull?.weekDay;
    return l10n.lastFromDay(
      placeDayLabel(dayNumber: lp.dayNumber, weekdayNumber: weekDay),
      lp.weekNumber,
    );
  }
  return lp.weekNumber == weekNumber - 1
      ? l10n.weekLastShort
      : l10n.weekShortN(lp.weekNumber);
}

/// "116 lb × 12 @1" (peso × reps @ RIR) para los chips del historial; sin
/// peso "12 @1".
String setChip(LoggedSetDto s, WeightUnit unit) {
  final w = s.weightKg;
  final reps = '${s.reps ?? '–'}';
  final base = w == null || w <= 0
      ? reps
      : '${formatWeight(unit.fromKg(w))} ${unit.label} × $reps';
  return s.rir == null ? base : '$base @${s.rir}';
}

/// Series de hoy de un ejercicio (lo del teléfono gana sobre la API), como
/// LoggedSetDto en kg para mezclarlas con el historial.
List<LoggedSetDto> todaySets(
  DayExerciseDto e,
  Map<String, LocalSetEntry> local,
) => [
  for (var n = 1; n <= setCountOf(e); n++)
    if (savedSetFor(e, n, local) case final s? when s.reps != null)
      LoggedSetDto(
        setNumber: n,
        weightKg: s.weight == null ? null : s.unit.toKg(s.weight!),
        weightUnit: s.unit.api,
        reps: s.reps,
        rir: s.rir,
      ),
];

/// La sesión es un PR si su e1RM supera el de todas las anteriores (y hay
/// anteriores). [entries] del más nuevo al más viejo.
bool isNewPr(List<List<LoggedSetDto>> entries) {
  if (entries.length < 2) return false;
  final last = bestE1rmKg(entries.first);
  if (last == null) return false;
  final before = entries.skip(1).map(bestE1rmKg).nonNulls;
  return before.isNotEmpty && last > before.reduce(max);
}

/// Lugar del programa: número de día + vez del ejercicio en ese día
/// (2026-11-07, PerformanceReport.Place de la API).
typedef ExercisePlace = ({int day, int slot});

/// Lugar de [e] en [day]: la vez se cuenta en el orden del día.
ExercisePlace placeOf(DayDto day, DayExerciseDto e) {
  var slot = 1;
  for (final x in day.exercises) {
    if (x.id == e.id) break;
    if (x.exerciseId == e.exerciseId) slot++;
  }
  return (day: day.dayNumber, slot: slot);
}

/// Si el ejercicio está en 2+ lugares de esa semana (días, o dos veces el
/// mismo día): el Detalle muestra solo el lugar de la sesión.
bool inSeveralPlaces(WeekDto week, String exerciseId) =>
    week.days
        .expand((d) => d.exercises)
        .where((x) => x.exerciseId == exerciseId)
        .length >=
    2;

/// Las del mismo lugar (hoy incluido). Cruzando programas sigue por número de
/// día, como Tu progreso.
List<HistoryItem> samePlaceItems(List<HistoryItem> items, ExercisePlace p) => [
  for (final i in items)
    if (i.isToday || i.place == p) i,
];

/// Una tarjeta del historial del Detalle de ejercicio.
class HistoryItem {
  const HistoryItem({
    required this.title,
    required this.date,
    required this.sets,
    this.isToday = false,
    this.past = false,
    this.inThisProgram = true,
    this.streamMessageId,
    this.videoCount = 0,
    this.place,
  });

  /// "Semana 3 · hoy", "Semana 2 · 25 sep", "Bloque fuerza · S4 · 2 ago".
  final String title;

  /// Lugar del programa de esa vez (null = no se sabe: caché vieja)
  final ExercisePlace? place;
  final DateTime date;
  final List<LoggedSetDto> sets;

  /// La sesión desde la que se abrió el Detalle (borde dorado)
  final bool isToday;

  /// Esa sesión es de otro día (Detalle abierto desde la Sesión pasada)
  final bool past;
  final bool inThisProgram;

  /// Hilo de feedback de esa vez (si subió videos).
  final String? streamMessageId;
  final int videoCount;
}

int _videos(List<LoggedSetDto> sets) =>
    sets.where((s) => s.videoUrl != null).length;

/// Historial del Detalle: hoy (si ya cargó series) + lo que vino de la API,
/// sin el registro de este mismo día (el de hoy ya va arriba, más nuevo). Sin
/// red ([history] null) queda hoy + "última vez" del programa.
List<HistoryItem> historyItems({
  required List<ExerciseHistoryEntryDto>? history,
  required DayExerciseDto exercise,
  required String assignmentId,
  required String dayId,
  required int weekNumber,
  required List<LoggedSetDto> today,
  required DateTime now,
  ExercisePlace? place,
  DateTime? sessionDate,
}) {
  // Abierto desde un entreno de otro día: esa sesión con su fecha y la lista
  // por fecha (puede haber veces posteriores)
  final past = sessionDate != null && !_sameDay(sessionDate.toLocal(), now);
  String title(String a, String block, int week, DateTime date) =>
      a == assignmentId
      ? '${l10n.weekN(week)} · ${formatDayMonth(date.toLocal())}'
      : '$block · ${l10n.weekLetter(week)} · ${formatDayMonth(date.toLocal())}';

  final lp = exercise.lastPerformance;
  final todayRemote = history?.where((h) => h.blockDayId == dayId).firstOrNull;
  final items = [
    if (today.isNotEmpty)
      HistoryItem(
        title: past
            ? '${l10n.weekN(weekNumber)} · ${formatDayMonth(sessionDate.toLocal())}'
            : '${l10n.weekN(weekNumber)} · ${l10n.commonToday.toLowerCase()}',
        date: past ? sessionDate : now,
        sets: today,
        isToday: true,
        past: past,
        place: place,
        streamMessageId:
            exercise.streamMessageId ?? todayRemote?.streamMessageId,
        videoCount: _videos(exercise.loggedSets),
      ),
    if (history != null)
      for (final h in history)
        if (h.blockDayId != dayId)
          HistoryItem(
            title: title(h.assignmentId, h.blockName, h.weekNumber, h.date),
            date: h.date,
            sets: h.sets,
            inThisProgram: h.assignmentId == assignmentId,
            place: (day: h.dayNumber, slot: h.slot),
            streamMessageId: h.streamMessageId,
            videoCount: _videos(h.sets),
          ),
    if (history == null && lp != null)
      HistoryItem(
        title: lp.assignmentId == assignmentId
            ? '${l10n.weekN(lp.weekNumber)} · ${formatDayMonth(lp.date.toLocal())}'
            : '${l10n.lastTime} · ${formatDayMonth(lp.date.toLocal())}',
        date: lp.date,
        sets: lp.sets,
        inThisProgram: lp.assignmentId == assignmentId,
        place: (day: lp.dayNumber, slot: lp.slot),
      ),
  ];
  if (past) items.sort((a, b) => b.date.compareTo(a.date));
  return items;
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
