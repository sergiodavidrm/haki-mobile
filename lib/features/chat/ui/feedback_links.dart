import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../../../core/theme/haki_colors.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../data/chat_message.dart';
import '../providers/chat_providers.dart';
import '../providers/feedback_providers.dart';
import 'feedback_thread_screen.dart';
import '../../../l10n/l10n.dart';

// Links al hilo de feedback fuera del chat (mockup: Detalle de ejercicio y
// Sesión pasada). Solo si el coach usa feedback por ejercicio; sin red o
// mientras carga no muestran nada.

/// Abre el hilo de [parent] (la ruta no hereda el StreamChannel del tab Chat).
Future<void> openFeedbackThread(
  BuildContext context,
  WidgetRef ref,
  Message parent,
) async {
  final channel = await ref.read(generalChannelProvider.future);
  if (!context.mounted) return;
  final coach = ref.read(authMeProvider).value?.coachName ?? context.l10n.yourCoach;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => StreamChannel(
        channel: channel,
        child: FeedbackThreadScreen(parent: parent, coachName: coach),
      ),
    ),
  );
  // Puede haber respondido
  ref.invalidate(feedbackSummaryProvider(parent.id));
}

/// Tarjeta turquesa "Feedback de tus videos · Diego · 26 sep · 3 mensajes ·
/// Ver", o punteada "Tu video todavía no tiene feedback". [compact] = chip
/// para el historial ("2 videos · 3 mensajes de feedback").
class FeedbackLink extends ConsumerWidget {
  const FeedbackLink({
    super.key,
    required this.messageId,
    this.title,
    this.compact = false,
    this.videoCount = 0,
    this.margin = EdgeInsets.zero,
  });

  final String messageId;

  /// Espacio alrededor, solo cuando se muestra (sin feedback no ocupa lugar).
  final EdgeInsets margin;
  /// null = 'Feedback de tus videos'.
  final String? title;
  final bool compact;
  final int videoCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final link = _link(context, ref);
    if (link == null) return const SizedBox.shrink();
    return Padding(padding: margin, child: link);
  }

  Widget? _link(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final me = ref.watch(authMeProvider).value;
    if (!(me?.exerciseFeedbackEnabled ?? false)) return null;
    final summary = ref.watch(feedbackSummaryProvider(messageId)).value;
    if (summary == null) return null;

    final l = context.l10n;
    final title = this.title ?? l.feedbackYourVideos;
    final coach = me?.coachName ?? l.yourCoach;
    final count = summary.count;
    void open() => unawaited(openFeedbackThread(context, ref, summary.parent));

    if (compact) {
      final videos = videoCount == 0
          ? null
          : l.videosCount(videoCount);
      final text = count == 0
          ? [videos, l.feedbackNoneYet].nonNulls.join(' · ')
          : [videos, l.feedbackMessagesCount(count)].nonNulls.join(' · ');
      return Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: c.turquoiseSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: c.turquoiseBorder),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: open,
            child: Container(
              constraints: const BoxConstraints(minHeight: 32),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 14, color: c.turquoise),
                  const SizedBox(width: 6),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: c.turquoise,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (count == 0) {
      return Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: open,
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, size: 14, color: c.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.feedbackVideoNone,
                    style: TextStyle(fontSize: 12, color: c.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final last = summary.last;
    final who = last == null || last.user?.id == summary.parent.user?.id
        ? null
        : (last.user?.name ?? coach);
    final subtitle = [
      ?who,
      if (last != null) shortDate(last.createdAt.toLocal()),
      l.messagesCount(count),
    ].join(' · ');

    return Semantics(
      button: true,
      label: '$title: $subtitle. ${l.feedbackSeeThread}',
      excludeSemantics: true,
      child: Material(
        color: c.turquoiseSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: c.turquoiseBorder),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: open,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.videocam_outlined,
                            size: 15,
                            color: c.turquoise,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: c.turquoise,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: c.textMuted),
                      ),
                    ],
                  ),
                ),
                Text(
                  l.see,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.turquoise,
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: c.turquoise),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// [FeedbackLink] de la Sesión: el id viene del detalle del programa o, si la
/// tarjeta se publicó durante este entreno, de los mensajes del chat. Sin
/// tarjeta no ocupa lugar.
class SessionFeedbackLink extends ConsumerWidget {
  const SessionFeedbackLink({
    super.key,
    required this.dayExerciseId,
    this.streamMessageId,
  });

  final String dayExerciseId;
  final String? streamMessageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id =
        streamMessageId ?? ref.watch(cardIdForProvider(dayExerciseId)).value;
    if (id == null) return const SizedBox.shrink();
    return FeedbackLink(messageId: id, margin: const EdgeInsets.only(top: 10));
  }
}
