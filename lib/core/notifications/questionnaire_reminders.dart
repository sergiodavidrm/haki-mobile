import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/questionnaire/data/questionnaire_dtos.dart';
import '../../l10n/l10n.dart';
import 'local_notifications.dart';

part 'questionnaire_reminders.g.dart';

// Aviso local de los cuestionarios semanales: el día de envío a las 20:00 del
// teléfono (el backend crea el envío a esa hora y todavía no manda push).
// Se programan las próximas [_weeksAhead] semanas de cada uno sin repetir y se
// reprograman cada vez que llegan los cuestionarios (abrir la app, volver a
// primer plano): si el coach saca uno, deja de avisar en la próxima apertura.
// Sin payload: al tocarla la app abre en Hoy, donde está la tarjeta.
class QuestionnaireReminders {
  static const _baseId = 3000;
  static const _maxQuestionnaires = 10;
  static const _weeksAhead = 4;
  static const _sendHour = 20;

  /// Misma clave que el push del chat: el permiso se pide una sola vez.
  static const _askedKey = 'push_permission_asked';

  Future<void>? _init;
  String? _lastSignature;

  static NotificationDetails get _details => NotificationDetails(
    android: AndroidNotificationDetails(
      'questionnaires',
      l10n.notifQuestionnaireChannel,
      channelDescription: l10n.notifQuestionnaireChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentSound: true,
    ),
  );

  Future<void> _ensureInit() => _init ??= () async {
    tzdata.initializeTimeZones();
    await ensureLocalNotifications();
  }();

  Future<void> sync(List<WeeklySchedule> schedule) async {
    final signature = [
      for (final s in schedule) '${s.weekday}:${s.name}',
      l10n.localeName,
      _todayKey(),
    ].join('|');
    if (signature == _lastSignature) return;
    _lastSignature = signature;

    try {
      await _ensureInit();
      for (var i = 0; i < _maxQuestionnaires * _weeksAhead; i++) {
        await localNotifications.cancel(id: _baseId + i);
      }
      if (schedule.isEmpty) return;
      await _askPermissionOnce();

      final mode = await _scheduleMode();
      final now = DateTime.now();
      for (final (i, s) in schedule.take(_maxQuestionnaires).indexed) {
        for (final (k, at) in nextSends(s.weekday, now).indexed) {
          await localNotifications.zonedSchedule(
            id: _baseId + i * _weeksAhead + k,
            title: s.name,
            body: l10n.notifQuestionnaireBody,
            scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
            notificationDetails: _details,
            androidScheduleMode: mode,
          );
        }
      }
    } catch (e) {
      // Sin avisos la tarjeta de Hoy igual aparece
      debugPrint('QuestionnaireReminders: $e');
    }
  }

  /// Próximos días [weekday] a las 20:00 (hora del teléfono), desde ahora.
  @visibleForTesting
  static List<DateTime> nextSends(int weekday, DateTime now) {
    var d = DateTime(
      now.year,
      now.month,
      now.day + (weekday - now.weekday + 7) % 7,
      _sendHour,
    );
    if (!d.isAfter(now)) d = DateTime(d.year, d.month, d.day + 7, _sendHour);
    return [
      for (var k = 0; k < _weeksAhead; k++)
        DateTime(d.year, d.month, d.day + 7 * k, _sendHour),
    ];
  }

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  Future<void> _askPermissionOnce() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_askedKey) ?? false) return;
    await prefs.setBool(_askedKey, true);
    if (Platform.isAndroid) {
      await localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, sound: true);
    }
  }

  /// Un recordatorio no necesita ser exacto al segundo: exacto si el sistema
  /// lo permite, si no inexacto.
  Future<AndroidScheduleMode> _scheduleMode() async {
    if (!Platform.isAndroid) return AndroidScheduleMode.exactAllowWhileIdle;
    final canExact = await localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.canScheduleExactNotifications();
    return canExact == true
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }
}

@Riverpod(keepAlive: true)
QuestionnaireReminders questionnaireReminders(Ref ref) =>
    QuestionnaireReminders();
