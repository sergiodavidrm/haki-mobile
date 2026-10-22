import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';

// Formatos de fecha según el idioma activo (intl; los datos de cada idioma se
// cargan en main con initializeDateFormatting).

bool get _en => appLocale.languageCode == 'en';
String get _lang => appLocale.languageCode;

/// "Viernes 2 de octubre" / "Friday, October 2"
String formatLongDate(DateTime d) => capitalize(
  DateFormat(_en ? 'EEEE, MMMM d' : "EEEE d 'de' MMMM", _lang).format(d),
);

/// "sáb 3 oct" / "Sat, Oct 3"
String formatShortDate(DateTime d) => _clean(
  DateFormat(_en ? 'EEE, MMM d' : 'EEE d MMM', _lang).format(d),
);

/// Inicial del día de la semana para la tira de Hoy: L M X J V S D / M T W T F S S.
String weekdayInitial(DateTime d) => weekdayLetter(d.weekday);

/// Inicial de un día (1 = lunes … 7 = domingo).
String weekdayLetter(int weekday) => (_en ? 'MTWTFSS' : 'LMXJVSD')[weekday - 1];

/// "lunes" / "Monday" (1 = lunes … 7 = domingo). 2024-01-01 fue lunes.
String weekdayName(int weekday) =>
    DateFormat('EEEE', _lang).format(DateTime(2024, 1, weekday));

/// "14 sep" / "Sep 14"
String formatDayMonth(DateTime d) =>
    _clean(DateFormat(_en ? 'MMM d' : 'd MMM', _lang).format(d));

/// "Octubre 2026" / "October 2026"
String formatMonthYear(DateTime d) =>
    capitalize(DateFormat('MMMM y', _lang).format(d));

/// "SEP" (para la línea de tiempo de programas anteriores)
String monthShortUpper(DateTime d) =>
    _clean(DateFormat('MMM', _lang).format(d)).toUpperCase();

/// "sáb 3 oct" → "Sáb 3 oct"
String capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

// intl en español abrevia con punto y septiembre como "sept." ("sáb.",
// "sept."): la UI va sin punto y con tres letras como el resto ("sep")
String _clean(String s) {
  final out = s.replaceAll('.', '');
  return _en ? out : out.replaceAll('sept', 'sep');
}
