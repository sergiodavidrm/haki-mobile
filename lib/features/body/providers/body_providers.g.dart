// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bodyLogs)
final bodyLogsProvider = BodyLogsProvider._();

final class BodyLogsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BodyLogDto>>,
          List<BodyLogDto>,
          FutureOr<List<BodyLogDto>>
        >
    with $FutureModifier<List<BodyLogDto>>, $FutureProvider<List<BodyLogDto>> {
  BodyLogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bodyLogsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bodyLogsHash();

  @$internal
  @override
  $FutureProviderElement<List<BodyLogDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BodyLogDto>> create(Ref ref) {
    return bodyLogs(ref);
  }
}

String _$bodyLogsHash() => r'fcb9f201e838808f1570020d605068a64dd51722';

/// Unidad en que el atleta ve y carga su peso corporal.

@ProviderFor(bodyWeightUnit)
final bodyWeightUnitProvider = BodyWeightUnitProvider._();

/// Unidad en que el atleta ve y carga su peso corporal.

final class BodyWeightUnitProvider
    extends $FunctionalProvider<WeightUnit, WeightUnit, WeightUnit>
    with $Provider<WeightUnit> {
  /// Unidad en que el atleta ve y carga su peso corporal.
  BodyWeightUnitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bodyWeightUnitProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bodyWeightUnitHash();

  @$internal
  @override
  $ProviderElement<WeightUnit> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WeightUnit create(Ref ref) {
    return bodyWeightUnit(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeightUnit value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeightUnit>(value),
    );
  }
}

String _$bodyWeightUnitHash() => r'68694fc1fa02a99e5fd7dcbe015a871d5c3df81e';

/// Guardar peso o medidas. El estado es el guardado en curso (loading /
/// error con el mensaje de la API).

@ProviderFor(BodyLogSaver)
final bodyLogSaverProvider = BodyLogSaverProvider._();

/// Guardar peso o medidas. El estado es el guardado en curso (loading /
/// error con el mensaje de la API).
final class BodyLogSaverProvider
    extends $AsyncNotifierProvider<BodyLogSaver, void> {
  /// Guardar peso o medidas. El estado es el guardado en curso (loading /
  /// error con el mensaje de la API).
  BodyLogSaverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bodyLogSaverProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bodyLogSaverHash();

  @$internal
  @override
  BodyLogSaver create() => BodyLogSaver();
}

String _$bodyLogSaverHash() => r'd6f0746d6427730d098930566a0390287c591948';

/// Guardar peso o medidas. El estado es el guardado en curso (loading /
/// error con el mensaje de la API).

abstract class _$BodyLogSaver extends $AsyncNotifier<void> {
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
