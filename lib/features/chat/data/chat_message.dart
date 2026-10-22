import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../../../core/units/weight_unit.dart';
import '../../../core/format/dates.dart';
import '../../../l10n/l10n.dart';

// Lógica pura de los mensajes del chat (sin Flutter): tarjetas de videos,
// separadores de fecha y miniaturas de Cloudinary.

/// Video de una serie dentro de la tarjeta de un ejercicio.
class CardVideo {
  const CardVideo({
    required this.setNumber,
    required this.url,
    this.weightKg,
    this.reps,
    this.rir,
  });

  final int setNumber;
  final String url;
  final double? weightKg;
  final int? reps;
  final int? rir;

  /// "116 lb × 12 · RIR 1"; sin peso "12 reps · RIR 1".
  String label(WeightUnit unit) {
    final w = weightKg;
    final base = w == null || w <= 0
        ? '${reps ?? '–'} ${l10n.repsShort}'
        : '${formatWeight(unit.fromKg(w))} ${unit.label} × ${reps ?? '–'}';
    return rir == null ? base : '$base · RIR $rir';
  }
}

/// Tarjeta de videos de un ejercicio: la publica la API como mensaje del
/// atleta (ver haki-api/CLAUDE.md § Chat). El texto es la nota del atleta.
class VideoCard {
  const VideoCard({
    required this.exerciseName,
    this.weekNumber,
    this.dayNumber,
    required this.videos,
    this.note,
  });

  final String exerciseName;
  final int? weekNumber;
  final int? dayNumber;
  final List<CardVideo> videos;
  final String? note;

  /// "Sem 2 · Día 3"
  String? get dayLabel => weekNumber == null || dayNumber == null
      ? null
      : '${l10n.weekShortN(weekNumber!)} · ${l10n.dayN(dayNumber!)}';

  /// null si el mensaje no es una tarjeta.
  static VideoCard? of(Message m) {
    final name = m.extraData['exerciseName'];
    if (name is! String) return null;
    return VideoCard(
      exerciseName: name,
      weekNumber: _int(m.extraData['weekNumber']),
      dayNumber: _int(m.extraData['dayNumber']),
      note: (m.text ?? '').trim().isEmpty ? null : m.text!.trim(),
      videos: [
        for (final a in m.attachments)
          if (a.assetUrl != null)
            CardVideo(
              setNumber: _int(a.extraData['setNumber']) ?? 0,
              url: a.assetUrl!,
              weightKg: (a.extraData['weight'] as num?)?.toDouble(),
              reps: _int(a.extraData['reps']),
              rir: _int(a.extraData['rir']),
            ),
      ]..sort((a, b) => a.setNumber.compareTo(b.setNumber)),
    );
  }

  static int? _int(Object? v) => v is num ? v.toInt() : null;
}

/// Miniatura de un video de Cloudinary: el mismo recurso como .jpg (cuadro
/// del medio). null si la URL no es de Cloudinary.
String? cloudinaryThumb(String videoUrl) {
  final uri = Uri.tryParse(videoUrl);
  if (uri == null || !uri.host.endsWith('cloudinary.com')) return null;
  final path = uri.path;
  final dot = path.lastIndexOf('.');
  final slash = path.lastIndexOf('/');
  final base = dot > slash ? path.substring(0, dot) : path;
  return uri.replace(path: '$base.jpg').toString();
}

/// Separador de día: "Hoy", "Ayer" o "25 sep" (con año si no es este).
String daySeparator(DateTime d, DateTime now) {
  final day = DateTime(d.year, d.month, d.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return l10n.commonToday;
  if (diff == 1) return capitalize(l10n.commonYesterday);
  final s = formatDayMonth(d);
  return d.year == now.year ? s : '$s ${d.year}';
}

/// "26 sep"
String shortDate(DateTime d) => formatDayMonth(d);

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// "18:42"
String timeOf(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
