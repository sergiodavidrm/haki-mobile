import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/format/dates.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../l10n/l10n.dart';
import '../data/agenda_dtos.dart';
import '../providers/agenda_providers.dart';

/// Tarjeta de Hoy: una sesión con el coach (mockup "Hoy con sesión" del canvas
/// de la Agenda). Va debajo de la tarjeta del entreno.
class AgendaEventCard extends ConsumerWidget {
  const AgendaEventCard({super.key, required this.event});

  final MyAgendaEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final e = event;
    final now = DateTime.now();
    final ended = e.endedAt(now);
    final muted = e.cancelled || e.declined;
    final accent = e.isVirtual ? c.mobilityText : c.turquoise;
    final border = e.isVirtual ? c.mobility : c.turquoise;
    final busy = ref.watch(agendaDeclinerProvider).isLoading;

    final isToday = DateUtils.isSameDay(e.startsAt, now);
    final when = isToday
        ? '${l.agendaToday} ${formatTime(e.startsAt)}'
        : '${formatShortDate(e.startsAt)} ${formatTime(e.startsAt)}';
    final label = e.cancelled
        ? l.agendaCancelledLabel(when)
        : '${e.isVirtual ? l.agendaVirtual : l.agendaInPerson} · $when';

    final place = e.isVirtual ? null : e.location;
    final timeLine = [
      '${formatTime(e.startsAt)} – ${formatTime(e.endsAt)}',
      ?place,
    ].join(' · ');

    final actions = <Widget>[
      if (!e.isVirtual && e.location != null)
        _ActionButton(
          icon: Icons.place_outlined,
          label: l.agendaDirections,
          onTap: () => _open(context, directionsUri(e.location!)),
        ),
      if (e.isVirtual && e.meetingUrl != null && meetingUri(e.meetingUrl!) != null)
        _ActionButton(
          icon: Icons.videocam_outlined,
          label: l.agendaJoin,
          filled: isToday,
          onTap: () => _open(context, meetingUri(e.meetingUrl!)!),
        ),
      _ActionButton(
        icon: Icons.chat_bubble_outline,
        label: l.agendaMessage,
        onTap: () => context.go(Routes.chatGeneral),
      ),
    ];

    return HakiCard(
      borderColor: muted ? null : border,
      borderWidth: muted ? 1 : 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: muted ? c.textMuted : accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            e.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: e.cancelled ? c.textMuted : c.text,
              decoration: e.cancelled ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 3),
          Text(timeLine, style: TextStyle(fontSize: 14, color: c.textSecondary)),
          if (e.note != null && !e.cancelled) ...[
            const SizedBox(height: 6),
            Text(
              '"${e.note}"',
              style: TextStyle(fontSize: 13, color: c.textMuted),
            ),
          ],
          if (e.cancelled) ...[
            const SizedBox(height: 6),
            Text(
              l.agendaCancelledBody(e.coachFirstName),
              style: TextStyle(fontSize: 13, color: c.textMuted),
            ),
          ] else if (e.declined) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.event_busy_outlined, size: 18, color: c.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.agendaDeclined(e.coachFirstName),
                    style: TextStyle(fontSize: 13, color: c.textSecondary),
                  ),
                ),
              ],
            ),
            if (!ended)
              TextButton(
                onPressed: busy ? null : () => _confirm(context, ref),
                style: TextButton.styleFrom(
                  foregroundColor: c.textSecondary,
                  minimumSize: const Size.fromHeight(40),
                ),
                child: Text(l.agendaUndoDecline),
              ),
          ] else if (!ended) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                for (final (i, a) in actions.indexed) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: a),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (e.confirmed)
              // Confirmó: lo dice y deja cambiar de idea
              Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: c.turquoise),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.agendaConfirmed(e.coachFirstName),
                      style: TextStyle(fontSize: 13, color: c.textSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: busy ? null : () => _decline(context, ref),
                    style: TextButton.styleFrom(
                      foregroundColor: c.textMuted,
                      minimumSize: const Size(0, 40),
                    ),
                    child: Text(l.agendaCantGo),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: busy ? null : () => _confirm(context, ref),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(l.agendaGoing),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: busy ? null : () => _decline(context, ref),
                      style: TextButton.styleFrom(
                        foregroundColor: c.textMuted,
                        minimumSize: const Size(0, 44),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(l.agendaCantGo),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    final msg = context.l10n.agendaOpenError;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _decline(BuildContext context, WidgetRef ref) async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.colors.surface,
      builder: (_) => _DeclineSheet(event: event),
    );
    if (reason == null || !context.mounted) return;
    final notifier = ref.read(agendaDeclinerProvider.notifier);
    final ok = await notifier.decline(event.id, reason);
    if (!ok && context.mounted) _showError(context, ref);
  }

  /// "Voy" (también "Deshacer · sí voy" después de un "No puedo ir")
  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(agendaDeclinerProvider.notifier).confirm(event.id);
    if (!ok && context.mounted) _showError(context, ref);
  }

  void _showError(BuildContext context, WidgetRef ref) {
    final error = ref.read(agendaDeclinerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(apiErrorMessage(error ?? Exception()))),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    const text = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17),
        const SizedBox(width: 6),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
    if (filled) {
      return FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: shape,
          textStyle: text,
        ),
        child: child,
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: c.text,
        side: BorderSide(color: c.border),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: shape,
        textStyle: text,
      ),
      child: child,
    );
  }
}

/// Hoja "No puedo ir": motivo opcional. Devuelve el motivo ('' = sin motivo)
/// o null si cancela.
class _DeclineSheet extends StatefulWidget {
  const _DeclineSheet({required this.event});

  final MyAgendaEvent event;

  @override
  State<_DeclineSheet> createState() => _DeclineSheetState();
}

class _DeclineSheetState extends State<_DeclineSheet> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final e = widget.event;
    final coach = e.coachFirstName;
    final when =
        '${capitalize(formatShortDate(e.startsAt))} · ${formatTime(e.startsAt)}';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.agendaDeclineTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: c.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${e.title} · $when',
              style: TextStyle(fontSize: 14, color: c.textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              l.agendaDeclineInfo(coach),
              style: TextStyle(fontSize: 14, color: c.textSecondary),
            ),
            const SizedBox(height: 14),
            Text(
              l.agendaDeclineReason,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _reason,
              minLines: 2,
              maxLines: 4,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(counterText: ''),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => Navigator.pop(context, _reason.text),
              child: Text(l.agendaDeclineConfirm(coach)),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: c.textSecondary,
                minimumSize: const Size.fromHeight(44),
              ),
              child: Text(l.commonCancel),
            ),
          ],
        ),
      ),
    );
  }
}
