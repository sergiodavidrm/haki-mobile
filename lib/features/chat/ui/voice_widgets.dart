import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../l10n/l10n.dart';
import '../data/voice.dart';
import '../providers/voice_player.dart';

/// Contenido de una burbuja con audio (mockup "App · Chat con audios"):
/// play/pausa, forma de onda con lo escuchado pintado (tocarla salta), la
/// duración (o "0:07 / 0:19" mientras suena), la velocidad y el punto
/// turquesa si es de otro y todavía no lo escuché.
class VoiceMessageView extends ConsumerWidget {
  const VoiceMessageView({
    super.key,
    required this.voice,
    required this.mine,
    this.width = 220,
  });

  final VoiceInfo voice;
  final bool mine;

  /// double.infinity = todo el ancho (revisar antes de mandar).
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final p = ref.watch(voicePlaybackProvider);
    final loaded = p.id == voice.id;
    final playing = loaded && p.playing;
    final progress = !loaded || voice.duration == Duration.zero
        ? 0.0
        : (p.position.inMilliseconds / voice.duration.inMilliseconds).clamp(
            0.0,
            1.0,
          );
    final unheard = !mine && !p.heard.contains(voice.id);
    final (button, onButton, waveOn, waveOff) = mine
        ? (c.gold, c.onAccent, c.goldBright, c.goldBorder)
        : (c.turquoise, c.onTurquoise, c.turquoise, c.track);

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: voice.playable
                    ? IconButton.filled(
                        tooltip: playing ? l.voicePause : l.voicePlay,
                        onPressed: () => unawaited(
                          ref.read(voicePlaybackProvider.notifier).toggle(voice),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: button,
                          foregroundColor: onButton,
                          padding: EdgeInsets.zero,
                        ),
                        icon: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 22,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: button,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: loaded
                      ? (d) {
                          final box = context.findRenderObject() as RenderBox?;
                          final w = (box?.size.width ?? 220) - 50;
                          unawaited(
                            ref
                                .read(voicePlaybackProvider.notifier)
                                .seek(voice, d.localPosition.dx / w),
                          );
                        }
                      : null,
                  child: SizedBox(
                    height: 30,
                    child: CustomPaint(
                      painter: WaveformPainter(
                        bars: voice.waveform,
                        progress: progress,
                        on: waveOn,
                        off: waveOff,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Row(
              children: [
                Text(
                  loaded && (playing || p.position > Duration.zero)
                      ? '${formatVoiceDuration(p.position)} / ${formatVoiceDuration(voice.duration)}'
                      : formatVoiceDuration(voice.duration),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: c.textMuted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (unheard) ...[
                  const SizedBox(width: 6),
                  Semantics(
                    label: l.voiceUnheard,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.turquoise,
                      ),
                    ),
                  ),
                ],
                if (loaded) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => unawaited(
                      ref.read(voicePlaybackProvider.notifier).cycleSpeed(),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: mine ? c.goldBorder : c.border),
                      ),
                      child: Text(
                        '${p.speed == p.speed.roundToDouble() ? p.speed.toInt() : p.speed}x',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Barras de la forma de onda: hasta [progress] en [on], el resto en [off].
class WaveformPainter extends CustomPainter {
  WaveformPainter({
    required this.bars,
    required this.on,
    required this.off,
    this.progress = 0,
    this.alignEnd = false,
  });

  final List<double> bars;
  final double progress;
  final Color on;
  final Color off;

  /// Grabando: las últimas muestras pegadas a la derecha.
  final bool alignEnd;

  @override
  void paint(Canvas canvas, Size size) {
    const barW = 3.0, gap = 2.0;
    final fit = ((size.width + gap) / (barW + gap)).floor();
    final data = alignEnd
        ? (bars.length > fit ? bars.sublist(bars.length - fit) : bars)
        : (bars.isEmpty ? List<double>.filled(fit, 0) : downsample(bars, fit));
    final start = alignEnd ? size.width - data.length * (barW + gap) : 0.0;
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < data.length; i++) {
      final h = 4 + data[i] * (size.height - 4);
      final x = start + i * (barW + gap);
      paint.color = !alignEnd && (i + .5) / data.length <= progress ? on : off;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, (size.height - h) / 2, barW, h),
          const Radius.circular(1.5),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter old) =>
      old.progress != progress || old.bars != bars || old.on != on;
}

/// Barra de grabación (mockup "App · Grabando"): reemplaza la caja de texto.
/// Graba al aparecer; 🗑 descarta, ⏸ termina y deja escucharlo antes de
/// mandar, la flecha manda. A los 2:00 para sola (queda para revisar).
class VoiceRecorderBar extends ConsumerStatefulWidget {
  const VoiceRecorderBar({
    super.key,
    required this.onCancel,
    required this.onSend,
  });

  /// [denied] = no dio permiso de micrófono.
  final void Function({bool denied}) onCancel;
  final void Function(Attachment attachment) onSend;

  @override
  ConsumerState<VoiceRecorderBar> createState() => _VoiceRecorderBarState();
}

class _VoiceRecorderBarState extends ConsumerState<VoiceRecorderBar> {
  final _recorder = AudioRecorder();
  final _samples = <double>[];
  StreamSubscription<Amplitude>? _amp;
  Timer? _tick;
  DateTime? _startedAt;
  Duration _elapsed = Duration.zero;
  String? _path;

  /// Terminó de grabar: se puede escuchar y mandar.
  bool _review = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    await ref.read(voicePlaybackProvider.notifier).stop();
    if (!await _recorder.hasPermission()) {
      widget.onCancel(denied: true);
      return;
    }
    final dir = await getTemporaryDirectory();
    _path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 64000,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: _path!,
    );
    _startedAt = DateTime.now();
    _amp = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((a) => setState(() => _samples.add(levelOf(a.current))));
    _tick = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final e = DateTime.now().difference(_startedAt!);
      if (e >= voiceMaxDuration) {
        unawaited(_finish());
      } else if (mounted) {
        setState(() => _elapsed = e);
      }
    });
  }

  Future<void> _finish() async {
    if (_review) return;
    _tick?.cancel();
    await _amp?.cancel();
    final end = DateTime.now();
    await _recorder.stop();
    if (!mounted) return;
    setState(() {
      _elapsed = _startedAt == null ? _elapsed : end.difference(_startedAt!);
      if (_elapsed > voiceMaxDuration) _elapsed = voiceMaxDuration;
      _review = true;
    });
  }

  Future<void> _discard() async {
    _tick?.cancel();
    await _amp?.cancel();
    await ref.read(voicePlaybackProvider.notifier).stop();
    await _recorder.cancel();
    _deleteFile();
    widget.onCancel();
  }

  Future<void> _send() async {
    if (!_review) await _finish();
    await ref.read(voicePlaybackProvider.notifier).stop();
    final path = _path;
    if (path == null || _elapsed < const Duration(milliseconds: 600)) {
      // Un toque sin querer: no se manda un audio vacío
      _deleteFile();
      widget.onCancel();
      return;
    }
    final file = File(path);
    widget.onSend(
      Attachment(
        type: AttachmentType.voiceRecording,
        file: AttachmentFile(
          size: await file.length(),
          path: path,
          name: 'audio.m4a',
        ),
        extraData: {
          'duration': _elapsed.inMilliseconds / 1000,
          'waveform_data': [
            for (final v in downsample(_samples)) double.parse(v.toStringAsFixed(2)),
          ],
        },
      ),
    );
  }

  void _deleteFile() {
    final p = _path;
    if (p == null) return;
    unawaited(File(p).delete().then((_) {}).catchError((_) {}));
  }

  @override
  void dispose() {
    _tick?.cancel();
    unawaited(_amp?.cancel());
    unawaited(_recorder.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final draft = VoiceInfo(
      id: 'draft:${_path ?? ''}',
      duration: _elapsed,
      waveform: downsample(_samples),
      localPath: _review ? _path : null,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: l.voiceDiscard,
                onPressed: () => unawaited(_discard()),
                icon: Icon(Icons.delete_outline, color: c.textMuted),
              ),
              Expanded(
                child: Container(
                  height: _review ? null : 44,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: _review ? 6 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: c.surfaceHigh,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: c.border),
                  ),
                  child: _review
                      ? VoiceMessageView(
                          voice: draft,
                          mine: true,
                          width: double.infinity,
                        )
                      : Row(
                          children: [
                            Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.danger,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatVoiceDuration(_elapsed),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: c.text,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 24,
                                child: CustomPaint(
                                  painter: WaveformPainter(
                                    bars: List.of(_samples),
                                    on: c.textSecondary,
                                    off: c.textSecondary,
                                    alignEnd: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (!_review) ...[
                const SizedBox(width: 6),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton.outlined(
                    tooltip: l.voiceStopToListen,
                    onPressed: () => unawaited(_finish()),
                    style: IconButton.styleFrom(
                      side: BorderSide(color: c.border),
                      foregroundColor: c.textSecondary,
                    ),
                    icon: const Icon(Icons.pause_rounded, size: 20),
                  ),
                ),
              ],
              const SizedBox(width: 6),
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton.filled(
                  tooltip: l.voiceSend,
                  onPressed: () => unawaited(_send()),
                  style: IconButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: c.onPrimary,
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                ),
              ),
            ],
          ),
          if (!_review) ...[
            const SizedBox(height: 6),
            Text(
              l.voiceHint,
              style: TextStyle(fontSize: 11, color: c.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
