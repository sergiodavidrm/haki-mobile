import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../../../core/theme/haki_colors.dart';
import '../../body/providers/body_providers.dart';
import '../data/chat_message.dart';
import 'chat_widgets.dart';

// Feedback por ejercicio (coach con exerciseFeedbackEnabled): el hilo de la
// tarjeta de videos. Igual al mockup "Hilo": tus videos + nota arriba, las
// respuestas y la caja para contestarle al coach (van con parent_id).

/// Fila al pie de la tarjeta: la última respuesta y "N respuestas · Ver
/// feedback", o "Esperando feedback de X" si el coach todavía no respondió.
class FeedbackRow extends StatefulWidget {
  const FeedbackRow({
    super.key,
    required this.parent,
    required this.coachName,
    required this.onOpen,
  });

  final Message parent;
  final String coachName;
  final VoidCallback onOpen;

  @override
  State<FeedbackRow> createState() => _FeedbackRowState();
}

class _FeedbackRowState extends State<FeedbackRow> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // La última respuesta, para mostrarla en la tarjeta
    final channel = StreamChannel.of(context);
    final loaded = channel.channel.state?.threads[widget.parent.id];
    if ((widget.parent.replyCount ?? 0) > 0 && loaded == null) {
      unawaited(
        channel.getReplies(widget.parent.id, limit: 1).catchError((_) {}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final channel = StreamChannel.of(context).channel;
    final me = channel.client.state.currentUser?.id;
    final count = widget.parent.replyCount ?? 0;
    final border = BoxDecoration(
      border: Border(top: BorderSide(color: c.goldBorder)),
    );

    if (count == 0) {
      return Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: border,
        child: InkWell(
          onTap: widget.onOpen,
          child: Row(
            children: [
              Icon(Icons.schedule, size: 14, color: c.textMuted),
              const SizedBox(width: 8),
              Text(
                'Esperando feedback de ${widget.coachName}',
                style: TextStyle(fontSize: 12, color: c.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<Map<String, List<Message>>>(
      stream: channel.state?.threadsStream,
      initialData: channel.state?.threads,
      builder: (context, snap) {
        final last = snap.data?[widget.parent.id]?.lastOrNull;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (last != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: border,
                child: Row(
                  children: [
                    Text(
                      '${last.user?.id == me ? 'Vos' : (last.user?.name ?? widget.coachName)}: ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: last.user?.id == me ? c.goldBright : c.turquoise,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        last.text ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: c.text),
                      ),
                    ),
                  ],
                ),
              ),
            InkWell(
              onTap: widget.onOpen,
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: border,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$count ${count == 1 ? 'respuesta' : 'respuestas'} · Ver feedback',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: c.goldBright,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 18, color: c.goldBright),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Pantalla del hilo. Necesita un [StreamChannel] arriba (quien la abre lo
/// pone: la ruta nueva no hereda el del tab Chat).
class FeedbackThreadScreen extends ConsumerStatefulWidget {
  const FeedbackThreadScreen({
    super.key,
    required this.parent,
    required this.coachName,
  });

  final Message parent;
  final String coachName;

  @override
  ConsumerState<FeedbackThreadScreen> createState() =>
      _FeedbackThreadScreenState();
}

class _FeedbackThreadScreenState extends ConsumerState<FeedbackThreadScreen> {
  final _list = MessageListController();
  var _loadingMore = false;

  /// Respuestas más viejas (carga de a 20) al acercarse arriba.
  Future<void> _loadMore() async {
    final paginate = _list.paginateData;
    if (_loadingMore || paginate == null) return;
    _loadingMore = true;
    try {
      await paginate();
    } catch (_) {
      // sin red: se reintenta al volver a scrollear
    } finally {
      _loadingMore = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final channel = StreamChannel.of(context).channel;
    final me = channel.client.state.currentUser?.id;
    final unit = ref.watch(bodyWeightUnitProvider);
    final card = VideoCard.of(widget.parent);
    final sent = widget.parent.createdAt.toLocal();
    final title = card?.exerciseName ?? 'Feedback';
    final subtitle = [
      'Feedback',
      if (card?.weekNumber != null) 'Semana ${card!.weekNumber}',
      if (card?.dayNumber != null) 'Día ${card!.dayNumber}',
      shortDate(sent),
    ].join(' · ');

    Widget videos() => Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'TUS VIDEOS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: c.textMuted,
                  ),
                ),
              ),
              Text(
                '${shortDate(sent)} · ${timeOf(sent)}',
                style: TextStyle(fontSize: 12, color: c.textMuted),
              ),
            ],
          ),
          if (card != null && card.videos.isNotEmpty) ...[
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.25,
              children: [
                for (final v in card.videos)
                  VideoThumb(
                    video: v,
                    label: v.label(unit),
                    title: '${card.exerciseName} · Serie ${v.setNumber}',
                  ),
              ],
            ),
          ],
          if (card?.note != null) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: c.border),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Tu nota: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.goldBright,
                    ),
                  ),
                  TextSpan(text: card!.note),
                ],
              ),
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: c.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );

    Widget reply(Message m) {
      final mine = m.user?.id == me;
      final at = m.createdAt.toLocal();
      final who = mine ? 'Vos' : (m.user?.name ?? widget.coachName);
      final head = Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: who,
              style: TextStyle(fontWeight: FontWeight.w700, color: c.text),
            ),
            TextSpan(text: ' · ${shortDate(at)} ${timeOf(at)}'),
          ],
        ),
        style: TextStyle(fontSize: 12, color: c.textMuted),
      );
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: mine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.stretch,
          children: [
            if (mine)
              head
            else
              Padding(padding: const EdgeInsets.only(left: 42), child: head),
            const SizedBox(height: 4),
            TextBubble(
              text: m.text ?? '',
              mine: mine,
              authorName: who,
              time: at,
              showTime: false,
              failed: m.state.isFailed,
              onRetry: () => unawaited(channel.retryMessage(m)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: c.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Volver',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.chevron_left, size: 28, color: c.text),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: c.text,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 12, color: c.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MessageListCore(
                parentMessage: widget.parent,
                messageListController: _list,
                loadingBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                errorBuilder: (_, _) => Center(
                  child: Text(
                    'No se pudieron cargar las respuestas.',
                    style: TextStyle(color: c.textMuted),
                  ),
                ),
                emptyBuilder: (_) => ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    videos(),
                    const SizedBox(height: 24),
                    Icon(Icons.schedule, size: 28, color: c.turquoise),
                    const SizedBox(height: 8),
                    Text(
                      'Tu coach todavía no lo revisó',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Si querés contarle algo del ejercicio, escribilo acá.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: c.textMuted),
                    ),
                  ],
                ),
                // Invertida: index 0 = la respuesta más nueva; al final
                // (arriba) la tarjeta con los videos y el separador
                messageListBuilder: (context, replies) {
                  final total = (widget.parent.replyCount ?? 0) > replies.length
                      ? widget.parent.replyCount!
                      : replies.length;
                  return NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (replies.length < total &&
                          n.metrics.extentAfter < 300) {
                        unawaited(_loadMore());
                      }
                      return false;
                    },
                    child: ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: replies.length + 1,
                      itemBuilder: (context, i) {
                        if (i < replies.length) return reply(replies[i]);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            videos(),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                children: [
                                  Expanded(child: Divider(color: c.border)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      '$total ${total == 1 ? 'respuesta' : 'respuestas'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: c.textMuted,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: c.border)),
                                ],
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
              hint: 'Responder a ${widget.coachName}…',
              onSend: (text) => channel.sendMessage(
                Message(text: text, parentId: widget.parent.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
