import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

// Videos de series esperando subirse. Viven en la carpeta de la app (no en la
// caché, que el sistema puede vaciar) hasta que la cola los sube.

const maxVideoSeconds = 90;

/// Abre la cámara o la galería; devuelve la ruta o null si canceló. La cámara
/// corta sola a los [maxVideoSeconds]; uno más largo de la galería se recorta
/// en Recortar video.
Future<String?> pickSetVideo(ImageSource source) async {
  final file = await ImagePicker().pickVideo(
    source: source,
    maxDuration: const Duration(seconds: maxVideoSeconds),
  );
  return file?.path;
}

Future<Directory> videosDir() async {
  final base = await getApplicationSupportDirectory();
  final dir = Directory('${base.path}/videos');
  await dir.create(recursive: true);
  return dir;
}

/// Copia el video grabado/elegido a la carpeta de la cola.
Future<String> keepVideo(String sourcePath) async {
  final dir = await videosDir();
  final ext = sourcePath.contains('.') ? sourcePath.split('.').last : 'mp4';
  final target = '${dir.path}/${DateTime.now().microsecondsSinceEpoch}.$ext';
  await File(sourcePath).copy(target);
  return target;
}

Future<void> deleteVideoFile(String? path) async {
  if (path == null) return;
  try {
    await File(path).delete();
  } on FileSystemException {
    // ya no estaba
  }
}

/// Al borrar la BD local (cerrar sesión / otro usuario).
Future<void> deleteAllVideoFiles() async {
  try {
    final dir = await videosDir();
    await dir.delete(recursive: true);
  } on FileSystemException {
    // nada que borrar
  }
}
