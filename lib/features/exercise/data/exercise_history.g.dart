// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_history.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exerciseHistoryRepository)
final exerciseHistoryRepositoryProvider = ExerciseHistoryRepositoryProvider._();

final class ExerciseHistoryRepositoryProvider
    extends
        $FunctionalProvider<
          ExerciseHistoryRepository,
          ExerciseHistoryRepository,
          ExerciseHistoryRepository
        >
    with $Provider<ExerciseHistoryRepository> {
  ExerciseHistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseHistoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseHistoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExerciseHistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExerciseHistoryRepository create(Ref ref) {
    return exerciseHistoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExerciseHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExerciseHistoryRepository>(value),
    );
  }
}

String _$exerciseHistoryRepositoryHash() =>
    r'4946340642f055c9287920e0b6b8c25c3f32e543';
