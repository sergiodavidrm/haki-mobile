import '../../../core/format/dates.dart';
import '../../../l10n/l10n.dart';

// Etiquetas del "lugar del programa" (número de día + vez en ese día,
// haki-api PerformanceReport.Place): un ejercicio en 2+ lugares va en una fila
// por lugar en Tu progreso, "Sem. pasada" sale del mismo lugar y el Detalle de
// ejercicio muestra el del día de la sesión (2026-11-07).

const _weekDays = {
  'mon': 1,
  'tue': 2,
  'wed': 3,
  'thu': 4,
  'fri': 5,
  'sat': 6,
  'sun': 7,
};

/// 1 = lunes … 7 = domingo; acepta "MON" o "mon". null si no se reconoce.
int? weekdayOf(String? weekDay) => _weekDays[weekDay?.toLowerCase()];

/// "Lunes" si el programa tiene fechas, si no "Día 5"; con la vez en el día
/// si el ejercicio está 2+ veces ese día: "Lunes · 2.ª". El día de la semana
/// como "mon" (API) o [weekdayNumber] 1…7 (DayMappingDto).
String placeDayLabel({
  required int dayNumber,
  String? weekDay,
  int? weekdayNumber,
  int? slot,
}) {
  final wd = weekdayNumber ?? weekdayOf(weekDay);
  final day = wd == null ? l10n.dayN(dayNumber) : _capitalize(weekdayName(wd));
  return slot == null ? day : '$day · ${l10n.placeSlot(slot)}';
}

/// "3 × 12" · "3 × 8–10" · "3" sin reps pedidas; null sin series.
String? rxLabel({int? sets, int? repsMin, int? repsMax}) {
  if (sets == null || sets <= 0) return null;
  if (repsMin == null) return '$sets';
  final reps = repsMax == null || repsMax == repsMin
      ? '$repsMin'
      : '$repsMin–$repsMax';
  return '$sets × $reps';
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
