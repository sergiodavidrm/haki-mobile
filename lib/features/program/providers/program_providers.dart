import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/cache/api_cache.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../../session/data/session_plan.dart';
import '../../session/data/session_store.dart';
import '../data/assignment_dtos.dart';
import '../data/program_repository.dart';
import '../data/program_schedule.dart';
import 'program_refresher.dart';

part 'program_providers.g.dart';

/// Programas del atleta clasificados en EN CURSO / PRÓXIMO / ANTERIORES.
@riverpod
Future<ProgramSections> programSections(Ref ref) async {
  final me = await ref.watch(authMeProvider.future);
  final all = await ref
      .watch(programRepositoryProvider)
      .getAssignments(me.userId, onUpdated: () => _reload(ref));
  return classifyPrograms(all, DateTime.now());
}

/// Detalle (semanas, días, ejercicios) de un programa, tal como lo da la API.
@riverpod
Future<AssignmentDetailDto> programDetail(Ref ref, String assignmentId) => ref
    .watch(programRepositoryProvider)
    .getDetail(assignmentId, onUpdated: () => _reload(ref));

/// La API devolvió algo distinto a la copia que se mostró: recargar, salvo
/// durante un entreno (no se le cambia el día en pantalla al atleta; lo nuevo
/// ya quedó guardado y se ve al salir).
void _reload(Ref ref) {
  if (!ref.mounted || isTraining(ref)) return;
  ref.invalidateSelf();
}

/// Detalle del programa en curso; null si no hay.
@riverpod
Future<AssignmentDetailDto?> currentProgramDetail(Ref ref) async {
  final current = (await ref.watch(programSectionsProvider.future)).current;
  if (current == null) return null;
  return ref.watch(programDetailProvider(current.assignmentId).future);
}

/// Detalle con el estado de los días pisado por lo registrado en el teléfono
/// (puede no haber llegado a la API todavía). Lo usan Hoy y Programa.
@riverpod
Future<AssignmentDetailDto> programWithLocal(
  Ref ref,
  String assignmentId,
) async {
  final remote = await ref.watch(programDetailProvider(assignmentId).future);
  final local = await ref.watch(
    _localSessionsStreamProvider(assignmentId).future,
  );
  final sets = await ref.watch(_localSetsStreamProvider(assignmentId).future);
  return mergeLocalSessions(remote, local, {
    for (final s in sets) setKey(s.dayExerciseId, s.setNumber): s,
  });
}

@riverpod
Stream<List<LocalSetEntry>> _localSetsStream(Ref ref, String assignmentId) =>
    ref.watch(sessionStoreProvider).watchSetsOf(assignmentId);

@riverpod
Stream<List<LocalSessionInfo>> _localSessionsStream(
  Ref ref,
  String assignmentId,
) => ref.watch(sessionStoreProvider).watchSessionsOf(assignmentId);

/// Lo local manda, salvo que la API ya tenga el día completado y en el
/// teléfono figure solo empezado (se completó desde otro lado). Los días
/// completados llevan sus series hechas / totales ([sets] = series del
/// teléfono por `setKey`), para mostrar el día parcial.
AssignmentDetailDto mergeLocalSessions(
  AssignmentDetailDto remote,
  List<LocalSessionInfo> local, [
  Map<String, LocalSetEntry> sets = const {},
]) {
  final byDay = {for (final s in local) s.dayId: s};
  DayDto merged(DayDto d) {
    final s = byDay[d.id];
    if (s == null) return d;
    if (s.completedAt == null) {
      return d.sessionStatus == SessionStatus.completed
          ? d
          : d.withStatus(SessionStatus.inProgress, startedAt: s.startedAt);
    }
    return d.withStatus(
      SessionStatus.completed,
      startedAt: s.startedAt,
      completedAt: s.completedAt,
    );
  }

  return remote.mapDays((d) {
    final m = merged(d);
    if (m.sessionStatus != SessionStatus.completed) return m;
    final p = setProgressOf(m.exercises, sets);
    return m.withSetProgress(p.done, p.total);
  });
}

/// Guardar fechas desde "Asignar fechas". El estado es el guardado en curso
/// (loading / error con el mensaje de la API).
@riverpod
class ScheduleSaver extends _$ScheduleSaver {
  @override
  FutureOr<void> build() {}

  /// true si se guardó. Refresca la lista de programas y el detalle.
  Future<bool> save(
    String assignmentId,
    DateTime start,
    Map<int, int> weekDays, {
    int fromWeek = 1,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(programRepositoryProvider)
          .schedule(assignmentId, start, weekDays, fromWeek: fromWeek);
      // Que Hoy y Programa lean la API y no la copia (con las fechas viejas):
      // sin esto había que hacer pull-to-refresh para ver el cambio
      ref.read(apiCacheProvider).expire(wait: true);
      ref.invalidate(programSectionsProvider);
      ref.invalidate(programDetailProvider(assignmentId));
    });
    return !state.hasError;
  }
}
