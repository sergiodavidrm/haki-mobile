import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/program/data/place_label.dart';
import 'package:haki_mobile/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

void main() {
  setUp(() => setAppLocale(const Locale('es')));

  test('día de la semana si hay fechas, si no Día N, con la vez', () {
    expect(placeDayLabel(dayNumber: 5, weekDay: 'fri'), 'Viernes');
    expect(placeDayLabel(dayNumber: 1, weekDay: 'MON', slot: 2), 'Lunes · 2.ª');
    expect(placeDayLabel(dayNumber: 3), 'Día 3');
  });

  test('prescripción', () {
    expect(rxLabel(sets: 3, repsMin: 12, repsMax: 12), '3 × 12');
    expect(rxLabel(sets: 3, repsMin: 8, repsMax: 10), '3 × 8–10');
    expect(rxLabel(sets: 4), '4');
    expect(rxLabel(sets: null, repsMin: 10), isNull);
  });
}
