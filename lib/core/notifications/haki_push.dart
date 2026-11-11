import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';
import '../format/dates.dart';
import 'local_notifications.dart';

// Push que manda haki-api (2026-11-10; el chat lo manda Stream). Como el del
// chat, FCM trae solo datos (`sender: haki`, `type`, …) y la notificación la
// arma la app, en el idioma del atleta. Funciona en segundo plano (lo llama
// el handler de fondo de FCM) y con la app abierta (`onMessage`).

/// Payload de las notificaciones de la API: tocarlas abre Hoy.
const hakiPushPayload = 'haki:home';

/// Avisos de la agenda: tocarlos abre Hoy en el día de la sesión.
const hakiDayPayloadPrefix = 'haki:day:';

String hakiDayPayload(DateTime day) =>
    '$hakiDayPayloadPrefix${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

/// Día de un payload [hakiDayPayload] (null si no es uno).
DateTime? dayOfPayload(String payload) {
  if (!payload.startsWith(hakiDayPayloadPrefix)) return null;
  return DateTime.tryParse(payload.substring(hakiDayPayloadPrefix.length));
}

/// Tipos de la agenda (campana + push), ver haki-api § Campana.
const eventInboxKinds = {'event_invited', 'event_changed', 'event_cancelled'};

/// Inicio de la sesión de un aviso de la agenda, en hora local.
DateTime? eventStartOf(Map<String, dynamic> data) =>
    DateTime.tryParse('${data['startsAt']}')?.toLocal();

bool isHakiPush(Map<String, dynamic> data) => data['sender'] == 'haki';

AndroidNotificationChannel get remindersChannel => AndroidNotificationChannel(
  'haki_reminders',
  l10n.notifRemindersChannel,
  description: l10n.notifRemindersChannelDesc,
  importance: Importance.high,
);

/// Título y texto de un push de la API (null = tipo desconocido: una versión
/// más nueva de la API manda algo que esta app no conoce, no se muestra).
({String title, String body})? hakiPushText(Map<String, dynamic> data) {
  switch (data['type']) {
    case 'test':
      return (title: l10n.notifTestTitle, body: l10n.notifTestBody);
    case 'payment_reminder':
      final days = int.tryParse('${data['days']}') ?? 0;
      final amount = formatPaymentAmount(
        num.tryParse('${data['amount']}') ?? 0,
        '${data['currency']}',
      );
      // Mismo texto que la vista previa del cobro en el web
      final coach = '${data['coach'] ?? ''}'.trim();
      final who = coach.isEmpty ? l10n.yourCoach.toLowerCase() : coach;
      final date = DateTime.tryParse('${data['date']}');
      if (days <= 0 || date == null) {
        return (
          title: l10n.notifPaymentDueTodayTitle,
          body: l10n.notifPaymentDueTodayBody(who, amount),
        );
      }
      return (
        title: l10n.notifPaymentDueInTitle(days),
        body: l10n.notifPaymentDueInBody(who, amount, formatDayMonth(date)),
      );
    case 'event_invited' || 'event_changed' || 'event_cancelled' ||
        'event_reminder':
      return _eventText('${data['type']}', data);
  }
  return null;
}

({String title, String body})? _eventText(
  String type,
  Map<String, dynamic> data,
) {
  final start = eventStartOf(data);
  if (start == null) return null;
  final coachFull = '${data['coach'] ?? ''}'.trim();
  final coach = coachFull.isEmpty
      ? l10n.yourCoach
      : coachFull.split(RegExp(r'\s+')).first;
  final weekdays = '${data['weekdays'] ?? ''}'
      .split(',')
      .map(int.tryParse)
      .whereType<int>()
      .where((d) => d >= 1 && d <= 7)
      .toList();
  final until = DateTime.tryParse('${data['until'] ?? ''}');
  final series = weekdays.isNotEmpty && until != null;

  final parts = <String>[
    data['eventKind'] == 'virtual'
        ? l10n.agendaKindVirtual
        : l10n.agendaKindInPerson,
  ];
  if (series) {
    parts.add(
      '${l10n.notifEventEvery(joinWords(weekdays.map(weekdayName).toList()))} '
      '${formatTime(start)}',
    );
    parts.add(
      type == 'event_cancelled'
          ? l10n.notifEventFrom(formatDayMonth(start))
          : l10n.notifEventUntil(formatDayMonth(until)),
    );
  } else {
    parts.add(formatShortDate(start));
    parts.add(formatTime(start));
  }
  final location = '${data['location'] ?? ''}'.trim();
  if (location.isNotEmpty && data['eventKind'] != 'virtual') {
    parts.add(location);
  }
  final body = parts.join(' · ');

  final title = switch (type) {
    // "Avisarme" del coach (solo push): 1 día o 1 hora antes
    'event_reminder' when '${data['remind']}' == '1440' =>
      l10n.notifEventReminderTomorrowTitle(coach),
    'event_reminder' => l10n.notifEventReminderTitle(coach, formatTime(start)),
    'event_invited' when series => l10n.notifEventInvitedSeriesTitle(coach),
    'event_invited' => l10n.notifEventInvitedTitle(coach),
    'event_cancelled' when series => l10n.notifEventCancelledSeriesTitle,
    'event_cancelled' => l10n.notifEventCancelledTitle,
    _ => switch ('${data['fields'] ?? ''}') {
      'time' => l10n.notifEventTimeChangedTitle,
      'place' => l10n.notifEventPlaceChangedTitle,
      'link' => l10n.notifEventLinkChangedTitle,
      _ => l10n.notifEventChangedTitle(coach),
    },
  };
  return (title: title, body: body);
}

/// "lunes y jueves" / "lunes, miércoles y viernes"
String joinWords(List<String> words) {
  if (words.length <= 1) return words.join();
  return '${words.sublist(0, words.length - 1).join(', ')} '
      '${l10n.commonAnd} ${words.last}';
}

/// Payload al tocar: los de la agenda abren Hoy en el día de la sesión.
String hakiPayloadOf(Map<String, dynamic> data) {
  if (eventInboxKinds.contains(data['type']) ||
      data['type'] == 'event_reminder') {
    final start = eventStartOf(data);
    if (start != null) return hakiDayPayload(start);
  }
  return hakiPushPayload;
}

/// "₡45 000" / "$45.50" según el idioma activo.
String formatPaymentAmount(num amount, String currency) {
  final symbol = currency == 'USD' ? r'$' : '₡';
  final digits = currency == 'USD' && amount != amount.truncate() ? 2 : 0;
  final number = NumberFormat.decimalPatternDigits(
    locale: l10n.localeName,
    decimalDigits: digits,
  ).format(amount);
  return '$symbol$number';
}

Future<void> showHakiPush(Map<String, dynamic> data) async {
  final text = hakiPushText(data);
  if (text == null) return;
  try {
    await ensureLocalNotifications();
    await localNotifications.show(
      id: '${data['type']}:${data['inboxId'] ?? data['date'] ?? ''}'.hashCode,
      title: text.title,
      body: text.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          remindersChannel.id,
          remindersChannel.name,
          channelDescription: remindersChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(text.body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
        ),
      ),
      payload: hakiPayloadOf(data),
    );
  } catch (e) {
    debugPrint('HakiPush: no se pudo mostrar la notificación ($e)');
  }
}
