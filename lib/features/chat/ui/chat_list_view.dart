import '../data/voice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../l10n/l10n.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../data/chat_message.dart';
import '../providers/chat_providers.dart';
import 'chat_widgets.dart';
import 'group_widgets.dart';

/// Tab Chat con grupos (mockup "App · Chat"): el coach arriba y los grupos
/// abajo, cada uno con su último mensaje y no leídos.
class ChatListView extends ConsumerWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final groups = ref.watch(chatGroupsProvider).value ?? const [];
    final general = ref.watch(generalChannelProvider).value;
    final coach = ref.watch(authMeProvider).value?.coachName ?? context.l10n.yourCoach;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(chatGroupsProvider.future),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Text(
                  context.l10n.tabChat,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: c.text),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.border),
                  ),
                  child: _ChannelRow(
                    channel: general,
                    leading: CoachAvatar(name: coach, size: 44),
                    title: coach,
                    prefix: context.l10n.yourCoach,
                    onTap: () => context.push(Routes.chatGeneral),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                child: Text(
                  context.l10n.chatGroupsSection.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .8,
                    color: c.textMuted,
                  ),
                ),
              ),
              for (final g in groups)
                StreamBuilder<Map<String, Object?>>(
                  stream: g.channel.extraDataStream,
                  builder: (context, _) => _ChannelRow(
                    channel: g.channel,
                    leading: GroupAvatar(announcements: !g.athletesCanWrite),
                    title: g.name,
                    showAuthor: true,
                    onTap: () => context.push(Routes.chatGroup(g.channel.id!)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila con el último mensaje, la hora y el badge de no leídos del canal.
class _ChannelRow extends StatelessWidget {
  const _ChannelRow({
    required this.channel,
    required this.leading,
    required this.title,
    required this.onTap,
    this.prefix,
    this.showAuthor = false,
  });

  final Channel? channel;
  final Widget leading;
  final String title;
  final VoidCallback onTap;

  /// Antes del último mensaje ("Tu coach · …").
  final String? prefix;

  /// Grupo: "Laura: …" con el nombre de quien escribió.
  final bool showAuthor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = channel?.state;
    final me = channel?.client.state.currentUser?.id;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: state?.messagesStream,
                initialData: state?.messages ?? const [],
                builder: (context, snap) {
                  final last = snap.data?.where((m) => !m.isDeleted).lastOrNull;
                  var preview = last?.text?.trim() ?? '';
                  final voice = last == null ? null : voiceOf(last);
                  if (preview.isEmpty && voice != null) {
                    preview = context.l10n.voicePreview(formatVoiceDuration(voice.duration));
                  }
                  if (preview.isEmpty && last != null && VideoCard.of(last) != null) {
                    preview = VideoCard.of(last)!.exerciseName;
                  }
                  if (showAuthor && last != null && !last.isSystem && last.user?.id != me) {
                    final first = (last.user?.name ?? '').split(' ').first;
                    if (first.isNotEmpty) preview = '$first: $preview';
                  }
                  if (prefix != null) {
                    preview = preview.isEmpty ? prefix! : '${prefix!} · $preview';
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: c.text,
                              ),
                            ),
                          ),
                          if (last != null)
                            Text(
                              listTime(last.createdAt.toLocal(), DateTime.now()),
                              style: TextStyle(fontSize: 12, color: c.textMuted),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              preview.isEmpty ? context.l10n.chatNoMessagesYet : preview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, color: c.textMuted),
                            ),
                          ),
                          if (state != null)
                            StreamBuilder<int>(
                              stream: state.unreadCountStream,
                              initialData: state.unreadCount,
                              builder: (context, unread) {
                                final n = unread.data ?? 0;
                                if (n == 0) return const SizedBox.shrink();
                                return Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  constraints: const BoxConstraints(minWidth: 20),
                                  height: 20,
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: c.gold,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    n > 99 ? '99+' : '$n',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: c.onAccent,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
