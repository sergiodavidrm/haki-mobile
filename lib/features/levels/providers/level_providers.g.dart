// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Nivel, XP y logros del atleta (Perfil y Nivel y logros). Necesita red: sin
/// ella la tarjeta no se muestra. La API recalcula el XP en cada llamada.

@ProviderFor(level)
final levelProvider = LevelProvider._();

/// Nivel, XP y logros del atleta (Perfil y Nivel y logros). Necesita red: sin
/// ella la tarjeta no se muestra. La API recalcula el XP en cada llamada.

final class LevelProvider
    extends
        $FunctionalProvider<AsyncValue<LevelDto>, LevelDto, FutureOr<LevelDto>>
    with $FutureModifier<LevelDto>, $FutureProvider<LevelDto> {
  /// Nivel, XP y logros del atleta (Perfil y Nivel y logros). Necesita red: sin
  /// ella la tarjeta no se muestra. La API recalcula el XP en cada llamada.
  LevelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'levelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$levelHash();

  @$internal
  @override
  $FutureProviderElement<LevelDto> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<LevelDto> create(Ref ref) {
    return level(ref);
  }
}

String _$levelHash() => r'5f9f41c2634ee09840c5de2a296661fc91e794cb';

/// "+190 XP" de Entreno completado. El entreno sube en cola: mientras la API
/// no lo tenga completo (`pending`) vuelve a preguntar unas veces.

@ProviderFor(dayXp)
final dayXpProvider = DayXpFamily._();

/// "+190 XP" de Entreno completado. El entreno sube en cola: mientras la API
/// no lo tenga completo (`pending`) vuelve a preguntar unas veces.

final class DayXpProvider
    extends
        $FunctionalProvider<
          AsyncValue<SessionXpDto>,
          SessionXpDto,
          FutureOr<SessionXpDto>
        >
    with $FutureModifier<SessionXpDto>, $FutureProvider<SessionXpDto> {
  /// "+190 XP" de Entreno completado. El entreno sube en cola: mientras la API
  /// no lo tenga completo (`pending`) vuelve a preguntar unas veces.
  DayXpProvider._({
    required DayXpFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'dayXpProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayXpHash();

  @override
  String toString() {
    return r'dayXpProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<SessionXpDto> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SessionXpDto> create(Ref ref) {
    final argument = this.argument as (String, String);
    return dayXp(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DayXpProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayXpHash() => r'311e4bead953be0060c549fcaf1bf90fd25860e4';

/// "+190 XP" de Entreno completado. El entreno sube en cola: mientras la API
/// no lo tenga completo (`pending`) vuelve a preguntar unas veces.

final class DayXpFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SessionXpDto>, (String, String)> {
  DayXpFamily._()
    : super(
        retry: null,
        name: r'dayXpProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// "+190 XP" de Entreno completado. El entreno sube en cola: mientras la API
  /// no lo tenga completo (`pending`) vuelve a preguntar unas veces.

  DayXpProvider call(String assignmentId, String dayId) =>
      DayXpProvider._(argument: (assignmentId, dayId), from: this);

  @override
  String toString() => r'dayXpProvider';
}

/// Ajustes → "Mostrar niveles y logros" (2026-11-13, Sergio): el atleta puede
/// ocultarlos aunque el coach los tenga prendidos. Preferencia del teléfono,
/// arranca prendida.

@ProviderFor(ShowGamification)
final showGamificationProvider = ShowGamificationProvider._();

/// Ajustes → "Mostrar niveles y logros" (2026-11-13, Sergio): el atleta puede
/// ocultarlos aunque el coach los tenga prendidos. Preferencia del teléfono,
/// arranca prendida.
final class ShowGamificationProvider
    extends $NotifierProvider<ShowGamification, bool> {
  /// Ajustes → "Mostrar niveles y logros" (2026-11-13, Sergio): el atleta puede
  /// ocultarlos aunque el coach los tenga prendidos. Preferencia del teléfono,
  /// arranca prendida.
  ShowGamificationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showGamificationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showGamificationHash();

  @$internal
  @override
  ShowGamification create() => ShowGamification();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showGamificationHash() => r'e4d6126f5a9985683ed5bdd7c8bfd7612aa4bc02';

/// Ajustes → "Mostrar niveles y logros" (2026-11-13, Sergio): el atleta puede
/// ocultarlos aunque el coach los tenga prendidos. Preferencia del teléfono,
/// arranca prendida.

abstract class _$ShowGamification extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Niveles y logros a la vista: el coach los muestra (`levelsEnabled`) y el
/// atleta no los ocultó en Ajustes.

@ProviderFor(gamificationVisible)
final gamificationVisibleProvider = GamificationVisibleProvider._();

/// Niveles y logros a la vista: el coach los muestra (`levelsEnabled`) y el
/// atleta no los ocultó en Ajustes.

final class GamificationVisibleProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Niveles y logros a la vista: el coach los muestra (`levelsEnabled`) y el
  /// atleta no los ocultó en Ajustes.
  GamificationVisibleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gamificationVisibleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gamificationVisibleHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return gamificationVisible(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$gamificationVisibleHash() =>
    r'689cd25f015c0f8360e6905bfd26902bd6b3db31';
