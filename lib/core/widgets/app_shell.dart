import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/haki_colors.dart';

/// Scaffold con la barra inferior de los 4 tabs (Hoy · Programa · Chat · Perfil).
/// Cada tab es una rama de StatefulShellRoute: conserva su estado y su pila.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              label: 'Hoy',
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center),
              label: 'Programa',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
