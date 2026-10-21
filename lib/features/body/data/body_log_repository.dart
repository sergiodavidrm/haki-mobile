import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/units/weight_unit.dart';
import 'body_log_dto.dart';

part 'body_log_repository.g.dart';

class BodyLogRepository {
  BodyLogRepository(this._api);

  final Dio _api;

  Future<List<BodyLogDto>> getHistory(String clientId) async {
    final res = await _api.get<List<dynamic>>('/body-logs/$clientId');
    return [
      for (final j in res.data ?? const [])
        BodyLogDto.fromJson(j as Map<String, dynamic>),
    ];
  }

  /// Upsert del día [date]: lo que no se manda queda como estaba (la API
  /// mergea). [weight] y las medidas en kg van en [unit]; la API pasa a kg.
  Future<void> save({
    required DateTime date,
    required WeightUnit unit,
    double? weight,
    Map<String, double> measures = const {},
  }) async {
    final d =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    await _api.post<void>(
      '/body-logs/me',
      data: {
        'loggedDate': d,
        'weight': ?weight,
        'weightUnit': unit.api,
        'values': measures,
      },
    );
  }
}

@Riverpod(keepAlive: true)
BodyLogRepository bodyLogRepository(Ref ref) =>
    BodyLogRepository(ref.watch(apiClientProvider));
