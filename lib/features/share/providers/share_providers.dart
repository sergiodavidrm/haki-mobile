import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/units/weight_unit.dart';
import '../../body/providers/body_providers.dart';
import '../../profile/data/records.dart';
import '../../profile/providers/profile_providers.dart';
import '../../program/data/assignment_dtos.dart';
import '../../program/data/program_schedule.dart';
import '../../program/providers/program_providers.dart';
import '../../session/data/session_plan.dart';
import '../../session/data/session_store.dart';
import '../../session/data/workout_prs.dart';
import '../data/share_stickers.dart';

part 'share_providers.g.dart';

const _shareKey = 'share_workouts';

/// Ajustes → Compartir entrenos (2026-11-12, Sergio): sin activarlo no aparece
/// el botón Compartir. Preferencia del teléfono, arranca apagado.
@Riverpod(keepAlive: true)
class ShareWorkoutsEnabled extends _$ShareWorkoutsEnabled {
  @override
  bool build() {
    unawaited(_load());
    return false;
  }

  Future<void> _load() async {
    final saved = await SharedPreferencesAsync().getBool(_shareKey);
    if (saved != null) state = saved;
  }

  void set(bool on) {
    state = on;
    unawaited(SharedPreferencesAsync().setBool(_shareKey, on));
  }
}

/// Series del teléfono de un programa entero, por `setKey`.
@riverpod
Stream<Map<String, LocalSetEntry>> assignmentLocalSets(
  Ref ref,
  String assignmentId,
) => ref
    .watch(sessionStoreProvider)
    .watchSetsOf(assignmentId)
    .map((l) => {for (final s in l) setKey(s.dayExerciseId, s.setNumber): s});

class ShareData {
  const ShareData({
    required this.day,
    required this.week,
    required this.month,
    required this.initial,
    required this.unit,
  });

  /// null = todavía no hay ningún entreno hecho (sin pestaña Día)
  final ShareDayData? day;
  final ShareWeekData week;
  final ShareMonthData month;

  /// Pestaña con la que abre
  final SharePeriod initial;
  final WeightUnit unit;
}

/// Datos de los stickers. [dayId] vacío = se entró sin un entreno (desde el
/// Perfil): Día muestra el último hecho y abre en Semana. Sin red no hay
/// récords ni racha (el resto sí).
@riverpod
Future<ShareData> shareData(
  Ref ref,
  String assignmentId,
  String dayId,
) async {
  final today = DateTime.now();
  final sections = await ref.watch(programSectionsProvider.future);
  final ids = <String>{
    if (assignmentId.isNotEmpty) assignmentId,
    for (final a in sections.currents) a.assignmentId,
    for (final a in [...sections.past, ...sections.upcoming])
      if (a.completedDays > 0) a.assignmentId,
  };
  final programs = <AssignmentDetailDto>[];
  final locals = <String, Map<String, LocalSetEntry>>{};
  final trained = <TrainedDay>[];
  for (final id in ids) {
    final p = await ref.watch(programWithLocalProvider(id).future);
    final local = await ref.watch(assignmentLocalSetsProvider(id).future);
    programs.add(p);
    locals[id] = local;
    trained.addAll(trainedDaysOf(p, local));
  }

  List<PersonalRecordDto> records;
  try {
    records = await ref.watch(recordsProvider.future);
  } catch (_) {
    records = const [];
  }
  int? streakWeeks;
  try {
    streakWeeks = (await ref.watch(streakProvider.future)).currentWeeks;
  } catch (_) {
    streakWeeks = null;
  }

  // Día: el de la pantalla de donde vino, o el último hecho
  TrainedDay? t;
  if (dayId.isNotEmpty) {
    t = trained.where((x) => x.day.id == dayId).firstOrNull;
  }
  t ??= ([...trained]..sort((a, b) => b.date.compareTo(a.date))).firstOrNull;
  ShareDayData? day;
  if (t != null) {
    final local = locals[t.assignmentId] ?? const {};
    day = buildShareDay(
      program: programs.firstWhere((p) => p.assignmentId == t!.assignmentId),
      trained: t,
      local: local,
      prs: workoutPrs(t.day.exercises, local, records, trainedOn: t.date),
      sameDayLastWeek: sameDayLastWeekOf(t, trained),
    );
  }

  final fromDay = dayId.isNotEmpty && t != null;
  final mainId = fromDay ? t.assignmentId : sections.current?.assignmentId;
  final week = buildShareWeek(
    start: fromDay ? mondayOf(t.date) : weekToShare(today, trained, today),
    today: today,
    programs: [
      for (final p in programs)
        if (sections.isCurrent(p.assignmentId) || p.assignmentId == mainId) p,
    ],
    trained: trained,
    records: records,
    mainProgram: programs
        .where((p) => p.assignmentId == mainId)
        .firstOrNull,
    streakWeeks: streakWeeks,
  );

  // Abre en Semana si este entreno cerró la semana (o si no vino de un entreno)
  final closedWeek =
      fromDay &&
      week.complete &&
      !trained.any(
        (x) => x.date.isAfter(t!.date) && !x.date.isBefore(week.start),
      );
  return ShareData(
    day: day,
    week: week,
    month: buildShareMonth(today: dateOnly(today), trained: trained, records: records),
    initial: !fromDay || closedWeek ? SharePeriod.week : SharePeriod.day,
    unit: ref.watch(bodyWeightUnitProvider),
  );
}
