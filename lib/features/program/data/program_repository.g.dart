// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(programRepository)
final programRepositoryProvider = ProgramRepositoryProvider._();

final class ProgramRepositoryProvider
    extends
        $FunctionalProvider<
          ProgramRepository,
          ProgramRepository,
          ProgramRepository
        >
    with $Provider<ProgramRepository> {
  ProgramRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProgramRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProgramRepository create(Ref ref) {
    return programRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgramRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgramRepository>(value),
    );
  }
}

String _$programRepositoryHash() => r'6d07b9f19a8e15cd1e7713f645044816f9a67726';
