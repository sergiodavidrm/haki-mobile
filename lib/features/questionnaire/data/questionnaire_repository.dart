import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/cache/api_cache.dart';
import '../../../core/network/api_client.dart';
import 'questionnaire_dtos.dart';

part 'questionnaire_repository.g.dart';

class QuestionnaireRepository {
  QuestionnaireRepository(this._api, this._cache);

  final Dio _api;
  final ApiCache _cache;

  /// Con copia local: la tarjeta de Hoy se ve aunque no haya señal.
  Future<AthleteQuestionnaires> getMine({void Function()? onUpdated}) =>
      _cache.get(
        '/questionnaires/me',
        (j) => AthleteQuestionnaires.fromJson(j as Map<String, dynamic>),
        onUpdated: onUpdated,
      );

  Future<void> submit(String responseId, Map<String, AnswerInput> answers) =>
      _api.post<void>(
        '/questionnaires/me/responses/$responseId',
        data: {
          'answers': [
            for (final MapEntry(key: id, value: a) in answers.entries)
              if (!a.isEmpty)
                {
                  'questionId': id,
                  'text': ?a.text?.trim(),
                  'scale': ?a.scale,
                  'yesNo': ?a.yesNo,
                  if (a.yesNo == true) 'detail': ?a.detail?.trim(),
                },
          ],
        },
      );
}

@Riverpod(keepAlive: true)
QuestionnaireRepository questionnaireRepository(Ref ref) =>
    QuestionnaireRepository(
      ref.watch(apiClientProvider),
      ref.watch(apiCacheProvider),
    );
