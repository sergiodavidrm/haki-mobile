// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_timer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Timer de descanso de la sesión. keepAlive: sigue corriendo al pasar entre
/// la Sesión y la pantalla del timer. Se recuerda la última duración elegida.
// Mientras corre hay notificación con cuenta regresiva (Android) y al terminar
// suena una notificación programada, aunque la app esté cerrada.

@ProviderFor(RestTimer)
final restTimerProvider = RestTimerProvider._();

/// Timer de descanso de la sesión. keepAlive: sigue corriendo al pasar entre
/// la Sesión y la pantalla del timer. Se recuerda la última duración elegida.
// Mientras corre hay notificación con cuenta regresiva (Android) y al terminar
// suena una notificación programada, aunque la app esté cerrada.
final class RestTimerProvider
    extends $NotifierProvider<RestTimer, RestTimerState> {
  /// Timer de descanso de la sesión. keepAlive: sigue corriendo al pasar entre
  /// la Sesión y la pantalla del timer. Se recuerda la última duración elegida.
  // Mientras corre hay notificación con cuenta regresiva (Android) y al terminar
  // suena una notificación programada, aunque la app esté cerrada.
  RestTimerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restTimerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restTimerHash();

  @$internal
  @override
  RestTimer create() => RestTimer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestTimerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestTimerState>(value),
    );
  }
}

String _$restTimerHash() => r'68145d0192552e5477661e9cbaa6b49869f846ad';

/// Timer de descanso de la sesión. keepAlive: sigue corriendo al pasar entre
/// la Sesión y la pantalla del timer. Se recuerda la última duración elegida.
// Mientras corre hay notificación con cuenta regresiva (Android) y al terminar
// suena una notificación programada, aunque la app esté cerrada.

abstract class _$RestTimer extends $Notifier<RestTimerState> {
  RestTimerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RestTimerState, RestTimerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RestTimerState, RestTimerState>,
              RestTimerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
