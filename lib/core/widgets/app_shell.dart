import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/chat/providers/chat_providers.dart';
import '../theme/haki_colors.dart';

/// Scaffold con la barra inferior de los 4 tabs (Hoy · Programa · Chat · Perfil).
/// Cada tab es una rama de StatefulShellRoute: conserva su estado y su pila.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Conecta el chat al entrar (para el badge de no leídos del tab)
    final channel = ref.watch(generalChannelProvider).value;
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
            const NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              label: 'Hoy',
            ),
            const NavigationDestination(
              icon: Icon(Icons.fitness_center),
              label: 'Programa',
            ),
            NavigationDestination(
              icon: StreamBuilder<int>(
                stream: channel?.state?.unreadCountStream,
                initialData: channel?.state?.unreadCount ?? 0,
                builder: (context, snap) {
                  final n = snap.data ?? 0;
                  return Badge(
                    isLabelVisible: n > 0,
                    label: Text(n > 9 ? '9+' : '$n'),
                    backgroundColor: context.colors.gold,
                    textColor: context.colors.background,
                    child: const Icon(Icons.chat_bubble_outline),
                  );
                },
              ),
              label: 'Chat',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
