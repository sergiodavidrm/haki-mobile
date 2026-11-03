import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../l10n/l10n.dart';
import '../data/chat_message.dart';
import '../data/chat_repository.dart';
import '../providers/chat_providers.dart';
import 'chat_widgets.dart';
import 'group_widgets.dart';

/// Busca el grupo por su canal de Stream entre los del atleta.
GroupChat? _groupOf(List<GroupChat>? groups, String channelId) =>
    groups?.where((g) => g.channel.id == channelId).firstOrNull;

/// Conversación de un grupo (mockup "App · Grupo abierto" / "solo
/// reacciones"). Si el coach no deja escribir, en vez de la caja de texto va
/// un aviso y el atleta reacciona manteniendo presionado.
class GroupChatScreen extends ConsumerWidget {
  const GroupChatScreen({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(chatGroupsProvider);
    final group = _groupOf(groups.value, channelId);

    if (group == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: groups.isLoading
              ? const CircularProgressIndicator()
              : Text(
                  context.l10n.chatGroupGone,
                  style: TextStyle(color: context.colors.textMuted),
                ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: StreamChannel(
          channel: group.channel,
          child: StreamBuilder<Map<String, Object?>>(
            stream: group.channel.extraDataStream,
            builder: (context, _) => Column(
              children: [
                _GroupHeader(group: group),
                Expanded(child: _GroupMessages(group: group)),
                if (group.athletesCanWrite)
                  ChatComposer(
                    hint: context.l10n.chatGroupHint,
                    onSend: (text) =>
                        group.channel.sendMessage(Message(text: text)),
                  )
                else
                  _LockedNotice(coachName: group.group.coachName),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final GroupChat group;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final count = group.channel.memberCount ?? group.channel.state?.members.length ?? 0;
    final subtitle = group.athletesCanWrite
        ? context.l10n.chatGroupMembers(count)
        : '${context.l10n.chatGroupMembers(count)} · '
              '${context.l10n.chatGroupOnlyCoachWrites(group.group.coachName)}';
    void openInfo() => context.push(Routes.chatGroupInfo(group.channel.id!));

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: context.l10n.commonBack,
            onPressed: () => context.pop(),
            icon: Icon(Icons.chevron_left, color: c.text),
          ),
          Expanded(
            child: InkWell(
              onTap: openInfo,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    GroupAvatar(
                      announcements: !group.athletesCanWrite,
                      size: 38,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: c.text,
                            ),
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: c.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: context.l10n.chatGroupInfo,
            onPressed: openInfo,
            icon: Icon(Icons.info_outline, color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _LockedNotice extends StatelessWidget {
  const _LockedNotice({required this.coachName});

  final String coachName;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: c.navBar,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_outline, size: 16, color: c.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.chatGroupLocked(coachName),
              style: TextStyle(fontSize: 13, height: 1.45, color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupMessages extends ConsumerStatefulWidget {
  const _GroupMessages({required this.group});

  final GroupChat group;

  @override
  ConsumerState<_GroupMessages> createState() => _GroupMessagesState();
}

class _GroupMessagesState extends ConsumerState<_GroupMessages> {
  final _list = MessageListController();
  var _loadingMore = false;

  Future<void> _loadMore() async {
    final paginate = _list.paginateData;
    if (_loadingMore || paginate == null) return;
    _loadingMore = true;
    try {
      await paginate();
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> _markRead(Channel channel) async {
    if ((channel.state?.unreadCount ?? 0) == 0) return;
    try {
      await channel.markRead();
    } catch (_) {
      // sin red: se marca la próxima vez
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final channel = widget.group.channel;
    final me = channel.client.state.currentUser?.id;
    final coachId = widget.group.group.coachStreamId;

    return MessageListCore(
      messageListController: _list,
      loadingBuilder: (_) => const Center(child: CircularProgressIndicator()),
      errorBuilder: (_, _) => Center(
        child: Text(
          context.l10n.chatMessagesError,
          style: TextStyle(color: c.textMuted),
        ),
      ),
      emptyBuilder: (_) => Center(
        child: Text(
          context.l10n.chatGroupEmpty,
          style: TextStyle(color: c.textMuted),
        ),
      ),
      messageListBuilder: (context, messages) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => unawaited(_markRead(channel)),
        );
        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.extentAfter < 400) unawaited(_loadMore());
            return false;
          },
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final m = messages[i];
              final at = m.createdAt.toLocal();
              final older = i + 1 < messages.length
                  ? messages[i + 1].createdAt.toLocal()
                  : null;
              final mine = m.user?.id == me;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (older == null || !sameDay(older, at))
                    DaySeparator(label: daySeparator(at, DateTime.now())),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: m.isSystem
                        ? SystemNotice(text: m.text ?? '')
                        : TextBubble(
                            text: m.text ?? '',
                            mine: mine,
                            authorName: m.user?.id == coachId
                                ? '${m.user?.name ?? ''} · ${context.l10n.chatGroupCoachTag}'
                                : m.user?.name,
                            showAuthorName: true,
                            time: at,
                            failed: m.state.isFailed,
                            onRetry: () => unawaited(channel.retryMessage(m)),
                            onLongPress: () =>
                                unawaited(showReactionPicker(context, channel, m)),
                            below: ReactionChips(message: m, channel: channel),
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// Info del grupo (mockup "App · Info del grupo"): integrantes y salir.
class GroupInfoScreen extends ConsumerWidget {
  const GroupInfoScreen({super.key, required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final group = _groupOf(ref.watch(chatGroupsProvider).value, channelId);
    if (group == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            context.l10n.chatGroupGone,
            style: TextStyle(color: c.textMuted),
          ),
        ),
      );
    }
    final me = group.channel.client.state.currentUser?.id;
    final coachId = group.group.coachStreamId;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.chatGroupInfo)),
      body: StreamBuilder<List<Member>>(
        stream: group.channel.state?.membersStream,
        initialData: group.channel.state?.members ?? const [],
        builder: (context, snap) {
          // Coach primero, después vos y el resto por nombre
          final members = [...?snap.data]
            ..sort((a, b) {
              int rank(Member m) => m.userId == coachId ? 0 : m.userId == me ? 1 : 2;
              final r = rank(a).compareTo(rank(b));
              return r != 0 ? r : (a.user?.name ?? '').compareTo(b.user?.name ?? '');
            });
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Center(
                child: GroupAvatar(
                  announcements: !group.athletesCanWrite,
                  size: 72,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                group.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.chatGroupOf(group.group.coachName, members.length),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: c.textMuted),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: c.turquoiseSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    group.athletesCanWrite
                        ? context.l10n.chatGroupEveryoneWrites
                        : context.l10n.chatGroupOnlyCoachWrites(group.group.coachName),
                    style: TextStyle(fontSize: 12, color: c.turquoise),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.chatGroupMembersTitle(members.length).toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .8,
                  color: c.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: c.border),
                ),
                child: Column(
                  children: [
                    for (final m in members)
                      ListTile(
                        leading: CoachAvatar(name: m.user?.name ?? '', size: 36),
                        title: Text(
                          m.userId == me ? context.l10n.chatGroupYou : (m.user?.name ?? ''),
                          style: TextStyle(fontSize: 14, color: c.text),
                        ),
                        trailing: m.userId == coachId
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: c.goldSurface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  context.l10n.chatGroupCoachTag,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: c.goldBright,
                                  ),
                                ),
                              )
                            : null,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: c.border),
                ),
                child: ListTile(
                  leading: Icon(Icons.logout, color: c.danger),
                  title: Text(
                    context.l10n.chatGroupLeave,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.danger,
                    ),
                  ),
                  onTap: () => unawaited(_confirmLeave(context, ref, group)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Hoja "¿Salir de …?" (mockup "App · Salir del grupo").
Future<void> _confirmLeave(BuildContext context, WidgetRef ref, GroupChat group) async {
  final c = context.colors;
  final coach = group.group.coachName;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: c.surface,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.chatGroupLeaveTitle(group.name),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.text),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.chatGroupLeaveBody(coach),
              style: TextStyle(fontSize: 14, height: 1.5, color: c.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.chatGroupLeaveKeep(coach),
              style: TextStyle(fontSize: 13, color: c.textMuted),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: OutlinedButton.styleFrom(
                foregroundColor: c.danger,
                side: BorderSide(color: c.danger),
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(context.l10n.chatGroupLeave),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: Text(context.l10n.commonCancel),
            ),
          ],
        ),
      ),
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    await ref.read(chatRepositoryProvider).leaveGroup(group.group.id);
    ref.invalidate(chatGroupsProvider);
    if (context.mounted) context.go(Routes.chat);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chatGroupLeaveError)),
      );
    }
  }
}
