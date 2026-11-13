// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ajustes → Compartir entrenos (2026-11-12, Sergio): sin activarlo no aparece
/// el botón Compartir. Preferencia del teléfono, arranca apagado.

@ProviderFor(ShareWorkoutsEnabled)
final shareWorkoutsEnabledProvider = ShareWorkoutsEnabledProvider._();

/// Ajustes → Compartir entrenos (2026-11-12, Sergio): sin activarlo no aparece
/// el botón Compartir. Preferencia del teléfono, arranca apagado.
final class ShareWorkoutsEnabledProvider
    extends $NotifierProvider<ShareWorkoutsEnabled, bool> {
  /// Ajustes → Compartir entrenos (2026-11-12, Sergio): sin activarlo no aparece
  /// el botón Compartir. Preferencia del teléfono, arranca apagado.
  ShareWorkoutsEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareWorkoutsEnabledProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareWorkoutsEnabledHash();

  @$internal
  @override
  ShareWorkoutsEnabled create() => ShareWorkoutsEnabled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$shareWorkoutsEnabledHash() =>
    r'd915cf90bc2df912a6292c4a466d463bd1192b4d';

/// Ajustes → Compartir entrenos (2026-11-12, Sergio): sin activarlo no aparece
/// el botón Compartir. Preferencia del teléfono, arranca apagado.

abstract class _$ShareWorkoutsEnabled extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Series del teléfono de un programa entero, por `setKey`.

@ProviderFor(assignmentLocalSets)
final assignmentLocalSetsProvider = AssignmentLocalSetsFamily._();

/// Series del teléfono de un programa entero, por `setKey`.

final class AssignmentLocalSetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, LocalSetEntry>>,
          Map<String, LocalSetEntry>,
          Stream<Map<String, LocalSetEntry>>
        >
    with
        $FutureModifier<Map<String, LocalSetEntry>>,
        $StreamProvider<Map<String, LocalSetEntry>> {
  /// Series del teléfono de un programa entero, por `setKey`.
  AssignmentLocalSetsProvider._({
    required AssignmentLocalSetsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'assignmentLocalSetsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assignmentLocalSetsHash();

  @override
  String toString() {
    return r'assignmentLocalSetsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, LocalSetEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, LocalSetEntry>> create(Ref ref) {
    final argument = this.argument as String;
    return assignmentLocalSets(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AssignmentLocalSetsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assignmentLocalSetsHash() =>
    r'764c1f06394fccd2463c56ec36ebbd64eb1ccff5';

/// Series del teléfono de un programa entero, por `setKey`.

final class AssignmentLocalSetsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, LocalSetEntry>>, String> {
  AssignmentLocalSetsFamily._()
    : super(
        retry: null,
        name: r'assignmentLocalSetsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Series del teléfono de un programa entero, por `setKey`.

  AssignmentLocalSetsProvider call(String assignmentId) =>
      AssignmentLocalSetsProvider._(argument: assignmentId, from: this);

  @override
  String toString() => r'assignmentLocalSetsProvider';
}

/// Datos de los stickers. [dayId] vacío = se entró sin un entreno (desde el
/// Perfil): Día muestra el último hecho y abre en Semana. Sin red no hay
/// récords ni racha (el resto sí).

@ProviderFor(shareData)
final shareDataProvider = ShareDataFamily._();

/// Datos de los stickers. [dayId] vacío = se entró sin un entreno (desde el
/// Perfil): Día muestra el último hecho y abre en Semana. Sin red no hay
/// récords ni racha (el resto sí).

final class ShareDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<ShareData>,
          ShareData,
          FutureOr<ShareData>
        >
    with $FutureModifier<ShareData>, $FutureProvider<ShareData> {
  /// Datos de los stickers. [dayId] vacío = se entró sin un entreno (desde el
  /// Perfil): Día muestra el último hecho y abre en Semana. Sin red no hay
  /// récords ni racha (el resto sí).
  ShareDataProvider._({
    required ShareDataFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'shareDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$shareDataHash();

  @override
  String toString() {
    return r'shareDataProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ShareData> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ShareData> create(Ref ref) {
    final argument = this.argument as (String, String);
    return shareData(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ShareDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shareDataHash() => r'fc660a795271ed33c97a405232a661d7a242f707';

/// Datos de los stickers. [dayId] vacío = se entró sin un entreno (desde el
/// Perfil): Día muestra el último hecho y abre en Semana. Sin red no hay
/// récords ni racha (el resto sí).

final class ShareDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ShareData>, (String, String)> {
  ShareDataFamily._()
    : super(
        retry: null,
        name: r'shareDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Datos de los stickers. [dayId] vacío = se entró sin un entreno (desde el
  /// Perfil): Día muestra el último hecho y abre en Semana. Sin red no hay
  /// récords ni racha (el resto sí).

  ShareDataProvider call(String assignmentId, String dayId) =>
      ShareDataProvider._(argument: (assignmentId, dayId), from: this);

  @override
  String toString() => r'shareDataProvider';
}
