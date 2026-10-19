// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Historial de un ejercicio del catálogo. Necesita red; sin conexión el
/// Detalle muestra solo lo del programa (hoy + "última vez").

@ProviderFor(exerciseHistory)
final exerciseHistoryProvider = ExerciseHistoryFamily._();

/// Historial de un ejercicio del catálogo. Necesita red; sin conexión el
/// Detalle muestra solo lo del programa (hoy + "última vez").

final class ExerciseHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExerciseHistoryEntryDto>>,
          List<ExerciseHistoryEntryDto>,
          FutureOr<List<ExerciseHistoryEntryDto>>
        >
    with
        $FutureModifier<List<ExerciseHistoryEntryDto>>,
        $FutureProvider<List<ExerciseHistoryEntryDto>> {
  /// Historial de un ejercicio del catálogo. Necesita red; sin conexión el
  /// Detalle muestra solo lo del programa (hoy + "última vez").
  ExerciseHistoryProvider._({
    required ExerciseHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'exerciseHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseHistoryHash();

  @override
  String toString() {
    return r'exerciseHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ExerciseHistoryEntryDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExerciseHistoryEntryDto>> create(Ref ref) {
    final argument = this.argument as String;
    return exerciseHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseHistoryHash() => r'f6a29efdceafca0de16f781ac9ff4e75733bf061';

/// Historial de un ejercicio del catálogo. Necesita red; sin conexión el
/// Detalle muestra solo lo del programa (hoy + "última vez").

final class ExerciseHistoryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ExerciseHistoryEntryDto>>,
          String
        > {
  ExerciseHistoryFamily._()
    : super(
        retry: null,
        name: r'exerciseHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Historial de un ejercicio del catálogo. Necesita red; sin conexión el
  /// Detalle muestra solo lo del programa (hoy + "última vez").

  ExerciseHistoryProvider call(String exerciseId) =>
      ExerciseHistoryProvider._(argument: exerciseId, from: this);

  @override
  String toString() => r'exerciseHistoryProvider';
}
