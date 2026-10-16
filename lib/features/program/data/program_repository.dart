import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import 'assignment_dtos.dart';

part 'program_repository.g.dart';

class ProgramRepository {
  ProgramRepository(this._api);

  final Dio _api;

  /// Programas del atleta (la API ya excluye borradores y cancelados).
  Future<List<AssignmentSummaryDto>> getAssignments(String clientId) async {
    final res = await _api.get<List<dynamic>>(
      '/block-assignments/$clientId/assignments',
    );
    return [
      for (final j in res.data ?? const [])
        AssignmentSummaryDto.fromJson(j as Map<String, dynamic>),
    ];
  }

  Future<AssignmentDetailDto> getDetail(String assignmentId) async {
    final res = await _api.get<Map<String, dynamic>>(
      '/block-assignments/$assignmentId/detail',
    );
    return AssignmentDetailDto.fromJson(res.data!);
  }
}

@Riverpod(keepAlive: true)
ProgramRepository programRepository(Ref ref) =>
    ProgramRepository(ref.watch(apiClientProvider));
