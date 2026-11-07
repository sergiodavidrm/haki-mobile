import 'dart:io';
import 'dart:typed_data';

// ¿El video es HEVC (H.265)? Lo usa la compresión: en algunos teléfonos
// (Samsung S25, 2026-11-06) el Transcoder se traba con HEVC + audio. Se lee
// solo el box `moov` del MP4 (metadatos, unos KB) y se busca la entrada de
// muestra `hvc1` / `hev1`: buscar en todo el archivo podría dar falsos
// positivos con bytes del video.

const _maxMoov = 32 * 1024 * 1024;

/// true si es HEVC; false si no o si no se pudo leer (no es MP4, etc.).
Future<bool> isHevcVideo(String path) async {
  RandomAccessFile? f;
  try {
    f = await File(path).open();
    final length = await f.length();
    var pos = 0;
    while (pos + 8 <= length) {
      await f.setPosition(pos);
      final header = await f.read(16);
      if (header.length < 8) return false;
      final box = parseBoxHeader(header, length - pos);
      if (box == null) return false;
      if (box.type == 'moov') {
        final size = box.size - box.headerSize;
        if (size <= 0 || size > _maxMoov) return false;
        await f.setPosition(pos + box.headerSize);
        return containsHevcSampleEntry(await f.read(size));
      }
      pos += box.size;
    }
    return false;
  } catch (_) {
    return false;
  } finally {
    await f?.close();
  }
}

/// Cabecera de un box MP4: tamaño total (32 bits, o 64 si vale 1; 0 = hasta
/// el final) y tipo. null si es inválida.
({int size, int headerSize, String type})? parseBoxHeader(
  Uint8List h,
  int remaining,
) {
  final data = ByteData.sublistView(h);
  var size = data.getUint32(0);
  final type = String.fromCharCodes(h.sublist(4, 8));
  var headerSize = 8;
  if (size == 1) {
    if (h.length < 16) return null;
    size = data.getUint64(8);
    headerSize = 16;
  } else if (size == 0) {
    size = remaining;
  }
  if (size < headerSize || size > remaining) return null;
  return (size: size, headerSize: headerSize, type: type);
}

/// Busca `hvc1` o `hev1` en los bytes del `moov`.
bool containsHevcSampleEntry(Uint8List moov) {
  for (var i = 0; i + 4 <= moov.length; i++) {
    if (moov[i] != 0x68) continue; // 'h'
    final b1 = moov[i + 1], b2 = moov[i + 2], b3 = moov[i + 3];
    if (b1 == 0x76 && b2 == 0x63 && b3 == 0x31) return true; // hvc1
    if (b1 == 0x65 && b2 == 0x76 && b3 == 0x31) return true; // hev1
  }
  return false;
}
