import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_me_provider.dart';
import '../../program/data/assignment_dtos.dart';
import '../../program/data/program_schedule.dart';
import '../../program/providers/program_providers.dart';
import '../data/adherence.dart';
import '../data/records.dart';
import '../data/streak_dto.dart';

part 'profile_providers.g.dart';

/// Tarjeta Adherencia del Perfil, sobre el programa en curso (con las
/// sesiones del teléfono). [due] null = programa sin calendario: solo hay
/// hechos / total.
typedef ProgramAdherence = ({int done, int? due, int total});

@riverpod
Future<ProgramAdherence?> currentAdherence(Ref ref) async {
  final current = (await ref.watch(programSectionsProvider.future)).current;
  if (current == null) return null;
  final p = await ref.watch(
    programWithLocalProvider(current.assignmentId).future,
  );
  final (done, total) = dayCountsOf(p);
  final a = adherenceOf(p, dateOnly(DateTime.now()));
  return a == null
      ? (done: done, due: null, total: total)
      : (done: a.$1, due: a.$2, total: total);
}

/// Pantalla Adherencia: el programa en curso + el anterior (para comparar).
/// null si no hay programa en curso.
@riverpod
Future<({AdherenceReport report, AssignmentSummaryDto? previous})?>
adherenceDetail(Ref ref) async {
  final sections = await ref.watch(programSectionsProvider.future);
  final current = sections.current;
  if (current == null) return null;
  final p = await ref.watch(
    programWithLocalProvider(current.assignmentId).future,
  );
  return (
    report: adherenceReport(p, dateOnly(DateTime.now())),
    previous: sections.past.where((x) => x.totalDays > 0).firstOrNull,
  );
}

/// Racha de semanas (tarjeta del Perfil). Necesita red; sin ella la tarjeta
/// no se muestra.
@riverpod
Future<StreakDto> streak(Ref ref) async {
  final me = await ref.watch(authMeProvider.future);
  return ref.watch(streakRepositoryProvider).get(me.userId);
}

/// Récords personales (tarjeta del Perfil y pantalla Récords). Necesita red.
@riverpod
Future<List<PersonalRecordDto>> records(Ref ref) async {
  final me = await ref.watch(authMeProvider.future);
  return ref.watch(recordsRepositoryProvider).get(me.userId);
}

/// Programa en curso (para "Este bloque"); null si no hay.
@riverpod
Future<String?> currentAssignmentId(Ref ref) async =>
    (await ref.watch(programSectionsProvider.future)).current?.assignmentId;
