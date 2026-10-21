import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Plugin de notificaciones locales compartido (timer de descanso y push del
// chat). Se inicializa una sola vez por isolate: inicializarlo dos veces pisa
// el callback de "tocó la notificación".

final localNotifications = FlutterLocalNotificationsPlugin();

/// Quién atiende el toque en una notificación (lo pone ChatPush; el payload
/// de las del chat es el id del mensaje). Las del timer no tienen payload.
void Function(String? payload)? onNotificationTap;

Future<void>? _init;

Future<void> ensureLocalNotifications() => _init ??= localNotifications
    .initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Los permisos se piden en un momento con contexto (primer descanso,
        // primera vez en el Chat), no al abrir la app
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) =>
          onNotificationTap?.call(r.payload),
    )
    .then((_) {});
