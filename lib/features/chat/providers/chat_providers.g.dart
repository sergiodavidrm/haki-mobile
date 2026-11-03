// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cliente de Stream de toda la app (la API key es pública). Lo envuelve
/// `StreamChatCore` en app.dart: desconecta en background y reconecta al
/// volver.

@ProviderFor(streamClient)
final streamClientProvider = StreamClientProvider._();

/// Cliente de Stream de toda la app (la API key es pública). Lo envuelve
/// `StreamChatCore` en app.dart: desconecta en background y reconecta al
/// volver.

final class StreamClientProvider
    extends
        $FunctionalProvider<
          StreamChatClient,
          StreamChatClient,
          StreamChatClient
        >
    with $Provider<StreamChatClient> {
  /// Cliente de Stream de toda la app (la API key es pública). Lo envuelve
  /// `StreamChatCore` en app.dart: desconecta en background y reconecta al
  /// volver.
  StreamClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streamClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streamClientHash();

  @$internal
  @override
  $ProviderElement<StreamChatClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StreamChatClient create(Ref ref) {
    return streamClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StreamChatClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StreamChatClient>(value),
    );
  }
}

String _$streamClientHash() => r'deba2db2822f117817c75064bf00b8b4686dff73';

/// Conecta al usuario a Stream (token de la API) y registra el push. Lo usan
/// el canal general y los grupos. keepAlive; al cerrar sesión
/// `LocalDataGuard` desconecta y lo invalida.

@ProviderFor(connectedStreamClient)
final connectedStreamClientProvider = ConnectedStreamClientProvider._();

/// Conecta al usuario a Stream (token de la API) y registra el push. Lo usan
/// el canal general y los grupos. keepAlive; al cerrar sesión
/// `LocalDataGuard` desconecta y lo invalida.

final class ConnectedStreamClientProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreamChatClient>,
          StreamChatClient,
          FutureOr<StreamChatClient>
        >
    with $FutureModifier<StreamChatClient>, $FutureProvider<StreamChatClient> {
  /// Conecta al usuario a Stream (token de la API) y registra el push. Lo usan
  /// el canal general y los grupos. keepAlive; al cerrar sesión
  /// `LocalDataGuard` desconecta y lo invalida.
  ConnectedStreamClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectedStreamClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectedStreamClientHash();

  @$internal
  @override
  $FutureProviderElement<StreamChatClient> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StreamChatClient> create(Ref ref) {
    return connectedStreamClient(ref);
  }
}

String _$connectedStreamClientHash() =>
    r'81565542db290a49c0c6d85cef54b93e92411e8b';

/// Canal general con el coach, conectado y escuchando. keepAlive: el chat
/// queda vivo al cambiar de tab.

@ProviderFor(generalChannel)
final generalChannelProvider = GeneralChannelProvider._();

/// Canal general con el coach, conectado y escuchando. keepAlive: el chat
/// queda vivo al cambiar de tab.

final class GeneralChannelProvider
    extends $FunctionalProvider<AsyncValue<Channel>, Channel, FutureOr<Channel>>
    with $FutureModifier<Channel>, $FutureProvider<Channel> {
  /// Canal general con el coach, conectado y escuchando. keepAlive: el chat
  /// queda vivo al cambiar de tab.
  GeneralChannelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generalChannelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generalChannelHash();

  @$internal
  @override
  $FutureProviderElement<Channel> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Channel> create(Ref ref) {
    return generalChannel(ref);
  }
}

String _$generalChannelHash() => r'd6a14b8a4579a3503a719ce0a0ba7ffeeff85282';

/// Grupos en los que está el atleta. Se recarga solo cuando el coach lo
/// agrega, lo quita o borra un grupo (eventos de Stream). Sin grupos, el tab
/// Chat abre directo el chat con el coach.

@ProviderFor(chatGroups)
final chatGroupsProvider = ChatGroupsProvider._();

/// Grupos en los que está el atleta. Se recarga solo cuando el coach lo
/// agrega, lo quita o borra un grupo (eventos de Stream). Sin grupos, el tab
/// Chat abre directo el chat con el coach.

final class ChatGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupChat>>,
          List<GroupChat>,
          FutureOr<List<GroupChat>>
        >
    with $FutureModifier<List<GroupChat>>, $FutureProvider<List<GroupChat>> {
  /// Grupos en los que está el atleta. Se recarga solo cuando el coach lo
  /// agrega, lo quita o borra un grupo (eventos de Stream). Sin grupos, el tab
  /// Chat abre directo el chat con el coach.
  ChatGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatGroupsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatGroupsHash();

  @$internal
  @override
  $FutureProviderElement<List<GroupChat>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GroupChat>> create(Ref ref) {
    return chatGroups(ref);
  }
}

String _$chatGroupsHash() => r'8dc9a2e7c4f7e48876feb9aa61c8dcf95cea7e76';
