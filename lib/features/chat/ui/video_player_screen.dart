import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../l10n/l10n.dart';

/// Video de una serie a pantalla completa (desde Cloudinary). Tocar =
/// play/pausa.
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final _player = VideoPlayerController.networkUrl(Uri.parse(widget.url));
  var _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    try {
      await _player.initialize();
      await _player.setLooping(true);
      await _player.play();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
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
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
      ),
      body: SafeArea(
        child: _failed
            ? Center(
                child: Text(
                  context.l10n.videoLoadError,
                  style: TextStyle(color: c.textMuted),
                ),
              )
            : !_player.value.isInitialized
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _player.value.isPlaying
                            ? unawaited(_player.pause())
                            : unawaited(_player.play());
                      }),
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
                                    : Icon(
                                        Icons.play_arrow,
                                        size: 56,
                                        color: c.text,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: VideoProgressIndicator(
                      _player,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: c.gold,
                        bufferedColor: c.border,
                        backgroundColor: c.surfaceHigh,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
