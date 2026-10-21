import 'video_files.dart';

// Recorte de videos de series (lógica pura). video_compress recorta en
// segundos enteros, así que las manijas se mueven de a 1 s (el fin puede ser
// el final exacto del video).

const _maxMs = maxVideoSeconds * 1000;
const _minMs = 1000;

/// Tramo elegido, en ms.
class TrimRange {
  const TrimRange(this.startMs, this.endMs);

  final int startMs;
  final int endMs;

  int get lengthMs => endMs - startMs;

  /// Al abrir: todo el video, o los primeros 90 s si es más largo.
  factory TrimRange.initial(int totalMs) =>
      TrimRange(0, totalMs < _maxMs ? totalMs : _maxMs);

  /// Mover el inicio a [ms]: mínimo 1 s de video y máximo 90.
  TrimRange withStart(int ms) {
    final lo = endMs - _maxMs < 0 ? 0 : endMs - _maxMs;
    final hi = endMs - _minMs < 0 ? 0 : endMs - _minMs;
    return TrimRange(_snap(ms).clamp(lo, hi), endMs);
  }

  /// Mover el fin a [ms] (sin pasar de [totalMs]).
  TrimRange withEnd(int ms, int totalMs) {
    final lo = startMs + _minMs;
    final hi = startMs + _maxMs < totalMs ? startMs + _maxMs : totalMs;
    final snapped = ms >= totalMs ? totalMs : _snap(ms);
    return TrimRange(startMs, snapped.clamp(lo < hi ? lo : hi, hi));
  }

  /// Sin recorte = el video entero.
  bool isWhole(int totalMs) => startMs == 0 && endMs >= totalMs;

  static int _snap(int ms) => (ms / 1000).round() * 1000;
}

/// Parámetros `startTime` / `duration` de `VideoCompress.compressVideo`, en
/// segundos. En iOS `duration` es lo que dura el tramo; en Android (Transcoder
/// `TrimDataSource`) es cuánto se corta del final.
({int start, int duration}) compressTrimArgs(
  TrimRange r,
  int totalMs, {
  required bool android,
}) {
  final start = r.startMs ~/ 1000;
  if (android) {
    final fromEnd = (totalMs - r.endMs) ~/ 1000;
    return (start: start, duration: fromEnd < 0 ? 0 : fromEnd);
  }
  return (start: start, duration: (r.lengthMs / 1000).ceil());
}

/// "1:05"
String clockOf(int ms) {
  final s = ms ~/ 1000;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}
