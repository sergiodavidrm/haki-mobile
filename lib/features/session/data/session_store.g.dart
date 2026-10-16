// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionStore)
final sessionStoreProvider = SessionStoreProvider._();

final class SessionStoreProvider
    extends $FunctionalProvider<SessionStore, SessionStore, SessionStore>
    with $Provider<SessionStore> {
  SessionStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionStoreHash();

  @$internal
  @override
  $ProviderElement<SessionStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionStore create(Ref ref) {
    return sessionStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionStore>(value),
    );
  }
}

String _$sessionStoreHash() => r'd9455c7d52895800c230b31e9eb9d172c801b153';
