import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/voice.dart';

part 'voice_player.g.dart';

/// Estado del reproductor de audios del chat (uno a la vez en toda la app).
class VoicePlaybackState {
  const VoicePlaybackState({
    this.id,
    this.playing = false,
    this.position = Duration.zero,
    this.speed = 1.0,
    this.heard = const {},
  });

  /// Audio cargado (el que suena o quedó en pausa).
  final String? id;
  final bool playing;
  final Duration position;
  final double speed;

  /// Audios de otros que ya escuché (sin el punto turquesa).
  final Set<String> heard;

  VoicePlaybackState copyWith({
    String? id,
    bool? playing,
    Duration? position,
    double? speed,
    Set<String>? heard,
  }) => VoicePlaybackState(
    id: id ?? this.id,
    playing: playing ?? this.playing,
    position: position ?? this.position,
    speed: speed ?? this.speed,
    heard: heard ?? this.heard,
  );
}

const _heardKey = 'voice_heard';
const _heardMax = 300;

@Riverpod(keepAlive: true)
class VoicePlayback extends _$VoicePlayback {
  final _player = AudioPlayer();
  final _subs = <StreamSubscription<Object?>>[];

  @override
  VoicePlaybackState build() {
    _subs
      ..add(
        _player.positionStream.listen(
          (p) => state = state.copyWith(position: p),
        ),
      )
      ..add(
        _player.playerStateStream.listen((s) {
          if (s.processingState == ProcessingState.completed) {
            // Terminó: vuelve al principio, en pausa
            unawaited(_player.pause());
            unawaited(_player.seek(Duration.zero));
            state = state.copyWith(playing: false, position: Duration.zero);
          } else {
            state = state.copyWith(playing: s.playing);
          }
        }),
      );
    ref.onDispose(() {
      for (final s in _subs) {
        unawaited(s.cancel());
      }
      unawaited(_player.dispose());
    });
    unawaited(_loadHeard());
    return const VoicePlaybackState();
  }

  Future<void> _loadHeard() async {
    try {
      final list = await SharedPreferencesAsync().getStringList(_heardKey);
      if (list != null) state = state.copyWith(heard: list.toSet());
    } catch (_) {}
  }

  /// Play / pausa de [voice]. Si sonaba otro, lo reemplaza.
  Future<void> toggle(VoiceInfo voice) async {
    if (!voice.playable) return;
    if (state.id == voice.id) {
      if (_player.playing) {
        await _player.pause();
      } else {
        unawaited(_player.play());
      }
      return;
    }
    await _player.stop();
    state = state.copyWith(id: voice.id, position: Duration.zero);
    try {
      if (voice.url != null) {
        await _player.setUrl(voice.url!);
      } else {
        await _player.setFilePath(voice.localPath!);
      }
      await _player.setSpeed(state.speed);
      unawaited(_player.play());
      _markHeard(voice.id);
    } catch (_) {
      state = state.copyWith(playing: false);
    }
  }

  /// 1x → 1.5x → 2x (vale para todos los audios).
  Future<void> cycleSpeed() async {
    final speed = nextSpeed(state.speed);
    state = state.copyWith(speed: speed);
    await _player.setSpeed(speed);
  }

  Future<void> seek(VoiceInfo voice, double fraction) async {
    if (state.id != voice.id) return;
    await _player.seek(voice.duration * fraction.clamp(0.0, 1.0));
  }

  /// Corta lo que suene (al salir del chat o empezar a grabar).
  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(playing: false);
  }

  void _markHeard(String id) {
    if (state.heard.contains(id)) return;
    final heard = {...state.heard, id};
    state = state.copyWith(heard: heard);
    final list = heard.toList();
    unawaited(
      SharedPreferencesAsync()
          .setStringList(
            _heardKey,
            list.length > _heardMax
                ? list.sublist(list.length - _heardMax)
                : list,
          )
          .catchError((_) {}),
    );
  }
}
