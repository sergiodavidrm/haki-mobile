import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'local_notifications.dart';
import '../../l10n/l10n.dart';

part 'rest_notifications.g.dart';

// Notificaciones del timer de descanso:
// - "corriendo": fija, con cuenta regresiva nativa (Android). Sin sonido.
// - "terminó": programada para endsAt, con sonido. Llega aunque la app esté en
//   segundo plano, cerrada o con el teléfono bloqueado.
// iOS solo tiene la de "terminó": la cuenta regresiva en la pantalla de
// bloqueo necesita Live Activities (nativo, pendiente).
class RestNotifications {
  final _plugin = localNotifications;
  Future<void>? _init;
  bool _askedPermission = false;

  static const _runningId = 1001;
  static const _doneId = 1002;

  // Android fija la vibración por canal: uno para cada opción de Ajustes
  static NotificationDetails get _doneNoVibration => NotificationDetails(
    android: AndroidNotificationDetails(
      'rest_timer_done_quiet',
      l10n.notifRestDoneQuietChannel,
      channelDescription: l10n.notifRestDoneChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: false,
      category: AndroidNotificationCategory.alarm,
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    ),
  );

  static NotificationDetails get _done => NotificationDetails(
    android: AndroidNotificationDetails(
      'rest_timer_done',
      l10n.notifRestDoneChannel,
      channelDescription: l10n.notifRestDoneChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm,
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    ),
  );

  Future<void> _ensureInit() => _init ??= () async {
    tzdata.initializeTimeZones();
    // Compartido con el push del chat (un solo initialize)
    await ensureLocalNotifications();
  }();

  /// Pide el permiso de notificaciones la primera vez (momento con contexto:
  /// el atleta acaba de iniciar un descanso).
  Future<void> _ensurePermission() async {
    if (_askedPermission) return;
    _askedPermission = true;
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, sound: true);
    }
  }

  /// Muestra la cuenta regresiva y programa el aviso de fin ([vibrate]:
  /// Ajustes → Vibrar al terminar el descanso).
  Future<void> start(
    DateTime endsAt, {
    String? title,
    bool vibrate = true,
  }) async {
    try {
      await _ensureInit();
      await _ensurePermission();
      await cancel();

      if (Platform.isAndroid) {
        final left = endsAt.difference(DateTime.now()).inMilliseconds;
        await _plugin.show(
          id: _runningId,
          payload: restNotificationPayload,
          title: l10n.restTitle,
          body: title ?? l10n.notifBackToWorkout,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'rest_timer_running',
              l10n.notifRestRunningChannel,
              channelDescription: l10n.notifRestRunningChannelDesc,
              importance: Importance.low,
              priority: Priority.low,
              playSound: false,
              enableVibration: false,
              ongoing: true,
              autoCancel: false,
              onlyAlertOnce: true,
              usesChronometer: true,
              chronometerCountDown: true,
              when: endsAt.millisecondsSinceEpoch,
              timeoutAfter: left > 0 ? left : null,
              category: AndroidNotificationCategory.stopwatch,
            ),
          ),
        );
      }

      await _plugin.zonedSchedule(
        id: _doneId,
        payload: restNotificationPayload,
        title: l10n.restGo,
        body: title == null
            ? l10n.notifRestOver
            : '${l10n.notifRestOver} · $title',
        scheduledDate: tz.TZDateTime.from(endsAt.toUtc(), tz.UTC),
        notificationDetails: vibrate ? _done : _doneNoVibration,
        androidScheduleMode: await _scheduleMode(),
      );
    } catch (e) {
      // Sin notificaciones el timer sigue funcionando dentro de la app
      debugPrint('RestNotifications: $e');
    }
  }

  /// Exacto si el sistema lo permite (Android 14 lo pide aparte); si no,
  /// inexacto (con el teléfono en uso llega casi a tiempo).
  Future<AndroidScheduleMode> _scheduleMode() async {
    if (!Platform.isAndroid) return AndroidScheduleMode.exactAllowWhileIdle;
    final canExact = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.canScheduleExactNotifications();
    return canExact == true
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// En pausa: queda la notificación fija con el tiempo que falta (sin
  /// cuenta regresiva) y se cancela el aviso de fin; al seguir se vuelve a
  /// programar con [start].
  Future<void> paused(int leftSeconds, {String? title}) async {
    try {
      await _ensureInit();
      await _plugin.cancel(id: _doneId);
      if (!Platform.isAndroid) return;
      final clock =
          '${leftSeconds ~/ 60}:${(leftSeconds % 60).toString().padLeft(2, '0')}';
      await _plugin.show(
        id: _runningId,
        payload: restNotificationPayload,
        title: '${l10n.notifRestPaused} · $clock',
        body: title ?? l10n.notifBackToWorkout,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'rest_timer_running',
            l10n.notifRestRunningChannel,
            channelDescription: l10n.notifRestRunningChannelDesc,
            importance: Importance.low,
            priority: Priority.low,
            playSound: false,
            enableVibration: false,
            ongoing: true,
            autoCancel: false,
            onlyAlertOnce: true,
            showWhen: false,
            category: AndroidNotificationCategory.stopwatch,
          ),
        ),
      );
    } catch (e) {
      debugPrint('RestNotifications: $e');
    }
  }

  Future<void> cancel() async {
    if (_init == null) return;
    try {
      await _plugin.cancel(id: _runningId);
      await _plugin.cancel(id: _doneId);
    } catch (e) {
      debugPrint('RestNotifications: $e');
    }
  }
}

@Riverpod(keepAlive: true)
RestNotifications restNotifications(Ref ref) => RestNotifications();
