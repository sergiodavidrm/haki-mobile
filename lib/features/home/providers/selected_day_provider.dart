import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../program/data/program_schedule.dart';

part 'selected_day_provider.g.dart';

/// Día elegido en la tira de Hoy. null = hoy (así, si la app queda abierta y
/// cambia la fecha, sigue mostrando el día de hoy).
@riverpod
class SelectedDay extends _$SelectedDay {
  @override
  DateTime? build() => null;

  void select(DateTime day) {
    final d = dateOnly(day);
    state = d == dateOnly(DateTime.now()) ? null : d;
  }

  void reset() => state = null;
}
