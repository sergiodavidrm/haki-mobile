import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/units/weight_unit.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../data/body_log_dto.dart';
import '../data/body_log_repository.dart';

part 'body_providers.g.dart';

// Peso y medidas del atleta. Necesitan red (no van offline como el entreno).

@riverpod
Future<List<BodyLogDto>> bodyLogs(Ref ref) async {
  final me = await ref.watch(authMeProvider.future);
  return ref.watch(bodyLogRepositoryProvider).getHistory(me.userId);
}

/// Unidad en que el atleta ve y carga su peso corporal.
@riverpod
WeightUnit bodyWeightUnit(Ref ref) =>
    ref.watch(authMeProvider).value?.preferredWeightUnit ?? WeightUnit.kg;

/// Guardar peso o medidas. El estado es el guardado en curso (loading /
/// error con el mensaje de la API).
@riverpod
class BodyLogSaver extends _$BodyLogSaver {
  @override
  FutureOr<void> build() {}

  /// true si se guardó. Refresca el historial.
  Future<bool> save({
    required DateTime date,
    double? weight,
    Map<String, double> measures = const {},
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(bodyLogRepositoryProvider)
          .save(
            date: date,
            unit: ref.read(bodyWeightUnitProvider),
            weight: weight,
            measures: measures,
          );
      ref.invalidate(bodyLogsProvider);
    });
    return !state.hasError;
  }
}
