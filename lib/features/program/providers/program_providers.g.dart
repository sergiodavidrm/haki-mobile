// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Programas del atleta clasificados en EN CURSO / PRÓXIMO / ANTERIORES.

@ProviderFor(programSections)
final programSectionsProvider = ProgramSectionsProvider._();

/// Programas del atleta clasificados en EN CURSO / PRÓXIMO / ANTERIORES.

final class ProgramSectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgramSections>,
          ProgramSections,
          FutureOr<ProgramSections>
        >
    with $FutureModifier<ProgramSections>, $FutureProvider<ProgramSections> {
  /// Programas del atleta clasificados en EN CURSO / PRÓXIMO / ANTERIORES.
  ProgramSectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programSectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programSectionsHash();

  @$internal
  @override
  $FutureProviderElement<ProgramSections> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramSections> create(Ref ref) {
    return programSections(ref);
  }
}

String _$programSectionsHash() => r'475adcd559bdb893d775874d48be5d974a1fc11d';

/// Detalle (semanas, días, ejercicios) de un programa, tal como lo da la API.

@ProviderFor(programDetail)
final programDetailProvider = ProgramDetailFamily._();

/// Detalle (semanas, días, ejercicios) de un programa, tal como lo da la API.

final class ProgramDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<AssignmentDetailDto>,
          AssignmentDetailDto,
          FutureOr<AssignmentDetailDto>
        >
    with
        $FutureModifier<AssignmentDetailDto>,
        $FutureProvider<AssignmentDetailDto> {
  /// Detalle (semanas, días, ejercicios) de un programa, tal como lo da la API.
  ProgramDetailProvider._({
    required ProgramDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'programDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programDetailHash();

  @override
  String toString() {
    return r'programDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AssignmentDetailDto> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AssignmentDetailDto> create(Ref ref) {
    final argument = this.argument as String;
    return programDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programDetailHash() => r'7c58413d3eb3a7d048ab25f91c0d3a91a0f1df26';

/// Detalle (semanas, días, ejercicios) de un programa, tal como lo da la API.

final class ProgramDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AssignmentDetailDto>, String> {
  ProgramDetailFamily._()
    : super(
        retry: null,
        name: r'programDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Detalle (semanas, días, ejercicios) de un programa, tal como lo da la API.

  ProgramDetailProvider call(String assignmentId) =>
      ProgramDetailProvider._(argument: assignmentId, from: this);

  @override
  String toString() => r'programDetailProvider';
}

/// Detalle del programa en curso; null si no hay.

@ProviderFor(currentProgramDetail)
final currentProgramDetailProvider = CurrentProgramDetailProvider._();

/// Detalle del programa en curso; null si no hay.

final class CurrentProgramDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<AssignmentDetailDto?>,
          AssignmentDetailDto?,
          FutureOr<AssignmentDetailDto?>
        >
    with
        $FutureModifier<AssignmentDetailDto?>,
        $FutureProvider<AssignmentDetailDto?> {
  /// Detalle del programa en curso; null si no hay.
  CurrentProgramDetailProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentProgramDetailProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentProgramDetailHash();

  @$internal
  @override
  $FutureProviderElement<AssignmentDetailDto?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AssignmentDetailDto?> create(Ref ref) {
    return currentProgramDetail(ref);
  }
}

String _$currentProgramDetailHash() =>
    r'50058fb9f9e6d080561e36f268f2fa8d2fdecc02';

/// Detalle con el estado de los días pisado por lo registrado en el teléfono
/// (puede no haber llegado a la API todavía). Lo usan Hoy y Programa.

@ProviderFor(programWithLocal)
final programWithLocalProvider = ProgramWithLocalFamily._();

/// Detalle con el estado de los días pisado por lo registrado en el teléfono
/// (puede no haber llegado a la API todavía). Lo usan Hoy y Programa.

final class ProgramWithLocalProvider
    extends
        $FunctionalProvider<
          AsyncValue<AssignmentDetailDto>,
          AssignmentDetailDto,
          FutureOr<AssignmentDetailDto>
        >
    with
        $FutureModifier<AssignmentDetailDto>,
        $FutureProvider<AssignmentDetailDto> {
  /// Detalle con el estado de los días pisado por lo registrado en el teléfono
  /// (puede no haber llegado a la API todavía). Lo usan Hoy y Programa.
  ProgramWithLocalProvider._({
    required ProgramWithLocalFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'programWithLocalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programWithLocalHash();

  @override
  String toString() {
    return r'programWithLocalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AssignmentDetailDto> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AssignmentDetailDto> create(Ref ref) {
    final argument = this.argument as String;
    return programWithLocal(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramWithLocalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programWithLocalHash() => r'7cd761ba705150f248e68635ca1a104c6584cc75';

/// Detalle con el estado de los días pisado por lo registrado en el teléfono
/// (puede no haber llegado a la API todavía). Lo usan Hoy y Programa.

final class ProgramWithLocalFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AssignmentDetailDto>, String> {
  ProgramWithLocalFamily._()
    : super(
        retry: null,
        name: r'programWithLocalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Detalle con el estado de los días pisado por lo registrado en el teléfono
  /// (puede no haber llegado a la API todavía). Lo usan Hoy y Programa.

  ProgramWithLocalProvider call(String assignmentId) =>
      ProgramWithLocalProvider._(argument: assignmentId, from: this);

  @override
  String toString() => r'programWithLocalProvider';
}

@ProviderFor(_localSessionsStream)
final _localSessionsStreamProvider = _LocalSessionsStreamFamily._();

final class _LocalSessionsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LocalSessionInfo>>,
          List<LocalSessionInfo>,
          Stream<List<LocalSessionInfo>>
        >
    with
        $FutureModifier<List<LocalSessionInfo>>,
        $StreamProvider<List<LocalSessionInfo>> {
  _LocalSessionsStreamProvider._({
    required _LocalSessionsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'_localSessionsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$_localSessionsStreamHash();

  @override
  String toString() {
    return r'_localSessionsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<LocalSessionInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LocalSessionInfo>> create(Ref ref) {
    final argument = this.argument as String;
    return _localSessionsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is _LocalSessionsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_localSessionsStreamHash() =>
    r'5177764ebf48b6ee90a155709c81fbdd2cab0d8b';

final class _LocalSessionsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<LocalSessionInfo>>, String> {
  _LocalSessionsStreamFamily._()
    : super(
        retry: null,
        name: r'_localSessionsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  _LocalSessionsStreamProvider call(String assignmentId) =>
      _LocalSessionsStreamProvider._(argument: assignmentId, from: this);

  @override
  String toString() => r'_localSessionsStreamProvider';
}

/// Guardar fechas desde "Asignar fechas". El estado es el guardado en curso
/// (loading / error con el mensaje de la API).

@ProviderFor(ScheduleSaver)
final scheduleSaverProvider = ScheduleSaverProvider._();

/// Guardar fechas desde "Asignar fechas". El estado es el guardado en curso
/// (loading / error con el mensaje de la API).
final class ScheduleSaverProvider
    extends $AsyncNotifierProvider<ScheduleSaver, void> {
  /// Guardar fechas desde "Asignar fechas". El estado es el guardado en curso
  /// (loading / error con el mensaje de la API).
  ScheduleSaverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleSaverProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleSaverHash();

  @$internal
  @override
  ScheduleSaver create() => ScheduleSaver();
}

String _$scheduleSaverHash() => r'2c8c529c9ea2de9385afcfc2b7ecfed7a6d7097c';

/// Guardar fechas desde "Asignar fechas". El estado es el guardado en curso
/// (loading / error con el mensaje de la API).

abstract class _$ScheduleSaver extends $AsyncNotifier<void> {
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
