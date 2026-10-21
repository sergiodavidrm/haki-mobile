// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_dto.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(streakRepository)
final streakRepositoryProvider = StreakRepositoryProvider._();

final class StreakRepositoryProvider
    extends
        $FunctionalProvider<
          StreakRepository,
          StreakRepository,
          StreakRepository
        >
    with $Provider<StreakRepository> {
  StreakRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakRepositoryHash();

  @$internal
  @override
  $ProviderElement<StreakRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StreakRepository create(Ref ref) {
    return streakRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StreakRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StreakRepository>(value),
    );
  }
}

String _$streakRepositoryHash() => r'a1dc238b5ead3a26b75ff7ebbff6ec50ac9cce8f';
