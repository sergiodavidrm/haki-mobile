import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/haki_colors.dart';
import 'features/program/providers/program_refresher.dart';
import 'features/session/data/session_sync.dart';
import 'features/session/providers/local_data_guard.dart';

class HakiApp extends ConsumerWidget {
  const HakiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Arranca el sync de entrenos (sube lo que quedó pendiente)
    ref.watch(sessionSyncProvider);
    // Borra los datos locales al cerrar sesión o si entra otro usuario
    ref.watch(localDataGuardProvider);
    // Recarga programas al volver a primer plano (no durante un entreno)
    ref.watch(programRefresherProvider);
    return MaterialApp.router(
      title: 'Haki',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(HakiColors.obsidian),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
