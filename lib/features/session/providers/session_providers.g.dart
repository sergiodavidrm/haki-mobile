// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionDay)
final sessionDayProvider = SessionDayFamily._();

final class SessionDayProvider
    extends
        $FunctionalProvider<
          AsyncValue<SessionDay>,
          SessionDay,
          FutureOr<SessionDay>
        >
    with $FutureModifier<SessionDay>, $FutureProvider<SessionDay> {
  SessionDayProvider._({
    required SessionDayFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'sessionDayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionDayHash();

  @override
  String toString() {
    return r'sessionDayProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<SessionDay> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SessionDay> create(Ref ref) {
    final argument = this.argument as (String, String);
    return sessionDay(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionDayHash() => r'd5b0ae9b49f7a39dad9d72d01b18ac7570a537eb';

final class SessionDayFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SessionDay>, (String, String)> {
  SessionDayFamily._()
    : super(
        retry: null,
        name: r'sessionDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SessionDayProvider call(String assignmentId, String dayId) =>
      SessionDayProvider._(argument: (assignmentId, dayId), from: this);

  @override
  String toString() => r'sessionDayProvider';
}

@ProviderFor(localSession)
final localSessionProvider = LocalSessionFamily._();

final class LocalSessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<LocalSessionInfo?>,
          LocalSessionInfo?,
          Stream<LocalSessionInfo?>
        >
    with
        $FutureModifier<LocalSessionInfo?>,
        $StreamProvider<LocalSessionInfo?> {
  LocalSessionProvider._({
    required LocalSessionFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'localSessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localSessionHash();

  @override
  String toString() {
    return r'localSessionProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<LocalSessionInfo?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<LocalSessionInfo?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return localSession(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalSessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localSessionHash() => r'ad388a5bf383c02579c16774b097a0da1d096cba';

final class LocalSessionFamily extends $Family
    with
        $FunctionalFamilyOverride<Stream<LocalSessionInfo?>, (String, String)> {
  LocalSessionFamily._()
    : super(
        retry: null,
        name: r'localSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LocalSessionProvider call(String assignmentId, String dayId) =>
      LocalSessionProvider._(argument: (assignmentId, dayId), from: this);

  @override
  String toString() => r'localSessionProvider';
}

@ProviderFor(localSessionsOf)
final localSessionsOfProvider = LocalSessionsOfFamily._();

final class LocalSessionsOfProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LocalSessionInfo>>,
          List<LocalSessionInfo>,
          Stream<List<LocalSessionInfo>>
        >
    with
        $FutureModifier<List<LocalSessionInfo>>,
        $StreamProvider<List<LocalSessionInfo>> {
  LocalSessionsOfProvider._({
    required LocalSessionsOfFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'localSessionsOfProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localSessionsOfHash();

  @override
  String toString() {
    return r'localSessionsOfProvider'
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
    return localSessionsOf(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalSessionsOfProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localSessionsOfHash() => r'84916b78b91fff2db64b3228b86d732071fd1bd9';

final class LocalSessionsOfFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<LocalSessionInfo>>, String> {
  LocalSessionsOfFamily._()
    : super(
        retry: null,
        name: r'localSessionsOfProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LocalSessionsOfProvider call(String assignmentId) =>
      LocalSessionsOfProvider._(argument: assignmentId, from: this);

  @override
  String toString() => r'localSessionsOfProvider';
}

/// Series locales del día, indexadas por "dayExerciseId#setNumber".

@ProviderFor(localSets)
final localSetsProvider = LocalSetsFamily._();

/// Series locales del día, indexadas por "dayExerciseId#setNumber".

final class LocalSetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, LocalSetEntry>>,
          Map<String, LocalSetEntry>,
          Stream<Map<String, LocalSetEntry>>
        >
    with
        $FutureModifier<Map<String, LocalSetEntry>>,
        $StreamProvider<Map<String, LocalSetEntry>> {
  /// Series locales del día, indexadas por "dayExerciseId#setNumber".
  LocalSetsProvider._({
    required LocalSetsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'localSetsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localSetsHash();

  @override
  String toString() {
    return r'localSetsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, LocalSetEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, LocalSetEntry>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return localSets(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalSetsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localSetsHash() => r'dc0e9bf984b372ee3ddc23773f7d9a5476bd869e';

/// Series locales del día, indexadas por "dayExerciseId#setNumber".

final class LocalSetsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Map<String, LocalSetEntry>>,
          (String, String)
        > {
  LocalSetsFamily._()
    : super(
        retry: null,
        name: r'localSetsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Series locales del día, indexadas por "dayExerciseId#setNumber".

  LocalSetsProvider call(String assignmentId, String dayId) =>
      LocalSetsProvider._(argument: (assignmentId, dayId), from: this);

  @override
  String toString() => r'localSetsProvider';
}

/// Unidad del día (switch del header). Arranca en la preferida del atleta
/// (`GET /auth/me`, kg si no viene). keepAlive: se mantiene al salir y volver
/// a la sesión, y la usa el resumen de Entreno completado.

@ProviderFor(DayWeightUnit)
final dayWeightUnitProvider = DayWeightUnitFamily._();

/// Unidad del día (switch del header). Arranca en la preferida del atleta
/// (`GET /auth/me`, kg si no viene). keepAlive: se mantiene al salir y volver
/// a la sesión, y la usa el resumen de Entreno completado.
final class DayWeightUnitProvider
    extends $NotifierProvider<DayWeightUnit, WeightUnit> {
  /// Unidad del día (switch del header). Arranca en la preferida del atleta
  /// (`GET /auth/me`, kg si no viene). keepAlive: se mantiene al salir y volver
  /// a la sesión, y la usa el resumen de Entreno completado.
  DayWeightUnitProvider._({
    required DayWeightUnitFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'dayWeightUnitProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayWeightUnitHash();

  @override
  String toString() {
    return r'dayWeightUnitProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DayWeightUnit create() => DayWeightUnit();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeightUnit value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeightUnit>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DayWeightUnitProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayWeightUnitHash() => r'eddf1b5de2b6cd6469fe2c2c982d89d813c14418';

/// Unidad del día (switch del header). Arranca en la preferida del atleta
/// (`GET /auth/me`, kg si no viene). keepAlive: se mantiene al salir y volver
/// a la sesión, y la usa el resumen de Entreno completado.

final class DayWeightUnitFamily extends $Family
    with
        $ClassFamilyOverride<
          DayWeightUnit,
          WeightUnit,
          WeightUnit,
          WeightUnit,
          String
        > {
  DayWeightUnitFamily._()
    : super(
        retry: null,
        name: r'dayWeightUnitProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Unidad del día (switch del header). Arranca en la preferida del atleta
  /// (`GET /auth/me`, kg si no viene). keepAlive: se mantiene al salir y volver
  /// a la sesión, y la usa el resumen de Entreno completado.

  DayWeightUnitProvider call(String dayId) =>
      DayWeightUnitProvider._(argument: dayId, from: this);

  @override
  String toString() => r'dayWeightUnitProvider';
}

/// Unidad del día (switch del header). Arranca en la preferida del atleta
/// (`GET /auth/me`, kg si no viene). keepAlive: se mantiene al salir y volver
/// a la sesión, y la usa el resumen de Entreno completado.

abstract class _$DayWeightUnit extends $Notifier<WeightUnit> {
  late final _$args = ref.$arg as String;
  String get dayId => _$args;

  WeightUnit build(String dayId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WeightUnit, WeightUnit>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WeightUnit, WeightUnit>,
              WeightUnit,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Override de unidad por ejercicio (tap en la unidad del ejercicio).
/// Sobrevive a cambios del switch del día.

@ProviderFor(ExerciseUnitOverrides)
final exerciseUnitOverridesProvider = ExerciseUnitOverridesFamily._();

/// Override de unidad por ejercicio (tap en la unidad del ejercicio).
/// Sobrevive a cambios del switch del día.
final class ExerciseUnitOverridesProvider
    extends $NotifierProvider<ExerciseUnitOverrides, Map<String, WeightUnit>> {
  /// Override de unidad por ejercicio (tap en la unidad del ejercicio).
  /// Sobrevive a cambios del switch del día.
  ExerciseUnitOverridesProvider._({
    required ExerciseUnitOverridesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'exerciseUnitOverridesProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseUnitOverridesHash();

  @override
  String toString() {
    return r'exerciseUnitOverridesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ExerciseUnitOverrides create() => ExerciseUnitOverrides();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, WeightUnit> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, WeightUnit>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseUnitOverridesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseUnitOverridesHash() =>
    r'53928b1e8c4d4e8fe0071e6d61441309a3d512da';

/// Override de unidad por ejercicio (tap en la unidad del ejercicio).
/// Sobrevive a cambios del switch del día.

final class ExerciseUnitOverridesFamily extends $Family
    with
        $ClassFamilyOverride<
          ExerciseUnitOverrides,
          Map<String, WeightUnit>,
          Map<String, WeightUnit>,
          Map<String, WeightUnit>,
          String
        > {
  ExerciseUnitOverridesFamily._()
    : super(
        retry: null,
        name: r'exerciseUnitOverridesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Override de unidad por ejercicio (tap en la unidad del ejercicio).
  /// Sobrevive a cambios del switch del día.

  ExerciseUnitOverridesProvider call(String dayId) =>
      ExerciseUnitOverridesProvider._(argument: dayId, from: this);

  @override
  String toString() => r'exerciseUnitOverridesProvider';
}

/// Override de unidad por ejercicio (tap en la unidad del ejercicio).
/// Sobrevive a cambios del switch del día.

abstract class _$ExerciseUnitOverrides
    extends $Notifier<Map<String, WeightUnit>> {
  late final _$args = ref.$arg as String;
  String get dayId => _$args;

  Map<String, WeightUnit> build(String dayId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<Map<String, WeightUnit>, Map<String, WeightUnit>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, WeightUnit>, Map<String, WeightUnit>>,
              Map<String, WeightUnit>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Resumen del entreno (Entreno completado), en la unidad del día.

@ProviderFor(workoutSummary)
final workoutSummaryProvider = WorkoutSummaryFamily._();

/// Resumen del entreno (Entreno completado), en la unidad del día.

final class WorkoutSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkoutSummary>,
          WorkoutSummary,
          FutureOr<WorkoutSummary>
        >
    with $FutureModifier<WorkoutSummary>, $FutureProvider<WorkoutSummary> {
  /// Resumen del entreno (Entreno completado), en la unidad del día.
  WorkoutSummaryProvider._({
    required WorkoutSummaryFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'workoutSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutSummaryHash();

  @override
  String toString() {
    return r'workoutSummaryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<WorkoutSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WorkoutSummary> create(Ref ref) {
    final argument = this.argument as (String, String);
    return workoutSummary(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutSummaryHash() => r'e78a91b93f530e56ec2ce75563d261cac58017ae';

/// Resumen del entreno (Entreno completado), en la unidad del día.

final class WorkoutSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WorkoutSummary>, (String, String)> {
  WorkoutSummaryFamily._()
    : super(
        retry: null,
        name: r'workoutSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Resumen del entreno (Entreno completado), en la unidad del día.

  WorkoutSummaryProvider call(String assignmentId, String dayId) =>
      WorkoutSummaryProvider._(argument: (assignmentId, dayId), from: this);

  @override
  String toString() => r'workoutSummaryProvider';
}
