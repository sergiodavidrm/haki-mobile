import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/chat/providers/chat_providers.dart';
import '../theme/haki_colors.dart';
import '../../l10n/l10n.dart';

/// Scaffold con la barra inferior de los 4 tabs (Hoy · Programa · Chat · Perfil).
/// Cada tab es una rama de StatefulShellRoute: conserva su estado y su pila.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Conecta el chat al entrar (para el badge de no leídos del tab). El
    // badge suma el chat con el coach y los grupos que la app conoce.
    final unread = ref.watch(chatUnreadProvider).value ?? 0;
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.colors.border)),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          // Tocar el tab activo vuelve a la raíz de esa rama
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.calendar_today_outlined),
              label: context.l10n.tabToday,
            ),
            NavigationDestination(
              icon: const Icon(Icons.fitness_center),
              label: context.l10n.tabProgram,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: unread > 0,
                label: Text(unread > 9 ? '9+' : '$unread'),
                backgroundColor: context.colors.gold,
                textColor: context.colors.onAccent,
                child: const Icon(Icons.chat_bubble_outline),
              ),
              label: context.l10n.tabChat,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              label: context.l10n.tabProfile,
            ),
          ],
        ),
      ),
    );
  }
}
