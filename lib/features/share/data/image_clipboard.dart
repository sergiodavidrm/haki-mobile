import 'dart:io';

import 'package:flutter/services.dart';

/// Copia una imagen (PNG de la caché) al portapapeles: el atleta la pega como
/// sticker en su historia de Instagram, sobre la foto que se saca ahí.
/// Solo Android (MainActivity.copyImage); en iOS no se muestra el botón.
class ImageClipboard {
  static const _channel = MethodChannel('haki/clipboard');

  static bool get supported => Platform.isAndroid;

  static Future<void> copy(String path) => _channel.invokeMethod<void>('copyImage', {'path': path});
}
