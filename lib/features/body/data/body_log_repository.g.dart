// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_log_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bodyLogRepository)
final bodyLogRepositoryProvider = BodyLogRepositoryProvider._();

final class BodyLogRepositoryProvider
    extends
        $FunctionalProvider<
          BodyLogRepository,
          BodyLogRepository,
          BodyLogRepository
        >
    with $Provider<BodyLogRepository> {
  BodyLogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bodyLogRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bodyLogRepositoryHash();

  @$internal
  @override
  $ProviderElement<BodyLogRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BodyLogRepository create(Ref ref) {
    return bodyLogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BodyLogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BodyLogRepository>(value),
    );
  }
}

String _$bodyLogRepositoryHash() => r'e12132f1025708fb917bfe4a07a795e893f46844';
