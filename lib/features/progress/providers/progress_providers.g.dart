// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Período de "Tu progreso" (lo comparten la lista y los detalles).

@ProviderFor(SelectedProgressPeriod)
final selectedProgressPeriodProvider = SelectedProgressPeriodProvider._();

/// Período de "Tu progreso" (lo comparten la lista y los detalles).
final class SelectedProgressPeriodProvider
    extends $NotifierProvider<SelectedProgressPeriod, ProgressPeriod> {
  /// Período de "Tu progreso" (lo comparten la lista y los detalles).
  SelectedProgressPeriodProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedProgressPeriodProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedProgressPeriodHash();

  @$internal
  @override
  SelectedProgressPeriod create() => SelectedProgressPeriod();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgressPeriod value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgressPeriod>(value),
    );
  }
}

String _$selectedProgressPeriodHash() =>
    r'38c523e6787433ba876a45b5e0191542430591a9';

/// Período de "Tu progreso" (lo comparten la lista y los detalles).

abstract class _$SelectedProgressPeriod extends $Notifier<ProgressPeriod> {
  ProgressPeriod build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProgressPeriod, ProgressPeriod>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProgressPeriod, ProgressPeriod>,
              ProgressPeriod,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Reporte del período, con caché (se ve sin señal con la última copia).

@ProviderFor(progressReport)
final progressReportProvider = ProgressReportFamily._();

/// Reporte del período, con caché (se ve sin señal con la última copia).

final class ProgressReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgressReport>,
          ProgressReport,
          FutureOr<ProgressReport>
        >
    with $FutureModifier<ProgressReport>, $FutureProvider<ProgressReport> {
  /// Reporte del período, con caché (se ve sin señal con la última copia).
  ProgressReportProvider._({
    required ProgressReportFamily super.from,
    required ProgressPeriod super.argument,
  }) : super(
         retry: null,
         name: r'progressReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$progressReportHash();

  @override
  String toString() {
    return r'progressReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ProgressReport> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgressReport> create(Ref ref) {
    final argument = this.argument as ProgressPeriod;
    return progressReport(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgressReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$progressReportHash() => r'0d1b036da6f9f45b9a1b62486cf3062be67c1cf2';

/// Reporte del período, con caché (se ve sin señal con la última copia).

final class ProgressReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ProgressReport>, ProgressPeriod> {
  ProgressReportFamily._()
    : super(
        retry: null,
        name: r'progressReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Reporte del período, con caché (se ve sin señal con la última copia).

  ProgressReportProvider call(ProgressPeriod period) =>
      ProgressReportProvider._(argument: period, from: this);

  @override
  String toString() => r'progressReportProvider';
}

/// Ejercicios que el atleta ocultó con el ojito (por usuario, en el teléfono).

@ProviderFor(HiddenExercises)
final hiddenExercisesProvider = HiddenExercisesProvider._();

/// Ejercicios que el atleta ocultó con el ojito (por usuario, en el teléfono).
final class HiddenExercisesProvider
    extends $AsyncNotifierProvider<HiddenExercises, Set<String>> {
  /// Ejercicios que el atleta ocultó con el ojito (por usuario, en el teléfono).
  HiddenExercisesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hiddenExercisesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hiddenExercisesHash();

  @$internal
  @override
  HiddenExercises create() => HiddenExercises();
}

String _$hiddenExercisesHash() => r'0137497d60f462e5f1d72e9e2913be9fff205460';

/// Ejercicios que el atleta ocultó con el ojito (por usuario, en el teléfono).

abstract class _$HiddenExercises extends $AsyncNotifier<Set<String>> {
  FutureOr<Set<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
