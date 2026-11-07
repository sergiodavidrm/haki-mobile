import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Id del video si la URL es de YouTube (watch, youtu.be, shorts, embed,
/// live, con o sin `www.`/`m.` y `http`); null = otro sitio (se abre afuera).
String? youtubeIdOf(String url) {
  var u = url.trim();
  if (u.isEmpty) return null;
  u = u.replaceFirst(RegExp(r'^http://', caseSensitive: false), 'https://');
  if (!u.toLowerCase().startsWith('https://')) u = 'https://$u';
  // El paquete no reconoce /live/ (transmisiones guardadas)
  final live = RegExp(
    r'^https://(?:www\.|m\.)?youtube\.com/live/([_\-a-zA-Z0-9]{11})',
  ).firstMatch(u);
  if (live != null) return live.group(1);
  return YoutubePlayerController.convertUrlToId(u);
}
