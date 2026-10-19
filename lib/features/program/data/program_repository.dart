import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/cache/api_cache.dart';
import '../../../core/network/api_client.dart';
import 'assignment_dtos.dart';

part 'program_repository.g.dart';

// Lecturas con ApiCache: sin señal se ven los programas y el detalle de la
// última vez que hubo conexión (y se puede entrenar).
class ProgramRepository {
  ProgramRepository(this._api, this._cache);

  final Dio _api;
  final ApiCache _cache;

  /// Programas del atleta (la API ya excluye borradores y cancelados).
  Future<List<AssignmentSummaryDto>> getAssignments(String clientId) =>
      _cache.get(
        '/block-assignments/$clientId/assignments',
        (j) => [
          for (final x in j as List? ?? const [])
            AssignmentSummaryDto.fromJson(x as Map<String, dynamic>),
        ],
      );

  Future<AssignmentDetailDto> getDetail(String assignmentId) => _cache.get(
    '/block-assignments/$assignmentId/detail',
    (j) => AssignmentDetailDto.fromJson(j as Map<String, dynamic>),
  );

  /// Fecha de inicio + día de la semana de cada entreno ([weekDays]:
  /// DayNumber → 1 = lunes … 7 = domingo). La API recalcula el fin.
  Future<AssignmentDetailDto> schedule(
    String assignmentId,
    DateTime start,
    Map<int, int> weekDays,
  ) async {
    final date =
        '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final res = await _api.put<Map<String, dynamic>>(
      '/block-assignments/$assignmentId/schedule',
      data: {
        'startDate': date,
        'dayMappings': [
          for (final e in weekDays.entries)
            {'dayNumber': e.key, 'weekDay': DayMappingDto.codeOf(e.value)},
        ],
      },
    );
    return AssignmentDetailDto.fromJson(res.data!);
  }
}

@Riverpod(keepAlive: true)
ProgramRepository programRepository(Ref ref) => ProgramRepository(
  ref.watch(apiClientProvider),
  ref.watch(apiCacheProvider),
);
