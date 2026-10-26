import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/haki_loader.dart';
import '../data/auth_repository.dart';
import '../providers/auth_me_provider.dart';
import 'invitation_screen.dart';
import '../../../l10n/l10n.dart';

// Deja pasar solo a atletas. Cualquiera puede crear una sesión en Supabase
// (Google o Crear cuenta): sin usuario en haki-api se busca una invitación
// para su email (InvitationGate); un coach ve un mensaje.
class AthleteGate extends ConsumerWidget {
  const AthleteGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authMeProvider);

    return switch (me) {
      // Archivado o eliminado por el coach y ya pasó la semana de gracia
      AsyncData(:final value)
          when value.isAthlete && value.accessEnded(DateTime.now()) =>
        _Message(text: context.l10n.gateAccessEnded),
      AsyncData(:final value) when value.isAthlete => child,
      AsyncData(:final value) when !value.exists => const InvitationGate(),
      AsyncData() => _Message(text: context.l10n.gateCoach),
      AsyncError() => _Message(
          text: context.l10n.gateConnectError,
          onRetry: () => ref.invalidate(authMeProvider),
        ),
      _ => const Scaffold(body: Center(child: LoadingView())),
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
                FilledButton(onPressed: onRetry, child: Text(context.l10n.commonRetry)),
                const SizedBox(height: 12),
              ],
              OutlinedButton(
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
                child: Text(context.l10n.settingsSignOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
