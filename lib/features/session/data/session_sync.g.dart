// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionSync)
final sessionSyncProvider = SessionSyncProvider._();

final class SessionSyncProvider
    extends $FunctionalProvider<SessionSync, SessionSync, SessionSync>
    with $Provider<SessionSync> {
  SessionSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionSyncHash();

  @$internal
  @override
  $ProviderElement<SessionSync> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionSync create(Ref ref) {
    return sessionSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionSync value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionSync>(value),
    );
  }
}

String _$sessionSyncHash() => r'1ac8f90123fc23d20c27fb1d40eb03bd34280c01';
