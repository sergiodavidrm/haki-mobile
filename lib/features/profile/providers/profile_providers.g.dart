// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currentAdherence)
final currentAdherenceProvider = CurrentAdherenceProvider._();

final class CurrentAdherenceProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgramAdherence?>,
          ProgramAdherence?,
          FutureOr<ProgramAdherence?>
        >
    with
        $FutureModifier<ProgramAdherence?>,
        $FutureProvider<ProgramAdherence?> {
  CurrentAdherenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAdherenceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAdherenceHash();

  @$internal
  @override
  $FutureProviderElement<ProgramAdherence?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgramAdherence?> create(Ref ref) {
    return currentAdherence(ref);
  }
}

String _$currentAdherenceHash() => r'd8715d1a7e26ab3108a7303147932240ab933089';

/// Pantalla Adherencia: el programa en curso + el anterior (para comparar).
/// null si no hay programa en curso.

@ProviderFor(adherenceDetail)
final adherenceDetailProvider = AdherenceDetailProvider._();

/// Pantalla Adherencia: el programa en curso + el anterior (para comparar).
/// null si no hay programa en curso.

final class AdherenceDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<
            ({AssignmentSummaryDto? previous, AdherenceReport report})?
          >,
          ({AssignmentSummaryDto? previous, AdherenceReport report})?,
          FutureOr<({AssignmentSummaryDto? previous, AdherenceReport report})?>
        >
    with
        $FutureModifier<
          ({AssignmentSummaryDto? previous, AdherenceReport report})?
        >,
        $FutureProvider<
          ({AssignmentSummaryDto? previous, AdherenceReport report})?
        > {
  /// Pantalla Adherencia: el programa en curso + el anterior (para comparar).
  /// null si no hay programa en curso.
  AdherenceDetailProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adherenceDetailProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adherenceDetailHash();

  @$internal
  @override
  $FutureProviderElement<
    ({AssignmentSummaryDto? previous, AdherenceReport report})?
  >
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({AssignmentSummaryDto? previous, AdherenceReport report})?> create(
    Ref ref,
  ) {
    return adherenceDetail(ref);
  }
}

String _$adherenceDetailHash() => r'e6df76ba121efe2ef85598627ebe1d2a544cb77e';

/// Racha de semanas (tarjeta del Perfil). Necesita red; sin ella la tarjeta
/// no se muestra.

@ProviderFor(streak)
final streakProvider = StreakProvider._();

/// Racha de semanas (tarjeta del Perfil). Necesita red; sin ella la tarjeta
/// no se muestra.

final class StreakProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreakDto>,
          StreakDto,
          FutureOr<StreakDto>
        >
    with $FutureModifier<StreakDto>, $FutureProvider<StreakDto> {
  /// Racha de semanas (tarjeta del Perfil). Necesita red; sin ella la tarjeta
  /// no se muestra.
  StreakProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakHash();

  @$internal
  @override
  $FutureProviderElement<StreakDto> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<StreakDto> create(Ref ref) {
    return streak(ref);
  }
}

String _$streakHash() => r'caaf59237adc87257065f6fbdfb43235c408c9c9';

/// Récords personales (tarjeta del Perfil y pantalla Récords). Necesita red.

@ProviderFor(records)
final recordsProvider = RecordsProvider._();

/// Récords personales (tarjeta del Perfil y pantalla Récords). Necesita red.

final class RecordsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PersonalRecordDto>>,
          List<PersonalRecordDto>,
          FutureOr<List<PersonalRecordDto>>
        >
    with
        $FutureModifier<List<PersonalRecordDto>>,
        $FutureProvider<List<PersonalRecordDto>> {
  /// Récords personales (tarjeta del Perfil y pantalla Récords). Necesita red.
  RecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordsHash();

  @$internal
  @override
  $FutureProviderElement<List<PersonalRecordDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PersonalRecordDto>> create(Ref ref) {
    return records(ref);
  }
}

String _$recordsHash() => r'1f13dee7c6f018e6625185a1496f403c491d1360';

/// Programa en curso (para "Este bloque"); null si no hay.

@ProviderFor(currentAssignmentId)
final currentAssignmentIdProvider = CurrentAssignmentIdProvider._();

/// Programa en curso (para "Este bloque"); null si no hay.

final class CurrentAssignmentIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Programa en curso (para "Este bloque"); null si no hay.
  CurrentAssignmentIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAssignmentIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAssignmentIdHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return currentAssignmentId(ref);
  }
}

String _$currentAssignmentIdHash() =>
    r'2124e61a11ae703dd63751fbd74008f5c35a4a02';

/// Programas en curso (en paralelo puede haber varios): "Este bloque" de Récords.
/// null si no hay ninguno.

@ProviderFor(currentAssignmentIds)
final currentAssignmentIdsProvider = CurrentAssignmentIdsProvider._();

/// Programas en curso (en paralelo puede haber varios): "Este bloque" de Récords.
/// null si no hay ninguno.

final class CurrentAssignmentIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>?>,
          Set<String>?,
          FutureOr<Set<String>?>
        >
    with $FutureModifier<Set<String>?>, $FutureProvider<Set<String>?> {
  /// Programas en curso (en paralelo puede haber varios): "Este bloque" de Récords.
  /// null si no hay ninguno.
  CurrentAssignmentIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAssignmentIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAssignmentIdsHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>?> create(Ref ref) {
    return currentAssignmentIds(ref);
  }
}

String _$currentAssignmentIdsHash() =>
    r'8370bda3fcc20d469549f937f68d47bef07588b3';
