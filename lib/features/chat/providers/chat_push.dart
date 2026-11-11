import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../../../core/network/api_client.dart';
import '../../../core/notifications/haki_push.dart';
import '../../agenda/providers/agenda_providers.dart';
import '../../inbox/providers/inbox_providers.dart';
import '../../../core/notifications/local_notifications.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../data/chat_notifications.dart';
import '../ui/feedback_thread_screen.dart';
import 'chat_providers.dart';
import '../../../l10n/l10n.dart';

part 'chat_push.g.dart';

// Push del chat (2026-10-21): FCM + integración de push de Stream (provider
// "firebase" en su dashboard, con la clave de cuenta de servicio de Firebase).
// Stream manda la push cuando el atleta no está conectado al chat (app en
// segundo plano o cerrada: StreamChatCore corta la conexión). Es v3: solo
// datos, la notificación la arma la app (data/chat_notifications.dart). Acá:
// registrar el teléfono, pedir el permiso y abrir el chat/hilo al tocarla.

/// Nombre del push provider en el dashboard de Stream.
const _pushProviderName = 'firebase';
const _askedKey = 'push_permission_asked';

class ChatPush {
  ChatPush(this._ref);

  final Ref _ref;
  var _ready = false;
  var _askChecked = false;
  String? _token;
  StreamSubscription<String>? _refreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  String? _apiToken;

  Future<void> init() async {
    // Firebase.initializeApp va en main(); sin config (iOS sin plist) no hay push
    if (Firebase.apps.isEmpty) return;
    _ready = true;

    await ensureLocalNotifications();
    if (Platform.isAndroid) {
      await localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(chatChannel);
      await localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(remindersChannel);
    }

    // Push de la API con la app abierta: se muestra igual (los del chat no,
    // ahí el aviso es el badge)
    _foregroundSub = FirebaseMessaging.onMessage.listen((m) {
      if (!isHakiPush(m.data)) return;
      unawaited(showHakiPush(m.data));
      // Campana y sesiones al día sin esperar a volver a la app
      _ref.invalidate(myInboxProvider);
      if (eventInboxKinds.contains(m.data['type'])) {
        _ref.invalidate(myAgendaProvider);
      }
    });
    _ref.read(authRepositoryProvider).beforeSignOut = _unregisterApi;

    // El toque en la notificación lo reparte NotificationTaps
    // (core/notifications/notification_taps.dart) → openMessage.
    // Con la app abierta no se muestra push (decisión de Sergio): el aviso
    // es el badge del tab Chat. FCM solo trae datos, así que no aparece nada.
  }

  /// Registra este teléfono en Stream para el usuario conectado y guarda sus
  /// credenciales para el handler de fondo.
  Future<void> register(StreamChatClient client, String token) async {
    if (!_ready) return;
    final user = client.state.currentUser;
    if (user == null) return;
    await saveStreamCredentials(user.id, token);

    // getToken/onTokenRefresh (deprecados en firebase_messaging 17): Stream
    // necesita el token de registro de FCM; register()/onRegistered dan el ID
    // de instalación (FID) para el envío directo nuevo, que Stream no usa.
    // ignore: deprecated_member_use
    final fcm = await FirebaseMessaging.instance.getToken();
    if (fcm == null) return;
    _token = fcm;
    unawaited(_registerApi(fcm));
    await client.addDevice(
      fcm,
      PushProvider.firebase,
      pushProviderName: _pushProviderName,
    );
    // ignore: deprecated_member_use
    _refreshSub ??= FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      _token = t;
      unawaited(_registerApi(t));
      unawaited(
        client
            .addDevice(
              t,
              PushProvider.firebase,
              pushProviderName: _pushProviderName,
            )
            .catchError((_) => EmptyResponse()),
      );
    });
  }

  /// Este teléfono recibe los push de la API (recordatorios de pago…).
  Future<void> _registerApi(String token) async {
    try {
      await _ref.read(apiClientProvider).put<void>(
        '/push/devices',
        data: {
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
      );
      _apiToken = token;
    } catch (e) {
      debugPrint('ChatPush: no se pudo registrar en la API ($e)');
    }
  }

  /// Antes de cerrar sesión (con el JWT todavía válido).
  Future<void> _unregisterApi() async {
    final token = _apiToken;
    if (token == null) return;
    await _ref.read(apiClientProvider).delete<void>(
      '/push/devices',
      queryParameters: {'token': token},
    );
    _apiToken = null;
  }

  /// Al cerrar sesión: que no le lleguen al teléfono los mensajes del usuario.
  Future<void> unregister(StreamChatClient client) async {
    await clearStreamCredentials();
    final token = _token;
    if (!_ready || token == null) return;
    try {
      await client.removeDevice(token);
    } catch (_) {
      // sin red: Stream lo descarta cuando el token deje de servir
    }
    _token = null;
  }

  /// Pide el permiso la primera vez que entra al Chat (momento con contexto).
  /// Si ya lo dio (p. ej. con el timer de descanso) Android no muestra nada.
  Future<void> askPermissionOnce() async {
    if (!_ready || _askChecked) return;
    _askChecked = true;
    final prefs = SharedPreferencesAsync();
    if (await prefs.getBool(_askedKey) ?? false) return;
    await prefs.setBool(_askedKey, true);
    await FirebaseMessaging.instance.requestPermission();
  }

  /// Tocó una notificación ([messageId] = su payload): al Chat y, si es una
  /// respuesta de un hilo de feedback, al hilo.
  Future<void> openMessage(String messageId) async {
    final router = _ref.read(appRouterProvider);
    router.go(Routes.chat);
    try {
      final channel = await _ref.read(generalChannelProvider.future);
      final res = await channel.client.getMessage(messageId);
      // Mensaje de un grupo: abrir el grupo
      if (res.channel?.type == groupChannelType && res.channel?.id != null) {
        final id = res.channel!.id;
        // Un grupo que la lista no tiene: lo agregaron con la app en segundo
        // plano (Stream desconectado, se perdió el evento) → recargar antes
        // de abrirlo; si no, decía "Ya no estás en este grupo"
        final known =
            _ref
                .read(chatGroupsProvider)
                .value
                ?.any((g) => g.channel.id == id) ??
            false;
        if (!known) _ref.invalidate(chatGroupsProvider);
        router.push(Routes.chatGroup(id));
        return;
      }
      final message = res.message;
      final parentId = message.parentId;
      if (parentId == null) return;
      final parent = (await channel.client.getMessage(parentId)).message;
      final context = router.routerDelegate.navigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      final coach = _ref.read(authMeProvider).value?.coachName ?? l10n.yourCoach;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => StreamChannel(
            channel: channel,
            child: FeedbackThreadScreen(parent: parent, coachName: coach),
          ),
        ),
      );
    } catch (e) {
      debugPrint('ChatPush: no se pudo abrir el mensaje ($e)');
    }
  }

  void dispose() {
    unawaited(_refreshSub?.cancel());
    unawaited(_foregroundSub?.cancel());
  }
}

@Riverpod(keepAlive: true)
ChatPush chatPush(Ref ref) {
  final push = ChatPush(ref);
  unawaited(push.init());
  ref.onDispose(push.dispose);
  return push;
}
