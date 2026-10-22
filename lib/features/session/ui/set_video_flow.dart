import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/session_plan.dart';
import '../data/session_store.dart';
import '../data/video_files.dart';
import '../data/video_trim.dart';
import 'video_trim_screen.dart';
import '../../../l10n/l10n.dart';

/// Grabar o elegir el video de una serie y dejarlo en la cola. La serie
/// tiene que estar registrada (el video se cuelga de su set-log). Serie sin
/// video pedido: se confirma antes. Lo usan la Sesión y la Sesión pasada
/// (videos subidos después de entrenar).
Future<void> queueSetVideo({
  required BuildContext context,
  required WidgetRef ref,
  required String assignmentId,
  required String dayId,
  required String dayExerciseId,
  required int setNumber,
  required SavedSet? saved,
  required bool requested,
}) async {
  void snack(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  if (saved == null) {
    snack(context.l10n.videoLogSetFirst);
    return;
  }
  if (saved.videoUploading) {
    snack(context.l10n.videoUploadingReplace);
  }
  if (!requested && !saved.hasVideo && !saved.videoUploading) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.videoUploadQuestion),
        content: Text(ctx.l10n.videoNotRequested),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.videoUpload),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
  }
  if (!context.mounted) return;

  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (saved.hasVideo)
            ListTile(
              title: Text(ctx.l10n.videoAlreadySent),
              subtitle: Text(ctx.l10n.videoReplaces),
            ),
          ListTile(
            leading: const Icon(Icons.videocam_outlined),
            title: Text(ctx.l10n.videoRecord),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.video_library_outlined),
            title: Text(ctx.l10n.videoPickGallery),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) return;

  final path = await pickSetVideo(source);
  if (path == null || !context.mounted) return;
  final range = await Navigator.of(context).push<TrimRange>(
    MaterialPageRoute(builder: (_) => VideoTrimScreen(path: path)),
  );
  if (range == null || !context.mounted) return;
  await ref
      .read(sessionStoreProvider)
      .addVideo(
        assignmentId: assignmentId,
        dayId: dayId,
        dayExerciseId: dayExerciseId,
        setNumber: setNumber,
        sourcePath: path,
        setLogId: saved.setLogId,
        trimStartMs: range.startMs,
        trimEndMs: range.endMs,
      );
  if (context.mounted) snack(context.l10n.videoQueued);
}
