import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../../body/providers/body_providers.dart';
import '../data/chat_message.dart';
import '../providers/chat_providers.dart';
import '../providers/chat_push.dart';
import 'chat_widgets.dart';
import 'feedback_thread_screen.dart';
import '../../../l10n/l10n.dart';

// Tab Chat: canal general con el coach (Stream). Mensajes de texto, tarjetas
// de videos de los ejercicios (las publica la API) y respuestas del coach
// citando una tarjeta. Necesita red.
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final channel = ref.watch(generalChannelProvider);
    // Primera vez en el Chat: pedir permiso de notificaciones (una sola vez)
    unawaited(ref.read(chatPushProvider).askPermissionOnce());
    final coach = ref.watch(authMeProvider).value?.coachName ?? context.l10n.yourCoach;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(coachName: coach),
            Expanded(
              child: switch (channel) {
                AsyncData(:final value) => StreamChannel(
                  channel: value,
                  child: _ChatView(coachName: coach),
                ),
                AsyncError() => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.chatOpenError,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: c.textMuted),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(generalChannelProvider),
                          style: TextButton.styleFrom(foregroundColor: c.gold),
                          child: Text(context.l10n.commonRetry),
                        ),
                      ],
                    ),
                  ),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.coachName});

  final String coachName;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          CoachAvatar(name: coachName, size: 40),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coachName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: c.text,
                ),
              ),
              Text(
                context.l10n.yourCoach,
                style: TextStyle(fontSize: 12, color: c.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatView extends ConsumerStatefulWidget {
  const _ChatView({required this.coachName});

  final String coachName;

  @override
  ConsumerState<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<_ChatView> {
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

  /// Leer el chat abierto = marcarlo leído (el coach ve el visto).
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
    final channel = StreamChannel.of(context).channel;
    final me = channel.client.state.currentUser?.id;
    final unit = ref.watch(bodyWeightUnitProvider);

    return Column(
      children: [
        Expanded(
          child: MessageListCore(
            messageListController: _list,
            loadingBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            errorBuilder: (_, _) => Center(
              child: Text(
                context.l10n.chatMessagesError,
                style: TextStyle(color: c.textMuted),
              ),
            ),
            emptyBuilder: (_) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  context.l10n.chatEmpty(widget.coachName),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.textMuted, height: 1.4),
                ),
              ),
            ),
            messageListBuilder: (context, messages) {
              // Solo si el tab Chat se ve: los tabs quedan vivos de fondo
              // (TickerMode apagado) y si no marcaría leído lo que llega
              // mientras el atleta está en otro tab (el badge nunca subía)
              if (TickerMode.valuesOf(context).enabled) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => unawaited(_markRead(channel)),
                );
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  // reverse: el "final" de la lista son los más viejos
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
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (older == null || !sameDay(older, at))
                          DaySeparator(label: daySeparator(at, DateTime.now())),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _message(
                            m,
                            mine: m.user?.id == me,
                            unit: unit,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
        ChatComposer(
          hint: context.l10n.chatMessageHint,
          onSend: (text) => channel.sendMessage(Message(text: text)),
        ),
      ],
    );
  }

  Widget _message(Message m, {required bool mine, required WeightUnit unit}) {
    final channel = StreamChannel.of(context).channel;
    final card = VideoCard.of(m);
    if (card != null) {
      final threads =
          ref.watch(authMeProvider).value?.exerciseFeedbackEnabled ?? false;
      return Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: VideoCardBubble(
          card: card,
          unit: unit,
          footer: threads
              ? FeedbackRow(
                  parent: m,
                  coachName: widget.coachName,
                  onOpen: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => StreamChannel(
                        channel: channel,
                        child: FeedbackThreadScreen(
                          parent: m,
                          coachName: widget.coachName,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        ),
      );
    }
    final quoted = m.quotedMessage;
    final quotedCard = quoted == null ? null : VideoCard.of(quoted);
    return TextBubble(
      text: m.text ?? '',
      mine: mine,
      authorName: mine ? null : (m.user?.name ?? widget.coachName),
      time: m.createdAt.toLocal(),
      quote: quotedCard != null
          ? [quotedCard.exerciseName, ?quotedCard.dayLabel].join(' · ')
          : quoted?.text,
      failed: m.state.isFailed,
      onRetry: () => unawaited(channel.retryMessage(m)),
    );
  }
}
