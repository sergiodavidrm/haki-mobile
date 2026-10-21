import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../../../core/config/env.dart';
import '../../../core/notifications/local_notifications.dart';
import 'chat_message.dart';

// Push del chat con Stream v3: Stream manda a Firebase mensajes SOLO de datos
// (ids del mensaje y del canal, sin título ni texto), así que la notificación
// la arma la app: con el id se pide el mensaje a Stream y se muestra local.
// Funciona con la app en segundo plano o cerrada (handler de fondo, otro
// isolate): por eso las credenciales de Stream del atleta quedan guardadas en
// el almacenamiento seguro del teléfono (se borran al cerrar sesión).

const _credsKey = 'stream_user';
const _storage = FlutterSecureStorage();

/// Canal de Android de los mensajes del chat.
const chatChannel = AndroidNotificationChannel(
  'chat_messages',
  'Mensajes de tu coach',
  description: 'Chat y feedback de tu coach',
  importance: Importance.high,
);

Future<void> saveStreamCredentials(String userId, String token) => _storage
    .write(key: _credsKey, value: jsonEncode({'id': userId, 'token': token}));

Future<void> clearStreamCredentials() => _storage.delete(key: _credsKey);

/// Handler de FCM con la app en segundo plano o cerrada (otro isolate: no
/// hay providers ni el cliente de Stream de la app).
@pragma('vm:entry-point')
Future<void> chatPushBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await showChatNotification(message.data);
}

/// Muestra la notificación de un `message.new` de Stream. Con [client]
/// (app abierta) usa ese; si no, se conecta solo por REST con las
/// credenciales guardadas.
Future<void> showChatNotification(
  Map<String, dynamic> data, {
  StreamChatClient? client,
}) async {
  if (data['sender'] != 'stream.chat' || data['type'] != 'message.new') return;
  final id = data['id'] ?? data['message_id'];
  if (id is! String) return;

  final raw = await _storage.read(key: _credsKey);
  if (raw == null) return;
  final creds = jsonDecode(raw) as Map<String, dynamic>;
  final me = creds['id'] as String;

  final own = client == null;
  final c = client ?? StreamChatClient(Env.streamApiKey, logLevel: Level.OFF);
  try {
    if (own) {
      await c.connectUser(
        User(id: me),
        creds['token'] as String,
        connectWebSocket: false,
      );
    }
    final msg = (await c.getMessage(id)).message;
    if (msg.user?.id == me) return; // lo mandó el atleta (sus tarjetas)

    final name = msg.user?.name ?? 'Tu coach';
    final card = VideoCard.of(msg);
    final text = (msg.text ?? '').trim();
    final body = text.isNotEmpty
        ? text
        : card != null
        ? 'Videos de ${card.exerciseName}'
        : 'Te mandó un mensaje';

    await ensureLocalNotifications();
    await localNotifications.show(
      id: msg.id.hashCode,
      title: msg.parentId != null ? 'Feedback de $name' : name,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          chatChannel.id,
          chatChannel.name,
          channelDescription: chatChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.message,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
        ),
      ),
      payload: msg.id,
    );
  } catch (e) {
    debugPrint('ChatPush: no se pudo mostrar la notificación ($e)');
  } finally {
    if (own) {
      await c.disconnectUser();
      await c.dispose();
    }
  }
}
