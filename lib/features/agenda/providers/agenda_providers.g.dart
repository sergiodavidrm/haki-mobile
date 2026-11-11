// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agenda_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sesiones con el coach (presenciales y virtuales) alrededor de hoy. Se
/// recarga al volver a primer plano mientras Hoy la escucha.

@ProviderFor(myAgenda)
final myAgendaProvider = MyAgendaProvider._();

/// Sesiones con el coach (presenciales y virtuales) alrededor de hoy. Se
/// recarga al volver a primer plano mientras Hoy la escucha.

final class MyAgendaProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MyAgendaEvent>>,
          List<MyAgendaEvent>,
          FutureOr<List<MyAgendaEvent>>
        >
    with
        $FutureModifier<List<MyAgendaEvent>>,
        $FutureProvider<List<MyAgendaEvent>> {
  /// Sesiones con el coach (presenciales y virtuales) alrededor de hoy. Se
  /// recarga al volver a primer plano mientras Hoy la escucha.
  MyAgendaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myAgendaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myAgendaHash();

  @$internal
  @override
  $FutureProviderElement<List<MyAgendaEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MyAgendaEvent>> create(Ref ref) {
    return myAgenda(ref);
  }
}

String _$myAgendaHash() => r'd37601e739d66f6ad44fb33222b96e855776b6a5';

/// "Voy", "No puedo ir" y deshacerlos. El estado es el envío en curso.

@ProviderFor(AgendaDecliner)
final agendaDeclinerProvider = AgendaDeclinerProvider._();

/// "Voy", "No puedo ir" y deshacerlos. El estado es el envío en curso.
final class AgendaDeclinerProvider
    extends $AsyncNotifierProvider<AgendaDecliner, void> {
  /// "Voy", "No puedo ir" y deshacerlos. El estado es el envío en curso.
  AgendaDeclinerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agendaDeclinerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agendaDeclinerHash();

  @$internal
  @override
  AgendaDecliner create() => AgendaDecliner();
}

String _$agendaDeclinerHash() => r'd6cb7c248d55d2bdfc23ca6f1cba75e47afb4940';

/// "Voy", "No puedo ir" y deshacerlos. El estado es el envío en curso.

abstract class _$AgendaDecliner extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
