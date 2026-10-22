import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/core/format/dates.dart';
import 'package:haki_mobile/l10n/l10n.dart';

void main() {
  tearDown(() => setAppLocale(const Locale('es')));

  test('inglés si el teléfono está en inglés, si no español', () {
    expect(resolveLocale(const Locale('en', 'US')), const Locale('en'));
    expect(resolveLocale(const Locale('pt', 'BR')), const Locale('es'));
    expect(resolveLocale(null), const Locale('es'));
  });

  test('fechas y textos según el idioma activo', () {
    final d = DateTime(2026, 10, 2); // viernes
    expect(formatShortDate(d), 'vie 2 oct');
    expect(formatLongDate(d), 'Viernes 2 de octubre');
    expect(l10n.weekOfTotal(2, 4), 'Semana 2 de 4');
    expect(l10n.exercisesCount(1), '1 ejercicio');

    setAppLocale(const Locale('en'));
    expect(formatShortDate(d), 'Fri, Oct 2');
    expect(formatLongDate(d), 'Friday, October 2');
    expect(weekdayLetter(1), 'M');
    expect(l10n.weekOfTotal(2, 4), 'Week 2 of 4');
    expect(l10n.exercisesCount(3), '3 exercises');
  });
}
