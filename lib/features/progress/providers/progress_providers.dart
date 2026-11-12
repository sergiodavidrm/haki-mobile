import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/cache/api_cache.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../data/progress_report.dart';

part 'progress_providers.g.dart';

/// Período de "Tu progreso" (lo comparten la lista y los detalles).
@Riverpod(keepAlive: true)
class SelectedProgressPeriod extends _$SelectedProgressPeriod {
  @override
  ProgressPeriod build() => ProgressPeriod.block;

  void set(ProgressPeriod p) => state = p;
}

/// Programas en paralelo (2026-11-11): programa elegido para "Este bloque"
/// (null = el primero en curso).
@Riverpod(keepAlive: true)
class SelectedProgressProgram extends _$SelectedProgressProgram {
  @override
  String? build() => null;

  void set(String? assignmentId) => state = assignmentId;
}

/// Reporte del período, con caché (se ve sin señal con la última copia).
/// [program] = programa de "Este bloque" cuando hay varios en curso.
@riverpod
Future<ProgressReport> progressReport(
  Ref ref,
  ProgressPeriod period, [
  String? program,
]) async {
  final me = await ref.watch(authMeProvider.future);
  final assignment = period == ProgressPeriod.block && program != null
      ? '&assignmentId=$program'
      : '';
  return ref
      .watch(apiCacheProvider)
      .get(
        '/progress/${me.userId}/performance-report?${period.query}$assignment',
        (j) => ProgressReport.fromJson(j as Map<String, dynamic>),
        onUpdated: () {
          if (ref.mounted) ref.invalidateSelf();
        },
      );
}

/// Ejercicios que el atleta ocultó con el ojito (por usuario, en el teléfono).
@Riverpod(keepAlive: true)
class HiddenExercises extends _$HiddenExercises {
  static const _prefix = 'progress_hidden_exercises_';

  @override
  Future<Set<String>> build() async {
    final me = await ref.watch(authMeProvider.future);
    final list = await SharedPreferencesAsync().getStringList(
      _prefix + me.userId,
    );
    return {...?list};
  }

  Future<void> toggle(String exerciseId) async {
    final me = await ref.read(authMeProvider.future);
    final current = {...(state.value ?? const <String>{})};
    if (!current.remove(exerciseId)) current.add(exerciseId);
    state = AsyncData(current);
    await SharedPreferencesAsync().setStringList(
      _prefix + me.userId,
      current.toList(),
    );
  }
}
