import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../program/data/assignment_dtos.dart';

part 'exercise_history.g.dart';

// GET progress/{clientId}/exercises/{exerciseId}/history: cada vez que el
// atleta hizo el ejercicio (de cualquier programa), del más nuevo al más viejo.
class ExerciseHistoryEntryDto {
  const ExerciseHistoryEntryDto({
    required this.assignmentId,
    required this.blockName,
    required this.weekNumber,
    required this.blockDayId,
    required this.date,
    required this.sets,
  });

  final String assignmentId;
  final String blockName;
  final int weekNumber;
  final String blockDayId;
  final DateTime date;
  final List<LoggedSetDto> sets;

  factory ExerciseHistoryEntryDto.fromJson(Map<String, dynamic> j) =>
      ExerciseHistoryEntryDto(
        assignmentId: j['assignmentId'] as String,
        blockName: j['blockName'] as String? ?? '',
        weekNumber: j['weekNumber'] as int,
        blockDayId: j['blockDayId'] as String,
        date: DateTime.parse(j['date'] as String),
        sets: [
          for (final s in j['sets'] as List? ?? const [])
            LoggedSetDto.fromJson(s as Map<String, dynamic>),
        ],
      );
}

class ExerciseHistoryRepository {
  ExerciseHistoryRepository(this._api);

  final Dio _api;

  Future<List<ExerciseHistoryEntryDto>> get(
    String clientId,
    String exerciseId,
  ) async {
    final res = await _api.get<List<dynamic>>(
      '/progress/$clientId/exercises/$exerciseId/history',
    );
    return [
      for (final j in res.data ?? const [])
        ExerciseHistoryEntryDto.fromJson(j as Map<String, dynamic>),
    ];
  }
}

@Riverpod(keepAlive: true)
ExerciseHistoryRepository exerciseHistoryRepository(Ref ref) =>
    ExerciseHistoryRepository(ref.watch(apiClientProvider));
