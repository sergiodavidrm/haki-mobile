import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/providers/auth_me_provider.dart';
import '../data/level_dto.dart';

part 'level_providers.g.dart';

/// Nivel, XP y logros del atleta (Perfil y Nivel y logros). Necesita red: sin
/// ella la tarjeta no se muestra. La API recalcula el XP en cada llamada.
@riverpod
Future<LevelDto> level(Ref ref) async {
  final me = await ref.watch(authMeProvider.future);
  return ref.watch(levelRepositoryProvider).get(me.userId);
}

/// "+190 XP" de Entreno completado. El entreno sube en cola: mientras la API
/// no lo tenga completo (`pending`) vuelve a preguntar unas veces.
@riverpod
Future<SessionXpDto> dayXp(Ref ref, String assignmentId, String dayId) async {
  final me = await ref.watch(authMeProvider.future);
  final repo = ref.watch(levelRepositoryProvider);
  var result = await repo.day(me.userId, assignmentId, dayId);
  for (var i = 0; i < 6 && result.pending; i++) {
    await Future<void>.delayed(const Duration(seconds: 4));
    if (!ref.mounted) return result;
    result = await repo.day(me.userId, assignmentId, dayId);
  }
  // El Perfil muestra el nivel nuevo
  if (!result.pending && ref.mounted) ref.invalidate(levelProvider);
  return result;
}

const _showKey = 'show_gamification';

/// Ajustes → "Mostrar niveles y logros" (2026-11-13, Sergio): el atleta puede
/// ocultarlos aunque el coach los tenga prendidos. Preferencia del teléfono,
/// arranca prendida.
@Riverpod(keepAlive: true)
class ShowGamification extends _$ShowGamification {
  @override
  bool build() {
    unawaited(_load());
    return true;
  }

  Future<void> _load() async {
    final saved = await SharedPreferencesAsync().getBool(_showKey);
    if (saved != null) state = saved;
  }

  void set(bool on) {
    state = on;
    unawaited(SharedPreferencesAsync().setBool(_showKey, on));
  }
}

/// Niveles y logros a la vista: el coach los muestra (`levelsEnabled`) y el
/// atleta no los ocultó en Ajustes.
@riverpod
bool gamificationVisible(Ref ref) =>
    (ref.watch(authMeProvider).value?.levelsEnabled ?? true) &&
    ref.watch(showGamificationProvider);
