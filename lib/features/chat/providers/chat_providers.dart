import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../../../core/config/env.dart';
import '../data/chat_repository.dart';
import 'chat_push.dart';

part 'chat_providers.g.dart';

/// Cliente de Stream de toda la app (la API key es pública). Lo envuelve
/// `StreamChatCore` en app.dart: desconecta en background y reconecta al
/// volver.
@Riverpod(keepAlive: true)
StreamChatClient streamClient(Ref ref) {
  final client = StreamChatClient(Env.streamApiKey, logLevel: Level.WARNING);
  ref.onDispose(client.dispose);
  return client;
}

/// Canal general con el coach, conectado y escuchando. Conecta al usuario la
/// primera vez (token de la API). keepAlive: el chat queda vivo al cambiar de
/// tab; al cerrar sesión `LocalDataGuard` desconecta y lo invalida.
@Riverpod(keepAlive: true)
Future<Channel> generalChannel(Ref ref) async {
  final client = ref.watch(streamClientProvider);
  final repo = ref.watch(chatRepositoryProvider);

  final token = await repo.token();
  final current = client.state.currentUser?.id;
  if (current != token.userId) {
    if (current != null) await client.disconnectUser();
    await client.connectUser(
      User(id: token.userId, name: token.userName),
      token.token,
    );
    // Push: registrar este teléfono (si falla, el chat anda igual)
    try {
      await ref.read(chatPushProvider).register(client, token.token);
    } catch (e) {
      debugPrint('ChatPush: no se pudo registrar el teléfono ($e)');
    }
  }

  final (type, id) = await repo.generalChannel();
  final channel = client.channel(type, id: id);
  await channel.watch();
  return channel;
}
