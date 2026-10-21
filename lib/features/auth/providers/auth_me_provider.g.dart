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

/// Nombre a mostrar: el completo de haki-api (un atleta invitado entra con
/// email/password y Supabase no tiene su nombre); mientras carga o sin red,
/// el de Supabase o la parte local del email.

@ProviderFor(displayName)
final displayNameProvider = DisplayNameProvider._();

/// Nombre a mostrar: el completo de haki-api (un atleta invitado entra con
/// email/password y Supabase no tiene su nombre); mientras carga o sin red,
/// el de Supabase o la parte local del email.

final class DisplayNameProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Nombre a mostrar: el completo de haki-api (un atleta invitado entra con
  /// email/password y Supabase no tiene su nombre); mientras carga o sin red,
  /// el de Supabase o la parte local del email.
  DisplayNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displayNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displayNameHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return displayName(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$displayNameHash() => r'77e538966968424755d587ae791fe87fc5c93279';
