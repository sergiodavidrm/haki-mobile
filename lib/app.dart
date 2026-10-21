import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/haki_colors.dart';
import 'core/widgets/splash_screen.dart';
import 'features/chat/providers/chat_providers.dart';
import 'features/program/providers/program_refresher.dart';
import 'features/session/data/session_sync.dart';
import 'features/session/providers/local_data_guard.dart';
import 'features/settings/providers/settings_providers.dart';

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
      // Tema: Sistema (default), Claro u Oscuro desde Ajustes
      theme: buildAppTheme(HakiColors.light, brightness: Brightness.light),
      darkTheme: buildAppTheme(HakiColors.obsidian),
      themeMode: ref.watch(appThemeModeProvider),
      routerConfig: ref.watch(appRouterProvider),
      // Conexión de Stream: se corta en background y vuelve al abrir la app.
      // El splash va arriba de todo mientras la app arranca abajo.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        // Íconos de la barra de estado según el tema (no hay AppBar que lo haga)
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: StreamChatCore(
          client: ref.watch(streamClientProvider),
          child: SplashOverlay(child: child!),
        ),
      ),
    );
  }
}
