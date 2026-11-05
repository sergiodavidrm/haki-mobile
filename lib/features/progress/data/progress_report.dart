import '../../../core/units/weight_unit.dart';

// GET progress/{clientId}/performance-report (haki-api PerformanceReportService),
// la parte que usa "Tu progreso": columnas (semanas), una fila por ejercicio
// (byExercise=true) y los entrenos hechos de los que tocaban. Pesos en kg.
// Mockup: pantalla "App · Tu progreso" de https://claude.ai/artifact/WqKHzTWsJgE2CnrNqHX1gy

/// Período elegido arriba de la pantalla.
enum ProgressPeriod {
  block('block', null),
  previous('previous', null),
  weeks4('weeks', 4),
  weeks8('weeks', 8),
  weeks12('weeks', 12);

  const ProgressPeriod(this.api, this.weeks);

  final String api;
  final int? weeks;

  String get query => weeks == null
      ? 'period=$api&byExercise=true'
      : 'period=$api&weeks=$weeks&byExercise=true';
}

enum ColumnState { done, partial, future }

class ReportColumn {
  const ReportColumn({
    required this.label,
    required this.state,
    this.weekNumber,
    this.start,
    this.end,
  });

  /// block: "S1"; weeks: el lunes en ISO
  final String label;
  final ColumnState state;
  final int? weekNumber;
  final DateTime? start;
  final DateTime? end;

  factory ReportColumn.fromJson(Map<String, dynamic> j) => ReportColumn(
    label: j['label'] as String,
    state: ColumnState.values.asNameMap()[j['state']] ?? ColumnState.future,
    weekNumber: j['weekNumber'] as int?,
    start: j['start'] == null ? null : DateTime.parse(j['start'] as String),
    end: j['end'] == null ? null : DateTime.parse(j['end'] as String),
  );
}

class BestSet {
  const BestSet({
    required this.weightKg,
    required this.unit,
    required this.reps,
    required this.value,
  });

  final double? weightKg;

  /// Unidad en que cargó la serie (se muestra así)
  final WeightUnit unit;
  final int reps;
  final double value;

  factory BestSet.fromJson(Map<String, dynamic> j) => BestSet(
    weightKg: (j['weightKg'] as num?)?.toDouble(),
    unit: WeightUnit.parse(j['weightUnit'] as String?),
    reps: j['reps'] as int,
    value: (j['value'] as num).toDouble(),
  );
}

class ExerciseProgress {
  const ExerciseProgress({
    required this.exerciseId,
    required this.name,
    required this.bodyweight,
    required this.values,
    required this.best,
  });

  final String exerciseId;
  final String name;

  /// Sin peso: los valores son reps, no e1RM
  final bool bodyweight;

  /// e1RM (kg) o reps, por columna
  final List<double?> values;
  final List<BestSet?> best;

  factory ExerciseProgress.fromJson(Map<String, dynamic> j) => ExerciseProgress(
    exerciseId: j['exerciseId'] as String,
    name: j['name'] as String,
    bodyweight: j['bodyweight'] as bool? ?? false,
    values: [
      for (final v in (j['values'] as List? ?? const []))
        (v as num?)?.toDouble(),
    ],
    best: [
      for (final b in (j['best'] as List? ?? const []))
        b == null ? null : BestSet.fromJson(b as Map<String, dynamic>),
    ],
  );
}

class ProgramInfo {
  const ProgramInfo({
    required this.assignmentId,
    required this.name,
    required this.status,
    required this.totalWeeks,
    this.currentWeek,
    this.endDate,
  });

  final String assignmentId;
  final String name;
  final String status;
  final int totalWeeks;
  final int? currentWeek;
  final DateTime? endDate;

  static ProgramInfo? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    return ProgramInfo(
      assignmentId: json['assignmentId'] as String,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'active',
      totalWeeks: json['totalWeeks'] as int? ?? 0,
      currentWeek: json['currentWeek'] as int?,
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
    );
  }
}

class ProgressReport {
  const ProgressReport({
    required this.isRange,
    required this.from,
    required this.to,
    required this.columns,
    required this.exercises,
    required this.done,
    required this.due,
    required this.programNames,
    required this.weekFull,
    required this.weekFill,
    this.program,
    this.currentDone,
    this.currentPlanned,
  });

  /// true = semanas de calendario (4/8/12); false = un bloque
  final bool isRange;
  final DateTime from;
  final DateTime to;
  final ProgramInfo? program;
  final List<ReportColumn> columns;
  final List<ExerciseProgress> exercises;
  final int done;
  final int due;
  final int? currentDone;
  final int? currentPlanned;

  /// Programas del rango, en orden
  final List<String> programNames;

  /// Por columna: hizo todos los entrenos que tocaban (barrita llena)
  final List<bool> weekFull;

  /// Por columna: parte de la barrita llena (hechos / los que tenía la semana)
  final List<double> weekFill;

  factory ProgressReport.fromJson(Map<String, dynamic> j) {
    final columns = [
      for (final c in (j['columns'] as List? ?? const []))
        ReportColumn.fromJson(c as Map<String, dynamic>),
    ];
    final kpis = j['kpis'] as Map<String, dynamic>? ?? const {};
    final rows =
        (j['constancy'] as Map<String, dynamic>?)?['rows'] as List? ?? const [];
    final cells = [
      for (final r in rows)
        [
          for (final c in ((r as Map<String, dynamic>)['cells'] as List))
            c as String,
        ],
    ];
    final names = <String>[];
    for (final b in (j['bands'] as List? ?? const [])) {
      final n = (b as Map<String, dynamic>)['name'] as String?;
      if (n != null && !names.contains(n)) names.add(n);
    }
    return ProgressReport(
      isRange: j['period'] == 'weeks',
      from: DateTime.parse(j['from'] as String),
      to: DateTime.parse(j['to'] as String),
      program: ProgramInfo.fromJson(j['program']),
      columns: columns,
      exercises: [
        for (final r in (j['rows'] as List? ?? const []))
          ExerciseProgress.fromJson(r as Map<String, dynamic>),
      ],
      done: kpis['done'] as int? ?? 0,
      due: kpis['due'] as int? ?? 0,
      currentDone: kpis['currentDone'] as int?,
      currentPlanned: kpis['currentPlanned'] as int?,
      programNames: names,
      weekFull: [
        for (var i = 0; i < columns.length; i++)
          weekIsFull([for (final r in cells) i < r.length ? r[i] : 'none']),
      ],
      weekFill: [
        for (var i = 0; i < columns.length; i++)
          weekFillOf([for (final r in cells) i < r.length ? r[i] : 'none']),
      ],
    );
  }
}

/// Parte de la semana hecha (0–1): hechos sobre los entrenos que tenía
/// (sin días vacíos ni descansos; los futuros de la semana en curso cuentan).
double weekFillOf(List<String> cells) {
  final total = cells.where((c) => c != 'none' && c != 'rest').length;
  if (total == 0) return 0;
  return cells.where((c) => c == 'done').length / total;
}

/// Una semana está completa si tenía algo que hacer y no faltó a nada.
bool weekIsFull(List<String> cells) {
  final relevant = cells.where(
    (c) => c != 'none' && c != 'rest' && c != 'future',
  );
  return relevant.isNotEmpty &&
      relevant.every((c) => c == 'done') &&
      cells.contains('done');
}

/// Fila de la lista: primera y última semana con datos y el cambio en %.
class ExerciseTrend {
  const ExerciseTrend({
    required this.exercise,
    required this.first,
    required this.last,
    required this.points,
  });

  final ExerciseProgress exercise;
  final double first;
  final double last;

  /// Valores con dato, en orden (para el mini gráfico)
  final List<double> points;

  /// null = una sola semana con datos
  int? get pct => points.length < 2 || first == 0
      ? null
      : ((last - first) * 100 / first).round();
}

/// Ejercicios con al menos un dato en el período, del que más subió al que
/// menos (los ocultos van aparte, en el mismo orden).
List<ExerciseTrend> trendsOf(ProgressReport r) {
  final list = <ExerciseTrend>[];
  for (final e in r.exercises) {
    final points = e.values.nonNulls.toList();
    if (points.isEmpty) continue;
    list.add(
      ExerciseTrend(
        exercise: e,
        first: points.first,
        last: points.last,
        points: points,
      ),
    );
  }
  list.sort((a, b) => (b.pct ?? -1000).compareTo(a.pct ?? -1000));
  return list;
}

/// Índices de las columnas con un récord nuevo (supera todas las anteriores
/// del período).
List<bool> prMask(List<double?> values) {
  double? best;
  return [
    for (final v in values)
      () {
        if (v == null) return false;
        final isPr = best != null && v > best!;
        if (best == null || v > best!) best = v;
        return isPr;
      }(),
  ];
}
