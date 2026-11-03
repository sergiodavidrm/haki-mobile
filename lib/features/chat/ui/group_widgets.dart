import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../l10n/l10n.dart';
import '../data/chat_message.dart';

// Piezas del chat grupal (mockup "Haki · Chat grupal"): ícono del grupo,
// avisos de sistema y reacciones.

/// Ícono turquesa del grupo. [announcements] = solo el coach escribe (megáfono).
class GroupAvatar extends StatelessWidget {
  const GroupAvatar({super.key, this.announcements = false, this.size = 44});

  final bool announcements;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.turquoiseSurface,
        borderRadius: BorderRadius.circular(size * 0.27),
        border: Border.all(color: c.turquoiseBorder),
      ),
      child: Icon(
        announcements ? Icons.campaign_outlined : Icons.groups_outlined,
        size: size * 0.48,
        color: c.turquoise,
      ),
    );
  }
}

/// "Andrés agregó a Laura", "Carlos salió del grupo"… (mensajes `system`).
class SystemNotice extends StatelessWidget {
  const SystemNotice({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: c.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: c.textMuted),
        ),
      ),
    );
  }
}

/// Reacciones de un mensaje; tocar una propia la saca, una ajena la suma.
class ReactionChips extends StatelessWidget {
  const ReactionChips({
    super.key,
    required this.message,
    required this.channel,
  });

  final Message message;
  final Channel channel;

  @override
  Widget build(BuildContext context) {
    final groups = message.reactionGroups ?? const {};
    if (groups.isEmpty) return const SizedBox.shrink();
    final c = context.colors;
    final mine = {for (final r in message.ownReactions ?? <Reaction>[]) r.type};
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final MapEntry(key: type, value: group) in groups.entries)
          if (group.count > 0)
            InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: () => unawaited(
                toggleReaction(channel, message, type, context: context),
              ),
              child: Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 9),
                decoration: BoxDecoration(
                  color: mine.contains(type) ? c.goldSurface : c.surfaceHigh,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: mine.contains(type) ? c.goldBorder : c.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      chatReactions[type] ?? type,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${group.count}',
                      style: TextStyle(
                        fontSize: 12,
                        color: mine.contains(type) ? c.goldBright : c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

/// Suma o saca la reacción propia [type]. Si falla avisa con un snackbar
/// (y el error queda en el log).
Future<void> toggleReaction(
  Channel channel,
  Message message,
  String type, {
  BuildContext? context,
}) async {
  final own = message.ownReactions?.where((r) => r.type == type).firstOrNull;
  final messenger = context != null && context.mounted
      ? ScaffoldMessenger.maybeOf(context)
      : null;
  final error = context != null && context.mounted ? context.l10n.chatReactError : null;
  try {
    if (own != null) {
      await channel.deleteReaction(message, own);
    } else {
      await channel.sendReaction(message, Reaction(type: type));
    }
  } catch (e) {
    debugPrint('Chat: no se pudo reaccionar ($e)');
    if (messenger != null && error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

/// Mantener presionado un mensaje: hoja con las reacciones.
Future<void> showReactionPicker(
  BuildContext context,
  Channel channel,
  Message message,
) async {
  final c = context.colors;
  final type = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: c.surface,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.chatReact,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final MapEntry(key: type, value: emoji) in chatReactions.entries)
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: IconButton(
                      tooltip: type,
                      onPressed: () => Navigator.of(context).pop(type),
                      icon: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (type != null && context.mounted) {
    await toggleReaction(channel, message, type, context: context);
  }
}
