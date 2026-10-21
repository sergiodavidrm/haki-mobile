import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/format/dates.dart';
import '../../../core/network/api_client.dart';
import '../../../core/units/weight_unit.dart';
import '../../program/data/program_schedule.dart';

part 'records.g.dart';

// GET progress/{clientId}/records: récord vigente (mejor e1RM) de cada
// ejercicio, del más reciente al más viejo. La API lo calcula desde las
// series registradas (ver haki-api Domain/PersonalRecords.cs).

class PersonalRecordDto {
  const PersonalRecordDto({
    required this.exerciseId,
    required this.exerciseName,
    required this.assignmentId,
    required this.date,
    required this.e1RmKg,
    required this.weightKg,
    required this.unit,
    required this.reps,
    this.rir,
    this.previousE1RmKg,
  });

  final String exerciseId;
  final String exerciseName;

  /// Programa donde lo logró ("Este bloque").
  final String assignmentId;
  final DateTime date;
  final double e1RmKg;
  final double weightKg;

  /// Unidad en que cargó esa serie: el récord se muestra así.
  final WeightUnit unit;
  final int reps;
  final int? rir;

  /// Marca anterior; null = primera vez que lo hizo (no cuenta como PR).
  final double? previousE1RmKg;

  bool get isPr => previousE1RmKg != null;

  /// "163.8 lb"
  String get e1RmLabel => '${formatWeight(unit.fromKg(e1RmKg))} ${unit.label}';

  /// "121 lb × 12 · RIR 1"
  String get setLabel {
    final base = '${formatWeight(unit.fromKg(weightKg))} ${unit.label} × $reps';
    return rir == null ? base : '$base · RIR $rir';
  }

  /// "+4.9" (en la unidad del récord); null si es la primera vez.
  String? get improvementLabel {
    final prev = previousE1RmKg;
    if (prev == null) return null;
    return '+${formatWeight(unit.fromKg(e1RmKg) - unit.fromKg(prev))}';
  }

  factory PersonalRecordDto.fromJson(Map<String, dynamic> j) =>
      PersonalRecordDto(
        exerciseId: j['exerciseId'] as String,
        exerciseName: j['exerciseName'] as String,
        assignmentId: j['assignmentId'] as String,
        date: DateTime.parse(j['date'] as String),
        e1RmKg: (j['e1RmKg'] as num).toDouble(),
        weightKg: (j['weightKg'] as num).toDouble(),
        unit: WeightUnit.parse(j['weightUnit'] as String? ?? 'KG'),
        reps: j['reps'] as int,
        rir: j['rir'] as int?,
        previousE1RmKg: (j['previousE1RmKg'] as num?)?.toDouble(),
      );
}

/// Secciones de la pantalla Récords: "Esta semana" (PRs de la semana de
/// calendario) y el resto: los del programa en curso ([blockOnly]) o todos.
({List<PersonalRecordDto> thisWeek, List<PersonalRecordDto> rest})
recordSections(
  List<PersonalRecordDto> records, {
  required DateTime today,
  String? currentAssignmentId,
  required bool blockOnly,
}) {
  final day = dateOnly(today);
  final monday = day.subtract(Duration(days: day.weekday - 1));
  bool inWeek(PersonalRecordDto r) =>
      r.isPr && !dateOnly(r.date).isBefore(monday);
  final thisWeek = records.where(inWeek).toList();
  final rest = records
      .where((r) => !inWeek(r))
      .where((r) => !blockOnly || r.assignmentId == currentAssignmentId)
      .toList();
  return (thisWeek: thisWeek, rest: rest);
}

/// "hoy", "ayer" o "25 sep".
String recordDateLabel(DateTime date, DateTime today) {
  final d = dateOnly(date).difference(dateOnly(today)).inDays;
  if (d == 0) return 'hoy';
  if (d == -1) return 'ayer';
  return formatDayMonth(date);
}

class RecordsRepository {
  RecordsRepository(this._api);

  final Dio _api;

  Future<List<PersonalRecordDto>> get(String clientId) async {
    final res = await _api.get<List<dynamic>>('/progress/$clientId/records');
    return [
      for (final j in res.data ?? const [])
        PersonalRecordDto.fromJson(j as Map<String, dynamic>),
    ];
  }
}

@Riverpod(keepAlive: true)
RecordsRepository recordsRepository(Ref ref) =>
    RecordsRepository(ref.watch(apiClientProvider));
