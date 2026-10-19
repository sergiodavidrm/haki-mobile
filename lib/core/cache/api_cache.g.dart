// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_cache.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(apiCache)
final apiCacheProvider = ApiCacheProvider._();

final class ApiCacheProvider
    extends $FunctionalProvider<ApiCache, ApiCache, ApiCache>
    with $Provider<ApiCache> {
  ApiCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiCacheHash();

  @$internal
  @override
  $ProviderElement<ApiCache> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiCache create(Ref ref) {
    return apiCache(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiCache value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiCache>(value),
    );
  }
}

String _$apiCacheHash() => r'47f8034db3a0a21929f39c5c13a62df7cfdaa044';
