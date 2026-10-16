import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_me_provider.dart';
import '../data/assignment_dtos.dart';
import '../data/program_repository.dart';
import '../data/program_schedule.dart';

part 'program_providers.g.dart';

/// Programas del atleta clasificados en EN CURSO / PRÓXIMO / ANTERIORES.
@riverpod
Future<ProgramSections> programSections(Ref ref) async {
  final me = await ref.watch(authMeProvider.future);
  final all = await ref
      .watch(programRepositoryProvider)
      .getAssignments(me.userId);
  return classifyPrograms(all, DateTime.now());
}

/// Detalle (semanas, días, ejercicios) del programa en curso; null si no hay.
@riverpod
Future<AssignmentDetailDto?> currentProgramDetail(Ref ref) async {
  final current = (await ref.watch(programSectionsProvider.future)).current;
  if (current == null) return null;
  return ref.watch(programRepositoryProvider).getDetail(current.assignmentId);
}
