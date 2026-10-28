import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/chat/providers/chat_push.dart';
import '../../features/session/providers/rest_timer.dart';
import '../router/app_router.dart';
import 'local_notifications.dart';

part 'notification_taps.g.dart';

// A dónde lleva tocar una notificación (todas comparten el callback de
// local_notifications.dart):
// - timer de descanso (payload [restNotificationPayload]) → pantalla Descanso
//   si el timer sigue activo; si no, la app queda donde estaba (la Sesión).
// - chat (payload = id del mensaje) → Chat o el hilo de feedback.
// - cuestionario (sin payload) → la app abre donde estaba (Hoy al arrancar).

const _lastLaunchKey = 'last_launch_notification';

class NotificationTaps {
  NotificationTaps(this._ref);

  final Ref _ref;

  Future<void> init() async {
    await ensureLocalNotifications();
    onNotificationTap = _handle;

    // Abrió la app tocando una notificación (estaba cerrada). En Android, si
    // el sistema mató el proceso y la tarea seguía en recientes, la app
    // vuelve con el intent que la abrió la primera vez (p. ej. una
    // notificación del chat) aunque se haya tocado otra (la del timer): sin
    // este control abría el chat. Cada notificación se atiende una sola vez.
    final launch = await localNotifications.getNotificationAppLaunchDetails();
    final payload = launch?.notificationResponse?.payload;
    if (!(launch?.didNotificationLaunchApp ?? false) || payload == null) return;
    final prefs = SharedPreferencesAsync();
    if (await prefs.getString(_lastLaunchKey) == payload) return;
    await prefs.setString(_lastLaunchKey, payload);
    _handle(payload);
  }

  void _handle(String? payload) {
    if (payload == null) return;
    if (payload == restNotificationPayload) {
      _openRest();
      return;
    }
    unawaited(_ref.read(chatPushProvider).openMessage(payload));
  }

  void _openRest() {
    if (!_ref.read(restTimerProvider).active) return;
    final router = _ref.read(appRouterProvider);
    final path = router.routerDelegate.currentConfiguration.uri.path;
    if (path != Routes.rest) router.push(Routes.rest);
  }
}

@Riverpod(keepAlive: true)
NotificationTaps notificationTaps(Ref ref) {
  final taps = NotificationTaps(ref);
  unawaited(taps.init());
  return taps;
}
