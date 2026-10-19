import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import 'program_providers.dart';

part 'program_refresher.g.dart';

/// Pantallas de entreno: ahí nunca se recarga el programa solo (el coach pudo
/// cambiar el día y no hay que moverle la pantalla al atleta mientras entrena).
const _trainingRoutes = [
  '/sesion/',
  '/descanso',
  '/ejercicio/',
  '/completado/',
];

bool isTrainingRoute(String path) =>
    _trainingRoutes.any((r) => path.startsWith(r));

/// Al volver la app a primer plano vuelve a pedir los programas y el detalle
/// (cambios del coach), salvo durante un entreno. Se arranca en app.dart.
@Riverpod(keepAlive: true)
void programRefresher(Ref ref) {
  final listener = AppLifecycleListener(
    onResume: () {
      final path = ref
          .read(appRouterProvider)
          .routerDelegate
          .currentConfiguration
          .uri
          .path;
      if (isTrainingRoute(path)) return;
      ref.invalidate(programSectionsProvider);
      ref.invalidate(programDetailProvider);
    },
  );
  ref.onDispose(listener.dispose);
}
