import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../program/data/program_schedule.dart';
import '../../program/providers/program_providers.dart';

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
