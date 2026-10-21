// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currentAdherence)
final currentAdherenceProvider = CurrentAdherenceProvider._();

final class CurrentAdherenceProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgramAdherence?>,
          ProgramAdherence?,
          FutureOr<ProgramAdherence?>
        >
    with
        $FutureModifier<ProgramAdherence?>,
        $FutureProvider<ProgramAdherence?> {
  CurrentAdherenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAdherenceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAdherenceHash();

  @$internal
  @override
  $FutureProviderElement<ProgramAdherence?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramAdherence?> create(Ref ref) {
    return currentAdherence(ref);
  }
}

String _$currentAdherenceHash() => r'3977fe80a627503b5799da773e1262e2d6406b05';

/// Racha de semanas (tarjeta del Perfil). Necesita red; sin ella la tarjeta
/// no se muestra.

@ProviderFor(streak)
final streakProvider = StreakProvider._();

/// Racha de semanas (tarjeta del Perfil). Necesita red; sin ella la tarjeta
/// no se muestra.

final class StreakProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreakDto>,
          StreakDto,
          FutureOr<StreakDto>
        >
    with $FutureModifier<StreakDto>, $FutureProvider<StreakDto> {
  /// Racha de semanas (tarjeta del Perfil). Necesita red; sin ella la tarjeta
  /// no se muestra.
  StreakProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakHash();

  @$internal
  @override
  $FutureProviderElement<StreakDto> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<StreakDto> create(Ref ref) {
    return streak(ref);
  }
}

String _$streakHash() => r'caaf59237adc87257065f6fbdfb43235c408c9c9';
