// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'records.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recordsRepository)
final recordsRepositoryProvider = RecordsRepositoryProvider._();

final class RecordsRepositoryProvider
    extends
        $FunctionalProvider<
          RecordsRepository,
          RecordsRepository,
          RecordsRepository
        >
    with $Provider<RecordsRepository> {
  RecordsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordsRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecordsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecordsRepository create(Ref ref) {
    return recordsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecordsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecordsRepository>(value),
    );
  }
}

String _$recordsRepositoryHash() => r'03abc76238a28e220cf7342ac89fe37fbd2ff539';
