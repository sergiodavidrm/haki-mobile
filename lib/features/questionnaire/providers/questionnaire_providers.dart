import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/cache/api_cache.dart';
import '../../../core/notifications/questionnaire_reminders.dart';
import '../data/questionnaire_dtos.dart';
import '../data/questionnaire_repository.dart';

part 'questionnaire_providers.g.dart';

/// Cuestionarios pendientes (tarjetas de Hoy) + semanales asignados.
@riverpod
Future<AthleteQuestionnaires> myQuestionnaires(Ref ref) => ref
    .watch(questionnaireRepositoryProvider)
    .getMine(
      onUpdated: () {
        if (ref.mounted) ref.invalidateSelf();
      },
    );

/// Un pendiente por id de envío (pantalla para responder).
@riverpod
PendingQuestionnaire? pendingQuestionnaire(Ref ref, String responseId) => ref
    .watch(myQuestionnairesProvider)
    .value
    ?.pending
    .where((p) => p.responseId == responseId)
    .firstOrNull;

/// Mantiene programado el aviso local de las 20:00 de cada semanal asignado y
/// recarga los pendientes al volver a primer plano. Se arranca en app.dart.
@Riverpod(keepAlive: true)
void questionnaireSync(Ref ref) {
  ref.listen(myQuestionnairesProvider, (_, next) {
    if (next case AsyncData(:final value)) {
      unawaited(ref.read(questionnaireRemindersProvider).sync(value.schedule));
    }
  });
  final listener = AppLifecycleListener(
    onResume: () => ref.invalidate(myQuestionnairesProvider),
  );
  ref.onDispose(listener.dispose);
}

/// Enviar las respuestas. El estado es el envío en curso (loading / error con
/// el mensaje de la API).
@riverpod
class QuestionnaireSubmitter extends _$QuestionnaireSubmitter {
  @override
  FutureOr<void> build() {}

  /// true si se envió. Saca la tarjeta de Hoy.
  Future<bool> submit(
    String responseId,
    Map<String, AnswerInput> answers,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(questionnaireRepositoryProvider)
          .submit(responseId, answers);
      // Que Hoy lea la API y no la copia (que todavía lo tiene pendiente)
      ref.read(apiCacheProvider).expire(wait: true);
      ref.invalidate(myQuestionnairesProvider);
    });
    return !state.hasError;
  }
}
