// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_dto.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(levelRepository)
final levelRepositoryProvider = LevelRepositoryProvider._();

final class LevelRepositoryProvider
    extends
        $FunctionalProvider<LevelRepository, LevelRepository, LevelRepository>
    with $Provider<LevelRepository> {
  LevelRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'levelRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$levelRepositoryHash();

  @$internal
  @override
  $ProviderElement<LevelRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LevelRepository create(Ref ref) {
    return levelRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LevelRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LevelRepository>(value),
    );
  }
}

String _$levelRepositoryHash() => r'd4965d61db0dfa2addc59ea3a8da2d60ade3a847';
