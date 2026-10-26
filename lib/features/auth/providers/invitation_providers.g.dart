// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Invitación pendiente del usuario logueado (sin caché: hace falta la red
/// para aceptarla igual).

@ProviderFor(myInvitation)
final myInvitationProvider = MyInvitationProvider._();

/// Invitación pendiente del usuario logueado (sin caché: hace falta la red
/// para aceptarla igual).

final class MyInvitationProvider
    extends
        $FunctionalProvider<
          AsyncValue<MyInvitationDto?>,
          MyInvitationDto?,
          FutureOr<MyInvitationDto?>
        >
    with $FutureModifier<MyInvitationDto?>, $FutureProvider<MyInvitationDto?> {
  /// Invitación pendiente del usuario logueado (sin caché: hace falta la red
  /// para aceptarla igual).
  MyInvitationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myInvitationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myInvitationHash();

  @$internal
  @override
  $FutureProviderElement<MyInvitationDto?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MyInvitationDto?> create(Ref ref) {
    return myInvitation(ref);
  }
}

String _$myInvitationHash() => r'3867525a8740cc6813bb8c4c89a862a193f0c7d3';

@ProviderFor(InvitationAccepter)
final invitationAccepterProvider = InvitationAccepterProvider._();

final class InvitationAccepterProvider
    extends $AsyncNotifierProvider<InvitationAccepter, void> {
  InvitationAccepterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'invitationAccepterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$invitationAccepterHash();

  @$internal
  @override
  InvitationAccepter create() => InvitationAccepter();
}

String _$invitationAccepterHash() =>
    r'5d7a8510ff1b2654a728b03e552f99c04ed277ed';

abstract class _$InvitationAccepter extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
