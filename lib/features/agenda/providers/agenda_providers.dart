import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/cache/api_cache.dart';
import '../data/agenda_dtos.dart';
import '../data/agenda_repository.dart';

part 'agenda_providers.g.dart';

/// Sesiones con el coach (presenciales y virtuales) alrededor de hoy. Se
/// recarga al volver a primer plano mientras Hoy la escucha.
@riverpod
Future<List<MyAgendaEvent>> myAgenda(Ref ref) {
  final listener = AppLifecycleListener(onResume: ref.invalidateSelf);
  ref.onDispose(listener.dispose);
  final (from, to) = agendaRange(DateTime.now());
  return ref
      .watch(agendaRepositoryProvider)
      .getMine(
        from,
        to,
        onUpdated: () {
          if (ref.mounted) ref.invalidateSelf();
        },
      );
}

/// "Voy", "No puedo ir" y deshacerlos. El estado es el envío en curso.
@riverpod
class AgendaDecliner extends _$AgendaDecliner {
  @override
  FutureOr<void> build() {}

  /// true si se guardó.
  Future<bool> decline(String eventId, String? reason) => _run(
    () => ref
        .read(agendaRepositoryProvider)
        .decline(eventId, reason == null || reason.trim().isEmpty ? null : reason.trim()),
  );

  Future<bool> undo(String eventId) =>
      _run(() => ref.read(agendaRepositoryProvider).undoDecline(eventId));

  Future<bool> confirm(String eventId) =>
      _run(() => ref.read(agendaRepositoryProvider).confirm(eventId));

  Future<bool> undoConfirm(String eventId) =>
      _run(() => ref.read(agendaRepositoryProvider).undoConfirm(eventId));

  Future<bool> _run(Future<void> Function() call) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await call();
      // Que Hoy lea la API y no la copia
      ref.read(apiCacheProvider).expire(wait: true);
      ref.invalidate(myAgendaProvider);
    });
    return !state.hasError;
  }
}
