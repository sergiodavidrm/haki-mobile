// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_data_guard.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// La BD local es de un solo usuario. Se guarda de quién es; al cerrar sesión
/// o si entra otro usuario se borra todo (y el estado en memoria de la sesión).
/// Sin dueño guardado (instalaciones previas a esto) se asume del usuario
/// actual. Antes de cerrar sesión, Perfil avisa si queda algo sin subir.

@ProviderFor(localDataGuard)
final localDataGuardProvider = LocalDataGuardProvider._();

/// La BD local es de un solo usuario. Se guarda de quién es; al cerrar sesión
/// o si entra otro usuario se borra todo (y el estado en memoria de la sesión).
/// Sin dueño guardado (instalaciones previas a esto) se asume del usuario
/// actual. Antes de cerrar sesión, Perfil avisa si queda algo sin subir.

final class LocalDataGuardProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// La BD local es de un solo usuario. Se guarda de quién es; al cerrar sesión
  /// o si entra otro usuario se borra todo (y el estado en memoria de la sesión).
  /// Sin dueño guardado (instalaciones previas a esto) se asume del usuario
  /// actual. Antes de cerrar sesión, Perfil avisa si queda algo sin subir.
  LocalDataGuardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localDataGuardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localDataGuardHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return localDataGuard(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$localDataGuardHash() => r'1b84026586aa039e9b34c83020a6becc9bf6a8a0';
