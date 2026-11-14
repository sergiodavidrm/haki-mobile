import 'dart:io';

import 'package:flutter/services.dart';

import '../../../core/config/env.dart';

/// Sticker a la cámara de Snapchat (Creative Kit, "Share to Camera"): abre
/// Snapchat con el sticker encima para sacarse la foto o el video. Lo hace
/// MainActivity.kt (Android); en iOS todavía no.
/// Necesita `SNAP_CLIENT_ID` (Snap Kit). Mientras la app de Snap Kit no esté
/// aprobada solo funciona con las cuentas de prueba (Demo Users).
class SnapchatShare {
  static const _channel = MethodChannel('haki/snapchat');

  static bool get configured => Platform.isAndroid && Env.snapClientId.isNotEmpty;

  static Future<bool> isInstalled() async {
    if (!configured) return false;
    try {
      return await _channel.invokeMethod<bool>('isInstalled') ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// [path] = PNG en la caché de la app (máx. 1 MB). [widthDp]/[heightDp] =
  /// tamaño con que aparece el sticker en Snapchat (se puede achicar ahí).
  static Future<void> shareSticker(String path, {required int widthDp, required int heightDp, bool withSticker = true}) =>
      _channel.invokeMethod<void>('shareSticker', {
        'path': path,
        'clientId': Env.snapClientId,
        'appName': 'Haki',
        'widthDp': widthDp,
        'heightDp': heightDp,
        'withSticker': withSticker,
      });
}
