import 'package:flutter/material.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../data/chat_message.dart';
import 'video_player_screen.dart';

// Piezas del chat (igual al mockup): avatar del coach, separador de día,
// burbujas, tarjeta de videos y caja de texto.

/// Inicial del coach sobre turquesa.
class CoachAvatar extends StatelessWidget {
  const CoachAvatar({super.key, required this.name, this.size = 32});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.turquoiseSurface,
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: c.turquoise,
        ),
      ),
    );
  }
}

class DaySeparator extends StatelessWidget {
  const DaySeparator({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: context.colors.textMuted),
    ),
  );
}

/// Mensaje de texto. Propio = dorado a la derecha; del coach = gris a la
/// izquierda con su inicial. [quote] = lo que cita (una tarjeta: "Jalón ·
/// Sem 2 · Día 3").
class TextBubble extends StatelessWidget {
  const TextBubble({
    super.key,
    required this.text,
    required this.mine,
    required this.time,
    this.authorName,
    this.quote,
    this.showTime = true,
    this.failed = false,
    this.onRetry,
  });

  final String text;
  final bool mine;
  final DateTime time;
  final String? authorName;
  final String? quote;

  /// false = la hora ya va en el encabezado (hilo de feedback).
  final bool showTime;
  final bool failed;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: mine ? c.goldSurface : c.surfaceHigh,
        border: Border.all(color: mine ? c.goldBorder : c.border),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(mine ? 16 : 4),
          topRight: Radius.circular(mine ? 4 : 16),
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(16),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, height: 1.45, color: c.text),
      ),
    );

    final column = Column(
      crossAxisAlignment: mine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (quote != null) ...[_Quote(text: quote!), const SizedBox(height: 4)],
        bubble,
        if (failed || showTime) const SizedBox(height: 4),
        if (failed)
          GestureDetector(
            onTap: onRetry,
            child: Text(
              'No se envió · Reintentar',
              style: TextStyle(fontSize: 11, color: c.goldBright),
            ),
          )
        else if (showTime)
          Text(
            timeOf(time),
            style: TextStyle(fontSize: 11, color: c.textMuted),
          ),
      ],
    );

    if (mine) return Align(alignment: Alignment.centerRight, child: column);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CoachAvatar(name: authorName ?? ''),
        const SizedBox(width: 10),
        Flexible(child: column),
      ],
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: c.gold, width: 3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.subdirectory_arrow_right, size: 13, color: c.textMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de videos de un ejercicio: nombre + semana/día, miniaturas por
/// serie (tocar = ver el video) y la nota del atleta.
class VideoCardBubble extends StatelessWidget {
  const VideoCardBubble({
    super.key,
    required this.card,
    required this.unit,
    this.footer,
  });

  final VideoCard card;
  final WeightUnit unit;

  /// Fila de feedback (respuestas del hilo), si el coach lo usa.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 300,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.goldSurface,
        border: Border.all(color: c.goldBorder),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    card.exerciseName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                ),
                if (card.dayLabel != null)
                  Text(
                    card.dayLabel!,
                    style: TextStyle(fontSize: 11, color: c.textMuted),
                  ),
              ],
            ),
          ),
          if (card.videos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.35,
                children: [
                  for (final v in card.videos)
                    VideoThumb(
                      video: v,
                      label: v.label(unit),
                      title: '${card.exerciseName} · Serie ${v.setNumber}',
                    ),
                ],
              ),
            ),
          if (card.note != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Text(
                card.note!,
                style: TextStyle(fontSize: 13, height: 1.4, color: c.text),
              ),
            ),
          ?footer,
        ],
      ),
    );
  }
}

/// Miniatura de una serie (tocar = ver el video) con "S3" y el peso/reps.
class VideoThumb extends StatelessWidget {
  const VideoThumb({
    super.key,
    required this.video,
    required this.label,
    required this.title,
  });

  final CardVideo video;
  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final thumb = cloudinaryThumb(video.url);
    return Semantics(
      button: true,
      label: 'Ver video de la serie ${video.setNumber}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => VideoPlayerScreen(url: video.url, title: title),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: c.surfaceHigh),
                    if (thumb != null)
                      Image.network(
                        thumb,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    Center(
                      child: Icon(Icons.play_arrow, size: 26, color: c.text),
                    ),
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: c.background.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'S${video.setNumber}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: c.text,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Caja de texto + botón dorado de enviar.
class ChatComposer extends StatefulWidget {
  const ChatComposer({super.key, required this.hint, required this.onSend});

  final String hint;
  final Future<Object?> Function(String text) onSend;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _send() {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    _text.clear();
    // Stream lo muestra al instante y reintenta; si falla queda marcado
    widget.onSend(text).catchError((_) => null);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _text,
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(fontSize: 14, color: c.text),
              decoration: InputDecoration(
                hintText: widget.hint,
                isDense: true,
                filled: true,
                fillColor: c.surfaceHigh,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(color: c.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(color: c.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(color: c.gold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton.filled(
              tooltip: 'Enviar',
              onPressed: _send,
              style: IconButton.styleFrom(
                backgroundColor: c.gold,
                foregroundColor: c.onAccent,
              ),
              icon: const Icon(Icons.send_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
