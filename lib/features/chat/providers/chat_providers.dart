import 'dart:async';

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

/// Conecta al usuario a Stream (token de la API) y registra el push. Lo usan
/// el canal general y los grupos. keepAlive; al cerrar sesión
/// `LocalDataGuard` desconecta y lo invalida.
@Riverpod(keepAlive: true)
Future<StreamChatClient> connectedStreamClient(Ref ref) async {
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

  return client;
}

/// Canal general con el coach, conectado y escuchando. keepAlive: el chat
/// queda vivo al cambiar de tab.
@Riverpod(keepAlive: true)
Future<Channel> generalChannel(Ref ref) async {
  final client = await ref.watch(connectedStreamClientProvider.future);
  final (type, id) = await ref.watch(chatRepositoryProvider).generalChannel();
  final channel = client.channel(type, id: id);
  await channel.watch();
  return channel;
}

/// Un grupo del coach con su canal de Stream escuchando.
class GroupChat {
  const GroupChat(this.group, this.channel);

  final ChatGroupDto group;
  final Channel channel;

  /// Lo que dice el canal (se actualiza en vivo si el coach lo cambia); si
  /// no vino, lo de la API.
  bool get athletesCanWrite =>
      channel.extraData['athletesCanWrite'] as bool? ?? group.athletesCanWrite;
  String get name => channel.name ?? group.name;
}

/// Grupos en los que está el atleta. Se recarga solo cuando el coach lo
/// agrega, lo quita o borra un grupo (eventos de Stream). Sin grupos, el tab
/// Chat abre directo el chat con el coach.
@Riverpod(keepAlive: true)
Future<List<GroupChat>> chatGroups(Ref ref) async {
  final client = await ref.watch(connectedStreamClientProvider.future);
  final groups = await ref.watch(chatRepositoryProvider).groups();

  final sub = client
      .on(
        EventType.notificationAddedToChannel,
        EventType.notificationRemovedFromChannel,
        EventType.channelDeleted,
      )
      .where((e) => e.channelType == null || e.channelType == groupChannelType)
      .listen((_) => ref.invalidateSelf());
  ref.onDispose(sub.cancel);

  return Future.wait(
    groups.map((g) async {
      final channel = client.channel(g.channelType, id: g.channelId);
      await channel.watch();
      return GroupChat(g, channel);
    }),
  );
}

/// Tipo de canal de Stream de los grupos (`ChatGroupService.ChannelType`).
const groupChannelType = 'haki_group';

/// No leídos del tab Chat: el chat con el coach + los grupos que conoce esta
/// API (2026-11-09). Antes era `totalUnreadCount` de la cuenta de Stream, que
/// también sumaba canales que la app no muestra (dev y test comparten Stream:
/// un grupo creado en dev quedaba con no leídos imposibles de abrir).
@riverpod
Stream<int> chatUnread(Ref ref) {
  final general = ref.watch(generalChannelProvider).value;
  final groups = ref.watch(chatGroupsProvider).value ?? const [];
  final channels = [?general, for (final g in groups) g.channel];
  if (channels.isEmpty) return Stream.value(0);

  final counts = <String, int>{
    for (final ch in channels) ch.cid ?? '': ch.state?.unreadCount ?? 0,
  };
  int sum() => counts.values.fold(0, (a, b) => a + b);
  final out = StreamController<int>();
  out.add(sum());
  final subs = [
    for (final ch in channels)
      if (ch.state != null)
        ch.state!.unreadCountStream.listen((n) {
          counts[ch.cid ?? ''] = n;
          out.add(sum());
        }),
  ];
  ref.onDispose(() {
    for (final s in subs) {
      unawaited(s.cancel());
    }
    unawaited(out.close());
  });
  return out.stream.distinct();
}
