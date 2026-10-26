// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(invitationRepository)
final invitationRepositoryProvider = InvitationRepositoryProvider._();

final class InvitationRepositoryProvider
    extends
        $FunctionalProvider<
          InvitationRepository,
          InvitationRepository,
          InvitationRepository
        >
    with $Provider<InvitationRepository> {
  InvitationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'invitationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$invitationRepositoryHash();

  @$internal
  @override
  $ProviderElement<InvitationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InvitationRepository create(Ref ref) {
    return invitationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InvitationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InvitationRepository>(value),
    );
  }
}

String _$invitationRepositoryHash() =>
    r'2fd45695b85f52119057e491bfc4f73656537b45';
