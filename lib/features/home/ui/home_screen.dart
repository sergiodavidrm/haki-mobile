import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/haki_colors.dart';
import '../../auth/data/auth_repository.dart';
import '../providers/api_check_provider.dart';

// Placeholder de la pantalla Hoy: muestra si la conexión con la API funciona.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final check = ref.watch(apiCheckProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoy'),
        backgroundColor: c.background,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(apiCheckProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            switch (check) {
              AsyncData(:final value) => Text(value, style: TextStyle(color: c.turquoise)),
              AsyncError(:final error) =>
                Text('Error llamando a la API:\n$error', style: TextStyle(color: c.danger)),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ],
        ),
      ),
    );
  }
}
