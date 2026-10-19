import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/notifications/rest_notifications.dart';
import '../../settings/providers/settings_providers.dart';

part 'rest_timer.g.dart';

/// Qué se está descansando y qué viene después (lo muestra el timer).
class RestInfo {
  const RestInfo({required this.title, required this.subtitle, this.next});

  /// "Superserie A" / nombre del ejercicio.
  final String title;

  /// "A1 y A2 hechas · descansá antes de repetir".
  final String subtitle;
  final NextSetInfo? next;
}

class NextSetInfo {
  const NextSetInfo({
    required this.exerciseName,
    required this.setNumber,
    this.badge,
    this.target,
  });

  final String exerciseName;
  final int setNumber;
  final String? badge;

  /// "132 lb × 12 · RIR 1"
  final String? target;
}

/// Basado en timestamps ([endsAt]), no en un contador: si el SO duerme o
/// mata el isolate, al volver el tiempo restante sigue siendo correcto.
class RestTimerState {
  const RestTimerState({
    required this.totalSeconds,
    this.endsAt,
    this.pausedLeft,
    this.info,
  });

  final int totalSeconds;

  /// Corriendo hasta esta hora.
  final DateTime? endsAt;

  /// En pausa, con estos segundos restantes.
  final int? pausedLeft;
  final RestInfo? info;

  bool get active => endsAt != null || pausedLeft != null;
  bool get running => endsAt != null;
  bool get paused => pausedLeft != null;

  int leftAt(DateTime now) {
    if (endsAt != null) {
      final ms = endsAt!.difference(now).inMilliseconds;
      return ms <= 0 ? 0 : (ms / 1000).ceil();
    }
    return pausedLeft ?? totalSeconds;
  }

  bool doneAt(DateTime now) => running && leftAt(now) == 0;

  RestTimerState copyWith({
    int? totalSeconds,
    DateTime? Function()? endsAt,
    int? Function()? pausedLeft,
    RestInfo? Function()? info,
  }) => RestTimerState(
    totalSeconds: totalSeconds ?? this.totalSeconds,
    endsAt: endsAt != null ? endsAt() : this.endsAt,
    pausedLeft: pausedLeft != null ? pausedLeft() : this.pausedLeft,
    info: info != null ? info() : this.info,
  );
}

const restPresets = [60, 90, 120, 180];
const _prefKey = 'rest_seconds';

/// Timer de descanso de la sesión. keepAlive: sigue corriendo al pasar entre
/// la Sesión y la pantalla del timer. Se recuerda la última duración elegida.
// Mientras corre hay notificación con cuenta regresiva (Android) y al terminar
// suena una notificación programada, aunque la app esté cerrada.
@Riverpod(keepAlive: true)
class RestTimer extends _$RestTimer {
  Timer? _done;

  @override
  RestTimerState build() {
    ref.onDispose(() => _done?.cancel());
    unawaited(_loadPreferred());
    return const RestTimerState(totalSeconds: 90);
  }

  Future<void> _loadPreferred() async {
    final saved = await SharedPreferencesAsync().getInt(_prefKey);
    if (saved != null && !state.active) {
      state = state.copyWith(totalSeconds: saved);
    }
  }

  /// La Sesión avisa qué viene después de cada serie guardada; el timer lo
  /// muestra cuando el atleta lo arranca (no arranca solo). Si ya está
  /// corriendo no se pisa.
  void prepare(RestInfo info) {
    if (!state.active) state = state.copyWith(info: () => info);
  }

  /// Arranca de cero con la duración elegida (siempre a mano).
  void start() => _run(state.totalSeconds);

  void toggle() {
    final now = DateTime.now();
    if (state.doneAt(now)) return restart();
    if (state.running) {
      _done?.cancel();
      state = state.copyWith(
        endsAt: () => null,
        pausedLeft: () => state.leftAt(now),
      );
      _notifyPaused();
    } else {
      _run(state.pausedLeft ?? state.totalSeconds);
    }
  }

  /// ±15 s. Si se pasa de la duración, la duración crece (el anillo no se
  /// sale de rango).
  void adjust(int deltaSeconds) {
    final now = DateTime.now();
    final left = max(0, state.leftAt(now) + deltaSeconds);
    final total = max(state.totalSeconds, left);
    if (state.running) {
      _run(left, total: total);
    } else if (state.paused) {
      state = state.copyWith(totalSeconds: total, pausedLeft: () => left);
      _notifyPaused();
    } else {
      state = state.copyWith(totalSeconds: max(15, left));
    }
  }

  void restart() => _run(state.totalSeconds);

  /// Elegir una duración: queda como preferida. Si estaba corriendo, vuelve a
  /// arrancar con la nueva.
  void setDuration(int seconds) {
    unawaited(SharedPreferencesAsync().setInt(_prefKey, seconds));
    if (state.running) {
      _run(seconds, total: seconds);
    } else {
      state = state.copyWith(
        totalSeconds: seconds,
        pausedLeft: state.paused ? () => seconds : null,
      );
      if (state.paused) _notifyPaused();
    }
  }

  /// Cierra la barra. Se queda con la info preparada (qué viene después).
  void dismiss() {
    _done?.cancel();
    unawaited(ref.read(restNotificationsProvider).cancel());
    state = state.copyWith(endsAt: () => null, pausedLeft: () => null);
  }

  /// Fin de la sesión / cambio de usuario: también olvida la info.
  void reset() {
    dismiss();
    state = state.copyWith(info: () => null);
  }

  /// "Sigue: Remo… · serie 2" para las notificaciones.
  String? _nextLabel() {
    final next = state.info?.next;
    return next == null
        ? null
        : 'Sigue: ${next.exerciseName} · serie ${next.setNumber}';
  }

  void _notifyPaused() => unawaited(
    ref
        .read(restNotificationsProvider)
        .paused(state.pausedLeft ?? 0, title: _nextLabel()),
  );

  void _run(int seconds, {int? total}) {
    _done?.cancel();
    final vibrate = ref.read(restVibrationProvider);
    final endsAt = DateTime.now().add(Duration(seconds: seconds));
    state = state.copyWith(
      totalSeconds: total,
      endsAt: () => endsAt,
      pausedLeft: () => null,
    );
    unawaited(
      ref
          .read(restNotificationsProvider)
          .start(endsAt, title: _nextLabel(), vibrate: vibrate),
    );
    _done = Timer(Duration(seconds: seconds), () async {
      if (!vibrate) return;
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 180));
      await HapticFeedback.heavyImpact();
    });
  }
}
