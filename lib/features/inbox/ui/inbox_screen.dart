import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/notifications/haki_push.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/haki_loader.dart';
import '../../../l10n/l10n.dart';
import '../../home/providers/selected_day_provider.dart';
import '../data/inbox_dtos.dart';
import '../providers/inbox_providers.dart';

/// Campana de avisos (mockup "Avisos del atleta" del canvas de la Agenda):
/// invitaciones, cambios y cancelaciones de sesiones + recordatorios de pago.
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final inbox = ref.watch(myInboxProvider);
    final unread = inbox.value?.unread ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.inboxTitle),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => ref.read(myInboxProvider.notifier).markRead(),
              style: TextButton.styleFrom(foregroundColor: c.textSecondary),
              child: Text(l.inboxMarkRead),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(myInboxProvider.future),
        child: switch (inbox) {
          AsyncData(:final value) when value.items.isEmpty => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(32, 96, 32, 24),
            children: [
              Icon(Icons.notifications_none, size: 40, color: c.textMuted),
              const SizedBox(height: 12),
              Text(
                l.inboxEmptyTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l.inboxEmptyBody,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: c.textMuted),
              ),
            ],
          ),
          AsyncData(:final value) => ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
            itemCount: value.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _InboxTile(item: value.items[i]),
          ),
          AsyncError() => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(32, 96, 32, 24),
            children: [
              Text(
                l.errorOfflineRetry,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: c.textMuted),
              ),
            ],
          ),
          _ => const Center(child: HakiLoader()),
        },
      ),
    );
  }
}

class _InboxTile extends ConsumerWidget {
  const _InboxTile({required this.item});

  final InboxItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final text = hakiPushText(item.pushData);
    if (text == null) return const SizedBox.shrink();
    final unread = !item.read;
    final (icon, highlight) = switch (item.kind) {
      'event_invited' => (Icons.event_outlined, true),
      'event_changed' => (Icons.schedule, false),
      'event_cancelled' => (Icons.event_busy_outlined, false),
      'payment_reminder' => (Icons.payments_outlined, false),
      _ => (Icons.notifications_none, false),
    };
    final accent = highlight && unread;

    return Material(
      color: unread ? c.surface : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: unread ? c.turquoiseBorder : c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent ? c.turquoiseSurface : c.track,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: accent ? c.turquoise : c.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      text.body,
                      style: TextStyle(fontSize: 13, color: c.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatAgo(item.createdAt),
                      style: TextStyle(fontSize: 11, color: c.textMuted),
                    ),
                  ],
                ),
              ),
              if (unread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6, left: 8),
                  decoration: BoxDecoration(
                    color: c.goldBright,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Marca leído y, si es de una sesión, abre Hoy en ese día.
  void _open(BuildContext context, WidgetRef ref) {
    ref.read(myInboxProvider.notifier).markRead({item.id});
    final start = eventInboxKinds.contains(item.kind)
        ? eventStartOf(item.data)
        : null;
    if (start == null) return;
    ref.read(selectedDayProvider.notifier).select(start);
    context.go(Routes.home);
  }
}
