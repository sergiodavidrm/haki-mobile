import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_me_provider.dart';
import '../data/exercise_history.dart';

part 'exercise_providers.g.dart';

/// Historial de un ejercicio del catálogo. Necesita red; sin conexión el
/// Detalle muestra solo lo del programa (hoy + "última vez").
@riverpod
Future<List<ExerciseHistoryEntryDto>> exerciseHistory(
  Ref ref,
  String exerciseId,
) async {
  final me = await ref.watch(authMeProvider.future);
  return ref
      .watch(exerciseHistoryRepositoryProvider)
      .get(me.userId, exerciseId);
}
