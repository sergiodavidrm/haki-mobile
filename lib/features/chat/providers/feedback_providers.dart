import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import 'chat_providers.dart';

part 'feedback_providers.g.dart';

/// Hilo de feedback de una tarjeta de videos, para los links fuera del chat
/// (Detalle de ejercicio, Sesión pasada): la tarjeta y su última respuesta.
class FeedbackSummary {
  const FeedbackSummary({required this.parent, this.last});

  final Message parent;
  final Message? last;

  int get count => parent.replyCount ?? 0;
}

/// [messageId] = `streamMessageId` del exercise-log. Necesita red.
@riverpod
Future<FeedbackSummary> feedbackSummary(Ref ref, String messageId) async {
  final channel = await ref.watch(generalChannelProvider.future);
  final res = await channel.client.getMessage(messageId);
  final parent = res.message;
  Message? last;
  if ((parent.replyCount ?? 0) > 0) {
    final replies = await channel.getReplies(
      messageId,
      options: const PaginationParams(limit: 1),
    );
    last = replies.messages.lastOrNull;
  }
  return FeedbackSummary(parent: parent, last: last);
}

/// Tarjeta de videos de un ejercicio del día ([dayExerciseId] =
/// BlockDayExerciseId) entre los mensajes cargados del chat. Para la Sesión:
/// el detalle del programa no se recarga durante el entreno, así que una
/// tarjeta recién publicada no trae su `streamMessageId` por ahí.
@riverpod
Stream<String?> cardIdFor(Ref ref, String dayExerciseId) async* {
  final channel = await ref.watch(generalChannelProvider.future);
  final state = channel.state;
  if (state == null) return;
  String? find(List<Message> ms) => ms
      .where((m) => m.extraData['blockDayExerciseId'] == dayExerciseId)
      .lastOrNull
      ?.id;
  yield find(state.messages);
  yield* state.messagesStream.map(find).distinct();
}
