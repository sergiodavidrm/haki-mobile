import 'dart:async';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../../core/units/weight_unit.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/providers/auth_me_provider.dart';

part 'settings_providers.g.dart';

const _vibrationKey = 'rest_vibrate';

/// Ajustes → Vibrar al terminar el descanso. Preferencia del teléfono
/// (shared_preferences), arranca en true.
@Riverpod(keepAlive: true)
class RestVibration extends _$RestVibration {
  @override
  bool build() {
    unawaited(_load());
    return true;
  }

  Future<void> _load() async {
    final saved = await SharedPreferencesAsync().getBool(_vibrationKey);
    if (saved != null) state = saved;
  }

  void set(bool on) {
    state = on;
    unawaited(SharedPreferencesAsync().setBool(_vibrationKey, on));
  }
}

const _themeKey = 'theme_mode';

/// Ajustes → Tema: Sistema (default), Claro u Oscuro. Preferencia del
/// teléfono (shared_preferences `theme_mode`: system | light | dark).
@Riverpod(keepAlive: true)
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() {
    unawaited(_load());
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final saved = await SharedPreferencesAsync().getString(_themeKey);
    final mode = ThemeMode.values.asNameMap()[saved];
    if (mode != null) state = mode;
  }

  void set(ThemeMode mode) {
    state = mode;
    unawaited(SharedPreferencesAsync().setString(_themeKey, mode.name));
  }
}

/// Ajustes → Unidad de peso: PATCH auth/me/weight-unit y refresca /auth/me
/// (Sesión y peso corporal la leen de ahí). El estado es el guardado en curso.
@riverpod
class WeightUnitSaver extends _$WeightUnitSaver {
  @override
  FutureOr<void> build() {}

  Future<bool> save(WeightUnit unit) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(apiClientProvider)
          .patch<void>(
            '/auth/me/weight-unit',
            data: {'preferredWeightUnit': unit.api},
          );
      ref.invalidate(authMeProvider);
    });
    return !state.hasError;
  }
}

/// Ajustes → Cambiar contraseña (Supabase). El estado es el guardado en curso.
@riverpod
class PasswordChanger extends _$PasswordChanger {
  @override
  FutureOr<void> build() {}

  Future<bool> change(String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).changePassword(password),
    );
    return !state.hasError;
  }
}
