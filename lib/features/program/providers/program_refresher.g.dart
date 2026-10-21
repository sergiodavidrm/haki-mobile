// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_refresher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Al volver la app a primer plano vuelve a pedir los programas y el detalle
/// (cambios del coach), salvo durante un entreno. Se arranca en app.dart.

@ProviderFor(programRefresher)
final programRefresherProvider = ProgramRefresherProvider._();

/// Al volver la app a primer plano vuelve a pedir los programas y el detalle
/// (cambios del coach), salvo durante un entreno. Se arranca en app.dart.

final class ProgramRefresherProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Al volver la app a primer plano vuelve a pedir los programas y el detalle
  /// (cambios del coach), salvo durante un entreno. Se arranca en app.dart.
  ProgramRefresherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programRefresherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programRefresherHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return programRefresher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$programRefresherHash() => r'5e19810fcf7c3db8f7f0c888a4ca7f5d0a186de5';
