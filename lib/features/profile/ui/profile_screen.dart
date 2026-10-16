import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/data/auth_repository.dart';
import '../../session/data/session_store.dart';

// Tab Perfil. Por ahora: datos de la cuenta + cerrar sesión. Peso, medidas,
// adherencia y récords se suman como tarjetas (ver mockup).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final auth = ref.watch(authRepositoryProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          children: [
            Row(
              children: [
                UserAvatar(name: auth.displayName, size: 60, highlighted: true),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.displayName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: c.text,
                        ),
                      ),
                      if (auth.email != null)
                        Text(
                          auth.email!,
                          style: TextStyle(fontSize: 13, color: c.textMuted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: c.danger,
                side: BorderSide(color: c.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _signOut(context, ref),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cerrar sesión borra los datos del teléfono (LocalDataGuard): si queda algo
/// sin subir, avisar antes de perderlo.
Future<void> _signOut(BuildContext context, WidgetRef ref) async {
  final pending = await ref.read(sessionStoreProvider).pendingCount();
  if (pending > 0 && context.mounted) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tenés entrenos sin subir'),
        content: const Text(
          'Hay series guardadas en el teléfono que todavía no llegaron a tu '
          'coach. Si cerrás sesión ahora se pierden. Conectate a internet y '
          'esperá a que se suban.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar igual'),
          ),
        ],
      ),
    );
    if (ok != true) return;
  }
  await ref.read(authRepositoryProvider).signOut();
}
