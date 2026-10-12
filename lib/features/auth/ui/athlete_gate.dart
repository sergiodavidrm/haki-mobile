import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/haki_colors.dart';
import '../data/auth_repository.dart';
import '../providers/auth_me_provider.dart';

// Deja pasar solo a atletas. Con Google cualquiera puede crear una sesión en
// Supabase (Google sin invitación, o un coach): sin usuario CLIENT en haki-api
// no hay nada que mostrar.
class AthleteGate extends ConsumerWidget {
  const AthleteGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authMeProvider);

    return switch (me) {
      AsyncData(:final value) when value.isAthlete => child,
      AsyncData(:final value) => _Message(
          text: value.exists
              ? 'Esta app es para atletas. Como coach, entrá desde hakifit.com.'
              : 'Tu cuenta no está asociada a ningún coach. Pedile a tu coach que te '
                  'invite y entrá con el mismo email de la invitación.',
        ),
      AsyncError() => _Message(
          text: 'No se pudo conectar. Revisá tu conexión e intentá de nuevo.',
          onRetry: () => ref.invalidate(authMeProvider),
        ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

class _Message extends ConsumerWidget {
  const _Message({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(text, textAlign: TextAlign.center, style: TextStyle(color: c.textMuted)),
              const SizedBox(height: 24),
              if (onRetry != null) ...[
                FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
                const SizedBox(height: 12),
              ],
              OutlinedButton(
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
