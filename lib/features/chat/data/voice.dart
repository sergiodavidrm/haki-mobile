import 'dart:math' as math;

import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../../../l10n/l10n.dart';

// Mensajes de voz (2026-11-09, canvas "Haki · Mensajes de voz"): adjunto
// `voiceRecording` de Stream (el archivo va al CDN de Stream) con
// `duration` (segundos) y `waveform_data` (0–1). Lógica pura: tests en
// test/voice_test.dart.

/// Máximo por audio (decidido por Sergio).
const voiceMaxDuration = Duration(minutes: 2);

/// Barras de la forma de onda que se guardan en el mensaje.
const voiceWaveformBars = 40;

/// Datos para dibujar y reproducir un audio.
class VoiceInfo {
  const VoiceInfo({
    required this.id,
    required this.duration,
    required this.waveform,
    this.url,
    this.localPath,
  });

  /// Id del adjunto (clave del reproductor y de "ya lo escuché").
  final String id;
  final Duration duration;
  final List<double> waveform;

  /// URL del CDN de Stream (null mientras se sube).
  final String? url;

  /// Archivo del teléfono (el mío, mientras se sube o si falló).
  final String? localPath;

  bool get playable => url != null || localPath != null;
}

/// El audio de un mensaje, o null si no tiene.
VoiceInfo? voiceOf(Message m) {
  final a = m.attachments
      .where((a) => a.type == AttachmentType.voiceRecording)
      .firstOrNull;
  if (a == null) return null;
  final seconds = a.extraData['duration'];
  final wave = a.extraData['waveform_data'];
  return VoiceInfo(
    id: a.id,
    duration: Duration(
      milliseconds: seconds is num ? (seconds * 1000).round() : 0,
    ),
    waveform: [
      if (wave is List)
        for (final v in wave)
          if (v is num) v.toDouble().clamp(0.0, 1.0),
    ],
    url: a.assetUrl,
    localPath: a.file?.path,
  );
}

/// Amplitud del micrófono (dBFS, −160…0) → 0–1 para la forma de onda.
/// Debajo de −50 dB es silencio.
double levelOf(double dbfs) {
  if (dbfs.isNaN || dbfs.isInfinite) return 0;
  const floor = -50.0;
  if (dbfs <= floor) return 0;
  return ((dbfs - floor) / -floor).clamp(0.0, 1.0);
}

/// Reduce (o estira) las muestras a [bars] barras: promedio por tramo.
List<double> downsample(List<double> samples, [int bars = voiceWaveformBars]) {
  if (samples.isEmpty) return List.filled(bars, 0);
  return [
    for (var i = 0; i < bars; i++)
      () {
        final from = (i * samples.length / bars).floor();
        final to = math.max(from + 1, ((i + 1) * samples.length / bars).floor());
        final slice = samples.sublist(from, math.min(to, samples.length));
        return slice.reduce((a, b) => a + b) / slice.length;
      }(),
  ];
}

/// "0:42", "1:05"
String formatVoiceDuration(Duration d) {
  final s = d.inSeconds;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// Velocidades al tocar el botón: 1x → 1.5x → 2x → 1x.
double nextSpeed(double speed) => switch (speed) {
  1.0 => 1.5,
  1.5 => 2.0,
  _ => 1.0,
};

/// Texto de un mensaje para vistas previas: el texto, o "Audio · 0:35".
String messagePreview(Message m) {
  final text = (m.text ?? '').trim();
  if (text.isNotEmpty) return text;
  final v = voiceOf(m);
  return v == null ? '' : l10n.voicePreview(formatVoiceDuration(v.duration));
}
