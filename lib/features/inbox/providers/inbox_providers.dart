import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/inbox_dtos.dart';
import '../data/inbox_repository.dart';

part 'inbox_providers.g.dart';

/// Campana de avisos. Se recarga al volver a primer plano y cuando llega un
/// push de la API con la app abierta (`ChatPush`).
@riverpod
class MyInbox extends _$MyInbox {
  @override
  Future<Inbox> build() {
    final listener = AppLifecycleListener(onResume: ref.invalidateSelf);
    ref.onDispose(listener.dispose);
    return ref
        .watch(inboxRepositoryProvider)
        .getMine(
          onUpdated: () {
            if (ref.mounted) ref.invalidateSelf();
          },
        );
  }

  /// Marca leídos al instante y avisa a la API (ids null = todos). Sin señal
  /// queda leído en pantalla y vuelve como no leído al recargar.
  Future<void> markRead([Set<String>? ids]) async {
    final current = state.value;
    if (current == null || current.unread == 0) return;
    state = AsyncData(current.markRead(ids));
    try {
      await ref.read(inboxRepositoryProvider).markRead(ids?.toList());
    } catch (e) {
      debugPrint('Inbox: no se pudo marcar leído ($e)');
    }
  }
}
