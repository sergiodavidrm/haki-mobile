// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_me_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authMe)
final authMeProvider = AuthMeProvider._();

final class AuthMeProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthMeDto>,
          AuthMeDto,
          FutureOr<AuthMeDto>
        >
    with $FutureModifier<AuthMeDto>, $FutureProvider<AuthMeDto> {
  AuthMeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authMeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authMeHash();

  @$internal
  @override
  $FutureProviderElement<AuthMeDto> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AuthMeDto> create(Ref ref) {
    return authMe(ref);
  }
}

String _$authMeHash() => r'3ccea763a0ad021da7f111ff936ac97f32aa484d';
