import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/haki_colors.dart';
import '../data/video_files.dart';
import '../data/video_trim.dart';
import '../../../l10n/l10n.dart';

// Recortar el video de una serie antes de mandarlo a la cola (como WhatsApp):
// se ve y se reproduce en loop solo el tramo elegido; al mover una manija el
// video salta a ese punto. Devuelve el TrimRange elegido o null si cancela.
class VideoTrimScreen extends StatefulWidget {
  const VideoTrimScreen({super.key, required this.path});

  final String path;

  @override
  State<VideoTrimScreen> createState() => _VideoTrimScreenState();
}

class _VideoTrimScreenState extends State<VideoTrimScreen> {
  static const _thumbCount = 8;

  late final _player = VideoPlayerController.file(File(widget.path));
  var _ready = false;
  var _failed = false;
  var _totalMs = 0;
  var _range = const TrimRange(0, 0);
  final _thumbs = <Uint8List?>[];

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    try {
      await _player.initialize();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    _totalMs = _player.value.duration.inMilliseconds;
    _range = TrimRange.initial(_totalMs);
    _player.addListener(_loop);
    if (!mounted) return;
    setState(() => _ready = true);
    unawaited(_player.play());
    await _loadThumbs();
  }

  /// Reproduce solo el tramo elegido, en loop.
  void _loop() {
    final pos = _player.value.position.inMilliseconds;
    if (_player.value.isPlaying && pos >= _range.endMs) {
      unawaited(_player.seekTo(Duration(milliseconds: _range.startMs)));
    }
  }

  /// De a una: el plugin no está pensado para pedidos en paralelo.
  Future<void> _loadThumbs() async {
    for (var i = 0; i < _thumbCount; i++) {
      final ms = (_totalMs * (i + 0.5) / _thumbCount).round();
      Uint8List? bytes;
      try {
        bytes = await VideoCompress.getByteThumbnail(
          widget.path,
          quality: 30,
          position: ms,
        );
      } catch (_) {
        bytes = null;
      }
      if (!mounted) return;
      setState(() => _thumbs.add(bytes));
    }
  }

  void _move(TrimRange r, {required bool start}) {
    if (r.startMs == _range.startMs && r.endMs == _range.endMs) return;
    setState(() => _range = r);
    unawaited(
      _player.seekTo(Duration(milliseconds: start ? r.startMs : r.endMs)),
    );
  }

  void _togglePlay() {
    if (_player.value.isPlaying) {
      unawaited(_player.pause());
    } else {
      final pos = _player.value.position.inMilliseconds;
      if (pos < _range.startMs || pos >= _range.endMs) {
        unawaited(_player.seekTo(Duration(milliseconds: _range.startMs)));
      }
      unawaited(_player.play());
    }
    setState(() {});
  }

  @override
  void dispose() {
    _player.removeListener(_loop);
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        title: Text(context.l10n.trimTitle),
      ),
      body: SafeArea(
        child: _failed
            ? Center(
                child: Text(
                  context.l10n.trimOpenError,
                  style: TextStyle(color: c.textMuted),
                ),
              )
            : !_ready
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(child: _preview(c)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _TrimStrip(
                      thumbs: _thumbs,
                      thumbCount: _thumbCount,
                      totalMs: _totalMs,
                      range: _range,
                      onStart: (ms) => _move(_range.withStart(ms), start: true),
                      onEnd: (ms) =>
                          _move(_range.withEnd(ms, _totalMs), start: false),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${clockOf(_range.startMs)} – ${clockOf(_range.endMs)}'
                    ' · ${(_range.lengthMs / 1000).round()} s',
                    style: TextStyle(fontSize: 14, color: c.textSecondary),
                  ),
                  if (_totalMs > maxVideoSeconds * 1000)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        context.l10n.trimMax(maxVideoSeconds),
                        style: TextStyle(fontSize: 12, color: c.textMuted),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              foregroundColor: c.text,
                              side: BorderSide(color: c.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(context.l10n.commonCancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.pop(context, _range),
                            child: Text(context.l10n.trimUse),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _preview(HakiColors c) => GestureDetector(
    onTap: _togglePlay,
    child: Center(
      child: AspectRatio(
        aspectRatio: _player.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_player),
            ValueListenableBuilder(
              valueListenable: _player,
              builder: (_, v, _) => v.isPlaying
                  ? const SizedBox.shrink()
                  : Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: c.background.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.play_arrow, size: 40, color: c.text),
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Tira de miniaturas con dos manijas doradas (inicio y fin); fuera del tramo
/// queda oscurecido. Al empezar a arrastrar se toma la manija más cercana al
/// dedo y se sigue su posición (no los deltas, que con el salto de a 1 s se
/// perderían).
class _TrimStrip extends StatefulWidget {
  const _TrimStrip({
    required this.thumbs,
    required this.thumbCount,
    required this.totalMs,
    required this.range,
    required this.onStart,
    required this.onEnd,
  });

  final List<Uint8List?> thumbs;
  final int thumbCount;
  final int totalMs;
  final TrimRange range;
  final ValueChanged<int> onStart;
  final ValueChanged<int> onEnd;

  @override
  State<_TrimStrip> createState() => _TrimStripState();
}

class _TrimStripState extends State<_TrimStrip> {
  static const _height = 56.0;
  static const _handle = 14.0;

  /// true = arrastrando el inicio, false = el fin.
  bool? _draggingStart;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth - _handle * 2;
        double x(int ms) => _handle + w * ms / widget.totalMs;
        int ms(double dx) => ((dx - _handle) / w * widget.totalMs).round();
        final left = x(widget.range.startMs);
        final right = x(widget.range.endMs);
        final shade = c.background.withValues(alpha: 0.7);

        void drag(double dx) {
          final start = _draggingStart;
          if (start == null) return;
          start ? widget.onStart(ms(dx)) : widget.onEnd(ms(dx));
        }

        Widget handle(bool isStart) => Positioned(
          left: isStart ? left - _handle : right,
          top: 0,
          bottom: 0,
          width: _handle,
          child: Container(
            decoration: BoxDecoration(
              color: c.gold,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(isStart ? 6 : 0),
                right: Radius.circular(isStart ? 0 : 6),
              ),
            ),
            child: Icon(
              isStart ? Icons.chevron_left : Icons.chevron_right,
              size: 14,
              color: c.onAccent,
            ),
          ),
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (d) {
            final dx = d.localPosition.dx;
            _draggingStart = (dx - left).abs() <= (dx - right).abs();
            drag(dx);
          },
          onHorizontalDragUpdate: (d) => drag(d.localPosition.dx),
          onHorizontalDragEnd: (_) => _draggingStart = null,
          child: SizedBox(
            height: _height,
            child: Stack(
              children: [
                Positioned.fill(
                  left: _handle,
                  right: _handle,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      children: [
                        for (var i = 0; i < widget.thumbCount; i++)
                          Expanded(
                            child:
                                i < widget.thumbs.length &&
                                    widget.thumbs[i] != null
                                ? Image.memory(
                                    widget.thumbs[i]!,
                                    fit: BoxFit.cover,
                                    height: _height,
                                    gaplessPlayback: true,
                                  )
                                : ColoredBox(color: c.surfaceHigh),
                          ),
                      ],
                    ),
                  ),
                ),
                // Fuera del tramo
                Positioned(
                  left: _handle,
                  width: left - _handle,
                  top: 0,
                  bottom: 0,
                  child: ColoredBox(color: shade),
                ),
                Positioned(
                  left: right,
                  right: _handle,
                  top: 0,
                  bottom: 0,
                  child: ColoredBox(color: shade),
                ),
                // Borde del tramo
                Positioned(
                  left: left,
                  width: right - left,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(color: c.gold, width: 3),
                      ),
                    ),
                  ),
                ),
                handle(true),
                handle(false),
              ],
            ),
          ),
        );
      },
    );
  }
}
