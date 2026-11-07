import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/session/data/video_codec.dart';

Uint8List _box(String type, List<int> body) {
  final size = 8 + body.length;
  return Uint8List.fromList([
    (size >> 24) & 0xff,
    (size >> 16) & 0xff,
    (size >> 8) & 0xff,
    size & 0xff,
    ...type.codeUnits,
    ...body,
  ]);
}

Future<String> _write(Directory dir, String name, List<Uint8List> boxes) async {
  final file = File('${dir.path}/$name');
  await file.writeAsBytes([for (final b in boxes) ...b]);
  return file.path;
}

void main() {
  late Directory dir;
  setUp(() async => dir = await Directory.systemTemp.createTemp('codec'));
  tearDown(() async => dir.delete(recursive: true));

  final ftyp = _box('ftyp', 'isom'.codeUnits);

  test('HEVC con el moov al final (como graba Samsung)', () async {
    final mdat = _box('mdat', List.filled(1000, 7));
    final moov = _box('moov', [..._box('trak', [..._box('stsd', 'hvc1'.codeUnits)])]);
    final path = await _write(dir, 'a.mp4', [ftyp, mdat, moov]);
    expect(await isHevcVideo(path), isTrue);
  });

  test('hev1 también es HEVC', () async {
    final moov = _box('moov', 'hev1'.codeUnits);
    expect(await isHevcVideo(await _write(dir, 'b.mp4', [ftyp, moov])), isTrue);
  });

  test('H.264 (avc1) no es HEVC', () async {
    final moov = _box('moov', [..._box('stsd', 'avc1'.codeUnits)]);
    expect(await isHevcVideo(await _write(dir, 'c.mp4', [ftyp, moov])), isFalse);
  });

  test('"hvc1" dentro del video (mdat) no cuenta', () async {
    final mdat = _box('mdat', 'xxhvc1xx'.codeUnits);
    final moov = _box('moov', 'avc1'.codeUnits);
    final path = await _write(dir, 'd.mp4', [ftyp, mdat, moov]);
    expect(await isHevcVideo(path), isFalse);
  });

  test('archivo inválido o inexistente = false', () async {
    final bad = File('${dir.path}/e.mp4')..writeAsBytesSync([1, 2, 3]);
    expect(await isHevcVideo(bad.path), isFalse);
    expect(await isHevcVideo('${dir.path}/no.mp4'), isFalse);
  });
}
