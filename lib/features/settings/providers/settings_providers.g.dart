// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ajustes → Vibrar al terminar el descanso. Preferencia del teléfono
/// (shared_preferences), arranca en true.

@ProviderFor(RestVibration)
final restVibrationProvider = RestVibrationProvider._();

/// Ajustes → Vibrar al terminar el descanso. Preferencia del teléfono
/// (shared_preferences), arranca en true.
final class RestVibrationProvider
    extends $NotifierProvider<RestVibration, bool> {
  /// Ajustes → Vibrar al terminar el descanso. Preferencia del teléfono
  /// (shared_preferences), arranca en true.
  RestVibrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restVibrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restVibrationHash();

  @$internal
  @override
  RestVibration create() => RestVibration();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$restVibrationHash() => r'de9791271f0de4dae7b22bf8a4589095a1f87ff3';

/// Ajustes → Vibrar al terminar el descanso. Preferencia del teléfono
/// (shared_preferences), arranca en true.

abstract class _$RestVibration extends $Notifier<bool> {
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

/// Ajustes → Unidad de peso: PATCH auth/me/weight-unit y refresca /auth/me
/// (Sesión y peso corporal la leen de ahí). El estado es el guardado en curso.

@ProviderFor(WeightUnitSaver)
final weightUnitSaverProvider = WeightUnitSaverProvider._();

/// Ajustes → Unidad de peso: PATCH auth/me/weight-unit y refresca /auth/me
/// (Sesión y peso corporal la leen de ahí). El estado es el guardado en curso.
final class WeightUnitSaverProvider
    extends $AsyncNotifierProvider<WeightUnitSaver, void> {
  /// Ajustes → Unidad de peso: PATCH auth/me/weight-unit y refresca /auth/me
  /// (Sesión y peso corporal la leen de ahí). El estado es el guardado en curso.
  WeightUnitSaverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weightUnitSaverProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weightUnitSaverHash();

  @$internal
  @override
  WeightUnitSaver create() => WeightUnitSaver();
}

String _$weightUnitSaverHash() => r'14967e69558ba9fe7a179416716072ec2c198943';

/// Ajustes → Unidad de peso: PATCH auth/me/weight-unit y refresca /auth/me
/// (Sesión y peso corporal la leen de ahí). El estado es el guardado en curso.

abstract class _$WeightUnitSaver extends $AsyncNotifier<void> {
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

/// Ajustes → Cambiar contraseña (Supabase). El estado es el guardado en curso.

@ProviderFor(PasswordChanger)
final passwordChangerProvider = PasswordChangerProvider._();

/// Ajustes → Cambiar contraseña (Supabase). El estado es el guardado en curso.
final class PasswordChangerProvider
    extends $AsyncNotifierProvider<PasswordChanger, void> {
  /// Ajustes → Cambiar contraseña (Supabase). El estado es el guardado en curso.
  PasswordChangerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passwordChangerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passwordChangerHash();

  @$internal
  @override
  PasswordChanger create() => PasswordChanger();
}

String _$passwordChangerHash() => r'882c39317f2aeca962bd9d06ab8785a077914548';

/// Ajustes → Cambiar contraseña (Supabase). El estado es el guardado en curso.

abstract class _$PasswordChanger extends $AsyncNotifier<void> {
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
