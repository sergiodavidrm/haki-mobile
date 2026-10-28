import '../../../core/units/weight_unit.dart';
import '../../program/data/assignment_dtos.dart';
import 'session_store.dart';

// Lógica pura de la sesión (sin Flutter): agrupar superseries, orden de las
// series, qué toca después de guardar una y el resumen del entreno.

/// Serie ya guardada (local o en la API), con el peso en [unit].
class SavedSet {
  const SavedSet({
    this.weight,
    required this.unit,
    this.reps,
    this.rir,
    required this.synced,
    this.hasVideo = false,
    this.videoUploading = false,
    this.setLogId,
  });

  final double? weight;
  final WeightUnit unit;
  final int? reps;
  final int? rir;

  /// false = guardada en el teléfono, todavía no llegó a la API.
  final bool synced;

  /// Ya tiene video subido (lo dice la API o la cola del teléfono).
  final bool hasVideo;

  /// Tiene un video en la cola del teléfono, todavía sin subir.
  final bool videoUploading;

  /// Id del set-log si la serie ya está en la API (para subirle el video).
  final String? setLogId;
}

String setKey(String dayExerciseId, int setNumber) =>
    '$dayExerciseId#$setNumber';

/// Lo local gana sobre lo que vino de la API (puede estar más nuevo).
/// [videos] = cola de videos del teléfono (true = ya subido).
SavedSet? savedSetFor(
  DayExerciseDto e,
  int setNumber,
  Map<String, LocalSetEntry> local, [
  Map<String, bool> videos = const {},
]) {
  final key = setKey(e.id, setNumber);
  final l = local[key];
  final r = e.loggedSets.where((x) => x.setNumber == setNumber).firstOrNull;
  final queued = videos[key];
  final hasVideo = r?.videoUrl != null || queued == true;
  final videoUploading = queued == false;
  if (l != null) {
    return SavedSet(
      weight: l.weight,
      unit: l.unit,
      reps: l.reps,
      rir: l.rir,
      synced: l.synced,
      hasVideo: hasVideo,
      videoUploading: videoUploading,
      setLogId: r?.id,
    );
  }
  if (r == null) return null;
  final u = WeightUnit.parse(r.weightUnit);
  return SavedSet(
    weight: r.weightKg == null ? null : u.fromKg(r.weightKg!),
    unit: u,
    reps: r.reps,
    rir: r.rir,
    synced: true,
    hasVideo: hasVideo,
    videoUploading: videoUploading,
    setLogId: r.id,
  );
}

/// Filas de series de un ejercicio: las prescritas, o más si ya se cargaron
/// más (de otro teléfono); mínimo 1.
int setCountOf(DayExerciseDto e) {
  var n = e.targetSets.length;
  for (final s in e.loggedSets) {
    if (s.setNumber > n) n = s.setNumber;
  }
  return n == 0 ? 1 : n;
}

class ExerciseGroup {
  ExerciseGroup(this.letter, this.exercises);

  /// null = ejercicio suelto; "A", "B"… = superserie.
  final String? letter;
  final List<DayExerciseDto> exercises;

  /// "A1", "A2"… dentro de una superserie.
  String? badgeOf(DayExerciseDto e) =>
      letter == null ? null : '$letter${exercises.indexOf(e) + 1}';
}

/// Agrupa ejercicios consecutivos con el mismo supersetGroupId.
List<ExerciseGroup> groupSupersets(List<DayExerciseDto> exercises) {
  final groups = <ExerciseGroup>[];
  var nextLetter = 'A'.codeUnitAt(0);
  for (final e in exercises) {
    final last = groups.lastOrNull;
    if (e.supersetGroupId != null &&
        last != null &&
        last.letter != null &&
        last.exercises.first.supersetGroupId == e.supersetGroupId) {
      last.exercises.add(e);
    } else if (e.supersetGroupId != null) {
      groups.add(ExerciseGroup(String.fromCharCode(nextLetter++), [e]));
    } else {
      groups.add(ExerciseGroup(null, [e]));
    }
  }
  // Una "superserie" de un solo ejercicio se muestra como ejercicio suelto
  return [
    for (final g in groups)
      g.exercises.length == 1 ? ExerciseGroup(null, g.exercises) : g,
  ];
}

/// Una serie concreta dentro de la sesión.
class SetRef {
  const SetRef(this.group, this.exercise, this.setNumber);

  final ExerciseGroup group;
  final DayExerciseDto exercise;
  final int setNumber;

  String get key => setKey(exercise.id, setNumber);
  String? get badge => group.badgeOf(exercise);
}

/// Orden en que se hacen las series. Suelto: serie por serie. Superserie:
/// por rondas (A1·1, A2·1, A1·2, A2·2…).
List<SetRef> workOrder(List<ExerciseGroup> groups) => [
  for (final g in groups)
    if (g.letter == null)
      for (var n = 1; n <= setCountOf(g.exercises.single); n++)
        SetRef(g, g.exercises.single, n)
    else
      for (
        var n = 1;
        n <= g.exercises.map(setCountOf).reduce((a, b) => a > b ? a : b);
        n++
      )
        for (final e in g.exercises)
          if (n <= setCountOf(e)) SetRef(g, e, n),
];

/// Qué pasa después de guardar una serie.
class AfterSave {
  const AfterSave({required this.rest, this.next});

  /// true = toca descansar (fin de la serie suelta o de la ronda de la superserie).
  final bool rest;

  /// Primera serie pendiente después de la guardada (null = no queda nada).
  final SetRef? next;
}

/// [isSaved] no tiene que incluir todavía la serie recién guardada.
/// Editar una serie que ya estaba guardada no dispara descanso.
AfterSave afterSave(
  List<ExerciseGroup> groups,
  DayExerciseDto exercise,
  int setNumber, {
  required bool wasSaved,
  required bool Function(SetRef) isSaved,
}) {
  final order = workOrder(groups);
  final i = order.indexWhere(
    (r) => r.exercise.id == exercise.id && r.setNumber == setNumber,
  );
  if (i < 0) return const AfterSave(rest: false);
  final current = order[i];
  bool pending(SetRef r) => r.key != current.key && !isSaved(r);

  final next =
      order.skip(i + 1).where(pending).firstOrNull ??
      order.take(i).where(pending).firstOrNull;

  // En superserie se descansa recién al terminar la ronda: cuando ningún
  // ejercicio posterior del grupo tiene esa serie.
  final g = current.group;
  final endOfRound =
      g.letter == null ||
      g.exercises
          .skip(g.exercises.indexOf(exercise) + 1)
          .every((e) => setCountOf(e) < setNumber);

  return AfterSave(rest: !wasSaved && endOfRound && next != null, next: next);
}

/// Resumen para Entreno completado.
class WorkoutSummary {
  const WorkoutSummary({
    required this.duration,
    required this.setsDone,
    required this.setsTotal,
    required this.volume,
    required this.unit,
  });

  /// null = la sesión no se empezó en este teléfono.
  final Duration? duration;
  final int setsDone;
  final int setsTotal;

  /// Σ peso × reps, en [unit].
  final double volume;
  final WeightUnit unit;
}

WorkoutSummary summarize(
  List<DayExerciseDto> exercises,
  Map<String, LocalSetEntry> local, {
  required WeightUnit unit,
  DateTime? startedAt,
  DateTime? completedAt,
}) {
  var done = 0;
  var total = 0;
  var volumeKg = 0.0;
  for (final e in exercises) {
    for (var n = 1; n <= setCountOf(e); n++) {
      total++;
      final s = savedSetFor(e, n, local);
      if (s == null) continue;
      done++;
      if (s.weight != null && s.reps != null) {
        volumeKg += s.unit.toKg(s.weight!) * s.reps!;
      }
    }
  }
  return WorkoutSummary(
    duration: workoutDuration(
      startedAt: startedAt,
      completedAt: completedAt,
      setTimes: [
        for (final s in local.values)
          if (s.savedAt != null) s.savedAt!,
      ],
    ),
    setsDone: done,
    setsTotal: total,
    volume: unit.fromKg(volumeKg),
    unit: unit,
  );
}

/// Más que esto no es un entreno: se dejó abierto y se retomó otro día.
const maxWorkoutDuration = Duration(hours: 4);

/// Margen para contar el arranque y el cierre de la sesión (entrada en calor
/// antes de la primera serie, Finalizar después de la última).
const _edgeSlack = Duration(minutes: 30);

/// Duración del entreno para Entreno completado. startedAt → completedAt
/// daba horas o días si el atleta tocó el día, lo dejó y lo retomó después
/// (se crea la sesión al entrar). Se mide de la primera a la última serie
/// guardada, sumando el arranque y el cierre solo si están cerca; si las
/// series quedaron separadas más de [maxWorkoutDuration], null (sin duración).
Duration? workoutDuration({
  DateTime? startedAt,
  DateTime? completedAt,
  required List<DateTime> setTimes,
}) {
  bool near(DateTime from, DateTime to) {
    final d = to.difference(from);
    return !d.isNegative && d <= _edgeSlack;
  }

  if (setTimes.isEmpty) {
    if (startedAt == null || completedAt == null) return null;
    final d = completedAt.difference(startedAt);
    return d.isNegative || d > maxWorkoutDuration ? null : d;
  }
  final sorted = [...setTimes]..sort();
  final first = sorted.first;
  final last = sorted.last;
  if (last.difference(first) > maxWorkoutDuration) return null;
  final start = startedAt != null && near(startedAt, first) ? startedAt : first;
  final end = completedAt != null && near(last, completedAt)
      ? completedAt
      : last;
  return end.difference(start);
}
