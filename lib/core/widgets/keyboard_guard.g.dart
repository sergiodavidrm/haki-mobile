// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyboard_guard.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bug (2026-11-02): si la app se iba a segundo plano con el teclado abierto
/// (p. ej. cargando una serie), al volver Flutter seguía con el espacio del
/// teclado (`viewInsets.bottom`) aunque ya no estuviera: cada pantalla achicaba
/// su contenido y quedaba un bloque negro abajo, en todos los tabs.
///
/// Al irse: se saca el foco (el teclado se cierra y la fila de la serie que se
/// estaba cargando se guarda sola, como al salir de ella). Al volver, si nada
/// tiene foco, se le pide al sistema que oculte el teclado para que vuelva a
/// informar el espacio en 0. Se arranca en app.dart.

@ProviderFor(keyboardGuard)
final keyboardGuardProvider = KeyboardGuardProvider._();

/// Bug (2026-11-02): si la app se iba a segundo plano con el teclado abierto
/// (p. ej. cargando una serie), al volver Flutter seguía con el espacio del
/// teclado (`viewInsets.bottom`) aunque ya no estuviera: cada pantalla achicaba
/// su contenido y quedaba un bloque negro abajo, en todos los tabs.
///
/// Al irse: se saca el foco (el teclado se cierra y la fila de la serie que se
/// estaba cargando se guarda sola, como al salir de ella). Al volver, si nada
/// tiene foco, se le pide al sistema que oculte el teclado para que vuelva a
/// informar el espacio en 0. Se arranca en app.dart.

final class KeyboardGuardProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Bug (2026-11-02): si la app se iba a segundo plano con el teclado abierto
  /// (p. ej. cargando una serie), al volver Flutter seguía con el espacio del
  /// teclado (`viewInsets.bottom`) aunque ya no estuviera: cada pantalla achicaba
  /// su contenido y quedaba un bloque negro abajo, en todos los tabs.
  ///
  /// Al irse: se saca el foco (el teclado se cierra y la fila de la serie que se
  /// estaba cargando se guarda sola, como al salir de ella). Al volver, si nada
  /// tiene foco, se le pide al sistema que oculte el teclado para que vuelva a
  /// informar el espacio en 0. Se arranca en app.dart.
  KeyboardGuardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keyboardGuardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keyboardGuardHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return keyboardGuard(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$keyboardGuardHash() => r'b1359572baf92a157541bea614313058f91a4f03';
