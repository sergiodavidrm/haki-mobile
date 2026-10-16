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

String _$programSectionsHash() => r'5e4c7b1dd75e73e7784354b31fd298777f46f5a6';

/// Detalle (semanas, días, ejercicios) del programa en curso; null si no hay.

@ProviderFor(currentProgramDetail)
final currentProgramDetailProvider = CurrentProgramDetailProvider._();

/// Detalle (semanas, días, ejercicios) del programa en curso; null si no hay.

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
  /// Detalle (semanas, días, ejercicios) del programa en curso; null si no hay.
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
    r'e3e8e99a7dc91b463e99020030b3e3a6b0a94134';
