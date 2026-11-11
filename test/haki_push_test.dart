import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:haki_mobile/core/notifications/haki_push.dart';
import 'package:haki_mobile/l10n/l10n.dart';

void main() {
  setUpAll(initializeDateFormatting);
  setUp(() => setAppLocale(const Locale('es')));

  test('solo los de la API son de Haki', () {
    expect(isHakiPush({'sender': 'haki', 'type': 'test'}), isTrue);
    expect(isHakiPush({'sender': 'stream.chat', 'type': 'message.new'}), isFalse);
  });

  test('recordatorio de pago: igual que la vista previa del web', () {
    Map<String, dynamic> data(String days, {String? coach = 'Andrés Solano'}) => {
      'sender': 'haki',
      'type': 'payment_reminder',
      'days': days,
      'amount': '45000',
      'currency': 'CRC',
      'date': '2026-11-13',
      'coach': ?coach,
    };
    final today = hakiPushText(data('0'))!;
    expect(today.title, 'Hoy vence tu pago');
    expect(today.body, startsWith('Pago a Andrés Solano de ₡45'));
    expect(hakiPushText(data('1'))!.title, 'Tu pago vence mañana');
    final three = hakiPushText(data('3'))!;
    expect(three.title, 'Tu pago vence en 3 días');
    expect(three.body, endsWith('el 13 nov.'));
    // API anterior, sin nombre del coach
    expect(hakiPushText(data('3', coach: null))!.body, startsWith('Pago a tu coach'));
  });

  test('montos', () {
    expect(formatPaymentAmount(45.5, 'USD'), r'$45,5'.replaceAll(',5', ',50'));
    expect(formatPaymentAmount(60, 'USD'), r'$60');
  });

  test('tipo desconocido no se muestra', () {
    expect(hakiPushText({'sender': 'haki', 'type': 'otro'}), isNull);
  });

  group('agenda', () {
    final start = DateTime(2026, 11, 13, 6);
    Map<String, dynamic> ev(String type, [Map<String, dynamic> extra = const {}]) => {
      'sender': 'haki',
      'type': type,
      'title': 'Sesión',
      'eventKind': 'in_person',
      'startsAt': start.toUtc().toIso8601String(),
      'endsAt': start.add(const Duration(hours: 1)).toUtc().toIso8601String(),
      'location': 'Gym Escazú',
      'coach': 'Andrés Solano',
      ...extra,
    };

    test('invitación a una sesión', () {
      final t = hakiPushText(ev('event_invited'))!;
      expect(t.title, 'Andrés te invitó a una sesión');
      expect(t.body, 'Presencial · vie 13 nov · 06:00 · Gym Escazú');
    });

    test('serie semanal: un solo aviso con los días', () {
      final t = hakiPushText(ev('event_invited', {'weekdays': '1,4', 'until': '2026-12-20'}))!;
      expect(t.title, 'Andrés te invitó a sesiones semanales');
      expect(t.body, 'Presencial · Los lunes y jueves 06:00 · hasta el 20 dic · Gym Escazú');
      final c = hakiPushText(ev('event_cancelled', {'weekdays': '1,4', 'until': '2026-12-20'}))!;
      expect(c.title, 'Se cancelaron tus sesiones semanales');
      expect(c.body, contains('desde el 13 nov'));
    });

    test('cambio: el título dice qué cambió', () {
      expect(hakiPushText(ev('event_changed', {'fields': 'time'}))!.title, 'Cambió la hora de tu sesión');
      expect(hakiPushText(ev('event_changed', {'fields': 'place'}))!.title, 'Cambió el lugar de tu sesión');
      expect(hakiPushText(ev('event_changed', {'fields': 'time,place'}))!.title, 'Andrés cambió tu sesión');
    });

    test('Avisarme: 1 hora y 1 día antes', () {
      final hour = hakiPushText(ev('event_reminder', {'remind': '60'}))!;
      expect(hour.title, 'Tu sesión con Andrés es a las 06:00');
      expect(hour.body, 'Presencial · vie 13 nov · 06:00 · Gym Escazú');
      expect(hakiPushText(ev('event_reminder', {'remind': '1440'}))!.title, 'Mañana tenés sesión con Andrés');
      expect(dayOfPayload(hakiPayloadOf(ev('event_reminder'))), DateTime(2026, 11, 13));
    });

    test('virtual sin lugar y tocar abre el día', () {
      final data = ev('event_cancelled', {'eventKind': 'virtual'});
      expect(hakiPushText(data)!.body, 'Virtual · vie 13 nov · 06:00');
      expect(dayOfPayload(hakiPayloadOf(data)), DateTime(2026, 11, 13));
      expect(hakiPayloadOf({'type': 'payment_reminder'}), hakiPushPayload);
    });
  });
}
