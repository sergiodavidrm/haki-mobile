// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Campana de avisos. Se recarga al volver a primer plano y cuando llega un
/// push de la API con la app abierta (`ChatPush`).

@ProviderFor(MyInbox)
final myInboxProvider = MyInboxProvider._();

/// Campana de avisos. Se recarga al volver a primer plano y cuando llega un
/// push de la API con la app abierta (`ChatPush`).
final class MyInboxProvider extends $AsyncNotifierProvider<MyInbox, Inbox> {
  /// Campana de avisos. Se recarga al volver a primer plano y cuando llega un
  /// push de la API con la app abierta (`ChatPush`).
  MyInboxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myInboxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myInboxHash();

  @$internal
  @override
  MyInbox create() => MyInbox();
}

String _$myInboxHash() => r'ed13fe59d3ce38086236227a6e7d06d64a9b4feb';

/// Campana de avisos. Se recarga al volver a primer plano y cuando llega un
/// push de la API con la app abierta (`ChatPush`).

abstract class _$MyInbox extends $AsyncNotifier<Inbox> {
  FutureOr<Inbox> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Inbox>, Inbox>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Inbox>, Inbox>,
              AsyncValue<Inbox>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
