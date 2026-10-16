// Formatos de fecha en español sin depender de intl (por ahora la UI es solo
// español; cuando entre gen-l10n se reemplaza por DateFormat).

const _weekdays = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];
const _months = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// "Viernes 2 de octubre"
String formatLongDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]} ${d.day} de ${_months[d.month - 1]}';

const _weekdaysShort = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
const _monthsShort = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// "sáb 3 oct"
String formatShortDate(DateTime d) =>
    '${_weekdaysShort[d.weekday - 1]} ${d.day} ${_monthsShort[d.month - 1]}';

/// Inicial del día de la semana para la tira de Hoy: L M X J V S D.
String weekdayInitial(DateTime d) => 'LMXJVSD'[d.weekday - 1];
