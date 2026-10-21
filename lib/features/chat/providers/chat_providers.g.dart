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

/// Canal general con el coach, conectado y escuchando. Conecta al usuario la
/// primera vez (token de la API). keepAlive: el chat queda vivo al cambiar de
/// tab; al cerrar sesión `LocalDataGuard` desconecta y lo invalida.

@ProviderFor(generalChannel)
final generalChannelProvider = GeneralChannelProvider._();

/// Canal general con el coach, conectado y escuchando. Conecta al usuario la
/// primera vez (token de la API). keepAlive: el chat queda vivo al cambiar de
/// tab; al cerrar sesión `LocalDataGuard` desconecta y lo invalida.

final class GeneralChannelProvider
    extends $FunctionalProvider<AsyncValue<Channel>, Channel, FutureOr<Channel>>
    with $FutureModifier<Channel>, $FutureProvider<Channel> {
  /// Canal general con el coach, conectado y escuchando. Conecta al usuario la
  /// primera vez (token de la API). keepAlive: el chat queda vivo al cambiar de
  /// tab; al cerrar sesión `LocalDataGuard` desconecta y lo invalida.
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

String _$generalChannelHash() => r'2dc4ad7d90086b24b49d8964e6e856518553b639';
