import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/haki_loader.dart';
import '../../../core/widgets/haki_logo.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/l10n.dart';
import '../data/auth_repository.dart';
import '../data/invitation_repository.dart';
import '../providers/invitation_providers.dart';

// Sesión iniciada pero todavía no es atleta en haki-api (AthleteGate): busca
// una invitación para su email y la acepta, o explica que no hay ninguna.
class InvitationGate extends ConsumerWidget {
  const InvitationGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(myInvitationProvider)) {
      AsyncData(value: final invitation?) => _InvitationScreen(invitation: invitation),
      AsyncData() => const _NoInvitationScreen(),
      AsyncError() => _Frame(children: [
          Text(context.l10n.gateConnectError,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textMuted)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => ref.invalidate(myInvitationProvider),
            child: Text(context.l10n.commonRetry),
          ),
        ]),
      _ => const Scaffold(body: Center(child: LoadingView())),
    };
  }
}

class _InvitationScreen extends ConsumerWidget {
  const _InvitationScreen({required this.invitation});

  final MyInvitationDto invitation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final state = ref.watch(invitationAccepterProvider);
    final since = invitation.coachingSince;

    return _Frame(children: [
      Text(l.inviteTitle,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Text(l.inviteSubtitle, style: TextStyle(color: c.textMuted, fontSize: 15, height: 1.5)),
      const SizedBox(height: 28),
      HakiCard(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(children: [
            UserAvatar(name: invitation.coachName, size: 56, highlighted: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(invitation.coachName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  since == null
                      ? l.inviteCoach
                      : '${l.inviteCoach} · ${l.coachExperience(DateTime.now().year - since)}',
                  style: TextStyle(color: c.textMuted, fontSize: 13),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          Divider(color: c.border, height: 1),
          const SizedBox(height: 16),
          Row(children: [
            Text(l.inviteFor, style: TextStyle(color: c.textMuted, fontSize: 13)),
            const Spacer(),
            Flexible(
              child: Text(invitation.email,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ]),
        ]),
      ),
      if (state.hasError) ...[
        const SizedBox(height: 12),
        Text(apiErrorMessage(state.error!), style: TextStyle(color: c.danger)),
      ],
      const SizedBox(height: 28),
      FilledButton(
        onPressed: state.isLoading
            ? null
            : () => ref.read(invitationAccepterProvider.notifier).accept(invitation.id),
        child: state.isLoading
            ? const SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(l.inviteAccept),
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: state.isLoading ? null : () => ref.read(authRepositoryProvider).signOut(),
        child: Text(l.inviteNotMine, style: TextStyle(color: c.textMuted)),
      ),
    ]);
  }
}

class _NoInvitationScreen extends ConsumerWidget {
  const _NoInvitationScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final email = ref.watch(authRepositoryProvider).email ?? '';

    return _Frame(children: [
      Text(l.inviteNoneTitle,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Text(l.inviteNoneBody(email),
          style: TextStyle(color: c.textMuted, fontSize: 15, height: 1.5)),
      const SizedBox(height: 24),
      HakiCard(
        padding: const EdgeInsets.all(14),
        radius: 14,
        child: Text(l.inviteNoneHint,
            style: TextStyle(color: c.textSecondary, fontSize: 14, height: 1.5)),
      ),
      const SizedBox(height: 28),
      FilledButton(
        onPressed: () => ref.read(authRepositoryProvider).signOut(),
        child: Text(l.inviteOtherAccount),
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: () => ref.invalidate(myInvitationProvider),
        child: Text(l.inviteSearchAgain),
      ),
    ]);
  }
}

/// Logo arriba y el contenido debajo, con scroll.
class _Frame extends StatelessWidget {
  const _Frame({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(alignment: Alignment.centerLeft, child: HakiLogoMark(size: 40)),
              const SizedBox(height: 40),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
