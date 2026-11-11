// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agenda_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(agendaRepository)
final agendaRepositoryProvider = AgendaRepositoryProvider._();

final class AgendaRepositoryProvider
    extends
        $FunctionalProvider<
          AgendaRepository,
          AgendaRepository,
          AgendaRepository
        >
    with $Provider<AgendaRepository> {
  AgendaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agendaRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agendaRepositoryHash();

  @$internal
  @override
  $ProviderElement<AgendaRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AgendaRepository create(Ref ref) {
    return agendaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AgendaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AgendaRepository>(value),
    );
  }
}

String _$agendaRepositoryHash() => r'1f29353162af6d47fbe5613b9d50be4b169100e8';
