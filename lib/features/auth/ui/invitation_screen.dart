import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/legal/legal_links.dart';
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
      AsyncData(value: final invitation?) when invitation.expired =>
        _NoInvitationScreen(expiredFrom: invitation.coachName),
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

class _InvitationScreen extends ConsumerStatefulWidget {
  const _InvitationScreen({required this.invitation});

  final MyInvitationDto invitation;

  @override
  ConsumerState<_InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends ConsumerState<_InvitationScreen> {
  // Las dos obligatorias para Aceptar (Términos + datos de salud, Ley 8968)
  bool _terms = false;
  bool _health = false;

  @override
  Widget build(BuildContext context) {
    final invitation = widget.invitation;
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
      const SizedBox(height: 20),
      _ConsentBox(
        value: _terms,
        onChanged: (v) => setState(() => _terms = v),
        child: LegalSentence(
          before: l.legalAcceptBefore,
          middle: l.legalAnd,
          after: '.',
          fontSize: 14,
          textAlign: WrapAlignment.start,
          color: c.text,
        ),
      ),
      const SizedBox(height: 10),
      _ConsentBox(
        value: _health,
        onChanged: (v) => setState(() => _health = v),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.legalHealthConsent, style: TextStyle(color: c.text, fontSize: 14, height: 1.45)),
          const SizedBox(height: 4),
          Text(l.legalHealthConsentHint,
              style: TextStyle(color: c.textMuted, fontSize: 12, height: 1.45)),
        ]),
      ),
      const SizedBox(height: 20),
      if (!(_terms && _health)) ...[
        Text(l.legalCheckBoth,
            textAlign: TextAlign.center, style: TextStyle(color: c.textMuted, fontSize: 13)),
        const SizedBox(height: 10),
      ],
      FilledButton(
        onPressed: state.isLoading || !(_terms && _health)
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

/// Casilla grande (toda la fila tocable) con su texto.
class _ConsentBox extends StatelessWidget {
  const _ConsentBox({required this.value, required this.onChanged, required this.child});

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 14, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: value ? c.goldBorder : c.border),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: c.gold,
              checkColor: c.onAccent,
            ),
            const SizedBox(width: 2),
            Expanded(child: Padding(padding: const EdgeInsets.only(top: 12), child: child)),
          ]),
        ),
      ),
    );
  }
}

class _NoInvitationScreen extends ConsumerWidget {
  const _NoInvitationScreen({this.expiredFrom});

  /// Nombre del coach si la invitación existe pero venció.
  final String? expiredFrom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final email = ref.watch(authRepositoryProvider).email ?? '';

    return _Frame(children: [
      Text(expiredFrom == null ? l.inviteNoneTitle : l.inviteExpiredTitle,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Text(expiredFrom == null ? l.inviteNoneBody(email) : l.inviteExpiredBody(expiredFrom!),
          style: TextStyle(color: c.textMuted, fontSize: 15, height: 1.5)),
      if (expiredFrom == null) ...[
        const SizedBox(height: 24),
        HakiCard(
          padding: const EdgeInsets.all(14),
          radius: 14,
          child: Text(l.inviteNoneHint,
              style: TextStyle(color: c.textSecondary, fontSize: 14, height: 1.5)),
        ),
      ],
      const SizedBox(height: 28),
      FilledButton(
        onPressed: () => ref.read(authRepositoryProvider).signOut(),
        child: Text(l.inviteOtherAccount),
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: () => ref.invalidate(myInvitationProvider),
        child: Text(expiredFrom == null ? l.inviteSearchAgain : l.inviteExpiredSearchAgain),
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
