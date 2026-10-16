import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/db/app_database.dart';
import '../../auth/data/auth_repository.dart';
import 'rest_timer.dart';
import 'session_providers.dart';

part 'local_data_guard.g.dart';

const _ownerKey = 'local_db_owner';

/// La BD local es de un solo usuario. Se guarda de quién es; al cerrar sesión
/// o si entra otro usuario se borra todo (y el estado en memoria de la sesión).
/// Sin dueño guardado (instalaciones previas a esto) se asume del usuario
/// actual. Antes de cerrar sesión, Perfil avisa si queda algo sin subir.
@Riverpod(keepAlive: true)
void localDataGuard(Ref ref) {
  final auth = ref.watch(authRepositoryProvider);
  final db = ref.watch(appDatabaseProvider);
  final prefs = SharedPreferencesAsync();

  Future<void> check() async {
    final userId = auth.userId;
    final owner = await prefs.getString(_ownerKey);
    if (owner == userId) return;
    if (owner != null) {
      await db.wipe();
      ref.invalidate(dayWeightUnitProvider);
      ref.invalidate(exerciseUnitOverridesProvider);
      ref.read(restTimerProvider.notifier).reset();
    }
    if (userId == null) {
      await prefs.remove(_ownerKey);
    } else {
      await prefs.setString(_ownerKey, userId);
    }
  }

  unawaited(check());
  final sub = auth.authChanges().listen((_) => unawaited(check()));
  ref.onDispose(sub.cancel);
}
