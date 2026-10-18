// DTOs de block-assignments (haki-api: ClientAssignmentSummaryDto y
// BlockAssignmentDetailDto). Solo los campos que usa la app; se agregan a
// medida que los necesiten Programa / Sesión.

/// `DateOnly` de .NET ("2026-09-14") → fecha sin hora, en UTC para que las
/// restas de días no se corran con cambios de horario.
DateTime? _date(Object? v) {
  if (v == null) return null;
  final d = DateTime.parse(v as String);
  return DateTime.utc(d.year, d.month, d.day);
}

/// Fecha y hora de .NET (UTC) → hora local. Sin zona en el texto se asume UTC.
DateTime? _dateTime(Object? v) {
  if (v == null) return null;
  final s = v as String;
  final hasZone = RegExp(r'(Z|[+-]\d\d:?\d\d)$').hasMatch(s);
  return DateTime.parse(hasZone ? s : '${s}Z').toLocal();
}

/// GET block-assignments/{clientId}/assignments
class AssignmentSummaryDto {
  const AssignmentSummaryDto({
    required this.assignmentId,
    required this.blockName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalWeeks,
    required this.completedWeeks,
    required this.blockUpdatedAt,
    required this.activatedAt,
    this.totalDays = 0,
    this.completedDays = 0,
  });

  final String assignmentId;
  final String blockName;

  /// active | completed (el atleta no recibe draft ni cancelled)
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int totalWeeks;
  final int completedWeeks;
  final DateTime blockUpdatedAt;
  final DateTime? activatedAt;

  /// Entrenos del programa (todas las semanas) y cuántos están completados.
  final int totalDays;
  final int completedDays;

  bool get hasDates => startDate != null && endDate != null;

  /// 0–100, null si el programa no tiene entrenos.
  int? get adherencePct =>
      totalDays == 0 ? null : (completedDays * 100 / totalDays).round();

  factory AssignmentSummaryDto.fromJson(Map<String, dynamic> j) =>
      AssignmentSummaryDto(
        assignmentId: j['assignmentId'] as String,
        blockName: j['blockName'] as String,
        status: j['status'] as String,
        startDate: _date(j['startDate']),
        endDate: _date(j['endDate']),
        totalWeeks: j['totalWeeks'] as int? ?? 0,
        completedWeeks: j['completedWeeks'] as int? ?? 0,
        blockUpdatedAt: DateTime.parse(j['blockUpdatedAt'] as String),
        activatedAt: j['activatedAt'] == null
            ? null
            : DateTime.parse(j['activatedAt'] as String),
        totalDays: j['totalDays'] as int? ?? 0,
        completedDays: j['completedDays'] as int? ?? 0,
      );
}

/// GET block-assignments/{id}/detail
class AssignmentDetailDto {
  const AssignmentDetailDto({
    required this.assignmentId,
    required this.blockName,
    this.status = 'active',
    required this.startDate,
    required this.endDate,
    required this.numberOfWeeks,
    required this.weeks,
    required this.dayMappings,
    required this.blockUpdatedAt,
  });

  final String assignmentId;
  final String blockName;

  /// active | completed. Solo a un programa activo se le pueden poner fechas.
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int numberOfWeeks;
  final List<WeekDto> weeks;

  /// Vacío si el programa no tiene día de la semana asignado por entreno.
  final List<DayMappingDto> dayMappings;
  final DateTime blockUpdatedAt;

  bool get hasDates => startDate != null;

  /// El coach puede tener más semanas creadas que las declaradas (o al revés).
  int get totalWeeks =>
      weeks.length > numberOfWeeks ? weeks.length : numberOfWeeks;

  /// Copia con cada día transformado por [f] (p. ej. estado de las sesiones
  /// locales sin subir).
  AssignmentDetailDto mapDays(DayDto Function(DayDto) f) => AssignmentDetailDto(
    assignmentId: assignmentId,
    blockName: blockName,
    status: status,
    startDate: startDate,
    endDate: endDate,
    numberOfWeeks: numberOfWeeks,
    weeks: [
      for (final w in weeks)
        WeekDto(weekNumber: w.weekNumber, days: [for (final d in w.days) f(d)]),
    ],
    dayMappings: dayMappings,
    blockUpdatedAt: blockUpdatedAt,
  );

  factory AssignmentDetailDto.fromJson(Map<String, dynamic> j) =>
      AssignmentDetailDto(
        assignmentId: j['assignmentId'] as String,
        blockName: j['blockName'] as String,
        status: j['status'] as String? ?? 'active',
        startDate: _date(j['startDate']),
        endDate: _date(j['endDate']),
        numberOfWeeks: j['numberOfWeeks'] as int? ?? 0,
        weeks: [
          for (final w in j['weeks'] as List? ?? const [])
            WeekDto.fromJson(w as Map<String, dynamic>),
        ]..sort((a, b) => a.weekNumber.compareTo(b.weekNumber)),
        dayMappings: [
          for (final m in j['dayMappings'] as List? ?? const [])
            DayMappingDto.fromJson(m as Map<String, dynamic>),
        ],
        blockUpdatedAt: DateTime.parse(j['blockUpdatedAt'] as String),
      );
}

class WeekDto {
  const WeekDto({required this.weekNumber, required this.days});

  final int weekNumber;

  /// Ya vienen en el orden del coach (DisplayOrder).
  final List<DayDto> days;

  factory WeekDto.fromJson(Map<String, dynamic> j) => WeekDto(
    weekNumber: j['weekNumber'] as int,
    days: [
      for (final d in j['days'] as List? ?? const [])
        DayDto.fromJson(d as Map<String, dynamic>),
    ],
  );
}

enum SessionStatus {
  pending,
  inProgress,
  completed;

  static SessionStatus parse(String? s) => switch (s) {
    'in_progress' => inProgress,
    'completed' => completed,
    _ => pending,
  };
}

class DayDto {
  const DayDto({
    required this.id,
    required this.dayNumber,
    required this.name,
    required this.sessionStatus,
    required this.workoutSessionId,
    required this.exercises,
    this.startedAt,
    this.completedAt,
  });

  final String id;
  final int dayNumber;
  final String? name;
  final SessionStatus sessionStatus;
  final String? workoutSessionId;
  final List<DayExerciseDto> exercises;

  /// Según la API: primera serie que llegó y cuándo se completó (hora del
  /// servidor; si el entreno se hizo sin conexión puede ser más tarde).
  final DateTime? startedAt;
  final DateTime? completedAt;

  /// "Día 3 · Espalda y bíceps" (o solo "Día 3" si el coach no le puso nombre).
  String get title {
    final n = name?.trim();
    return n == null || n.isEmpty ? 'Día $dayNumber' : 'Día $dayNumber · $n';
  }

  DayDto withStatus(
    SessionStatus status, {
    DateTime? startedAt,
    DateTime? completedAt,
  }) => DayDto(
    id: id,
    dayNumber: dayNumber,
    name: name,
    sessionStatus: status,
    workoutSessionId: workoutSessionId,
    exercises: exercises,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
  );

  int get supersetCount => exercises
      .map((e) => e.supersetGroupId)
      .whereType<String>()
      .toSet()
      .length;

  /// Ejercicios donde el coach pidió video en al menos una serie.
  int get videoRequestCount => exercises.where((e) => e.requestsVideo).length;

  factory DayDto.fromJson(Map<String, dynamic> j) => DayDto(
    id: j['id'] as String,
    dayNumber: j['dayNumber'] as int,
    name: j['name'] as String?,
    sessionStatus: SessionStatus.parse(j['sessionStatus'] as String?),
    workoutSessionId: j['workoutSessionId'] as String?,
    exercises: [
      for (final e in j['exercises'] as List? ?? const [])
        DayExerciseDto.fromJson(e as Map<String, dynamic>),
    ],
    startedAt: _dateTime(j['startedAt']),
    completedAt: _dateTime(j['completedAt']),
  );
}

class DayExerciseDto {
  const DayExerciseDto({
    required this.id,
    required this.exerciseName,
    required this.supersetGroupId,
    this.coachNote,
    this.athleteNote,
    this.targetSets = const [],
    this.loggedSets = const [],
  });

  /// BlockDayExerciseId: clave de los logs de este ejercicio en este día.
  final String id;
  final String exerciseName;
  final String? supersetGroupId;
  final String? coachNote;

  /// Nota que dejó el atleta en este ejercicio (ExerciseLog.AthleteNote).
  final String? athleteNote;
  final List<TargetSetDto> targetSets;

  /// Series ya guardadas en la API (de este u otro teléfono).
  final List<LoggedSetDto> loggedSets;

  bool get requestsVideo => targetSets.any((s) => s.requestVideo);

  factory DayExerciseDto.fromJson(Map<String, dynamic> j) => DayExerciseDto(
    id: j['id'] as String,
    exerciseName: j['exerciseName'] as String,
    supersetGroupId: j['supersetGroupId'] as String?,
    coachNote: j['coachNote'] as String?,
    athleteNote: j['athleteNote'] as String?,
    targetSets: [
      for (final s in j['targetSets'] as List? ?? const [])
        TargetSetDto.fromJson(s as Map<String, dynamic>),
    ]..sort((a, b) => a.setNumber.compareTo(b.setNumber)),
    loggedSets: [
      for (final s in j['actualSets'] as List? ?? const [])
        LoggedSetDto.fromJson(s as Map<String, dynamic>),
    ],
  );
}

/// Prescripción del coach para una serie. [weightKg] siempre en kg.
class TargetSetDto {
  const TargetSetDto({
    required this.setNumber,
    this.weightKg,
    this.reps,
    this.rir,
    this.requestVideo = false,
  });

  final int setNumber;
  final double? weightKg;
  final int? reps;
  final int? rir;
  final bool requestVideo;

  factory TargetSetDto.fromJson(Map<String, dynamic> j) => TargetSetDto(
    setNumber: j['setNumber'] as int,
    weightKg: (j['weight'] as num?)?.toDouble(),
    reps: j['reps'] as int?,
    rir: j['rir'] as int?,
    requestVideo: j['requestVideo'] == true,
  );
}

/// Serie registrada en la API. [weightKg] en kg; [weightUnit] = como la cargó.
class LoggedSetDto {
  const LoggedSetDto({
    required this.setNumber,
    this.weightKg,
    required this.weightUnit,
    this.reps,
    this.rir,
    this.videoUrl,
  });

  final int setNumber;
  final double? weightKg;
  final String weightUnit;
  final int? reps;
  final int? rir;

  /// Video ya subido de esta serie.
  final String? videoUrl;

  factory LoggedSetDto.fromJson(Map<String, dynamic> j) => LoggedSetDto(
    setNumber: j['setNumber'] as int,
    weightKg: (j['weight'] as num?)?.toDouble(),
    weightUnit: j['weightUnit'] as String? ?? 'KG',
    reps: j['reps'] as int?,
    rir: j['rir'] as int?,
    videoUrl: j['videoUrl'] as String?,
  );
}

/// Qué día de la semana se hace cada entreno; se repite todas las semanas.
class DayMappingDto {
  const DayMappingDto({required this.dayNumber, required this.weekDay});

  final int dayNumber;

  /// 1 = lunes … 7 = domingo (mismo criterio que DateTime.weekday).
  final int weekDay;

  static const _codes = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  /// 1 → "MON" … 7 → "SUN" (como lo espera la API).
  static String codeOf(int weekDay) => _codes[weekDay - 1];

  factory DayMappingDto.fromJson(Map<String, dynamic> j) => DayMappingDto(
    dayNumber: j['dayNumber'] as int,
    weekDay: _codes.indexOf(j['weekDay'] as String) + 1,
  );
}
