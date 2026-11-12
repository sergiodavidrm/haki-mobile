import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../program/data/assignment_dtos.dart';
import '../../program/data/program_schedule.dart';
import '../../program/providers/program_providers.dart';

part 'today_provider.g.dart';

/// Lo que muestra la pantalla Hoy.
sealed class TodayState {
  const TodayState();
}

/// El coach todavía no le activó ningún programa.
class NoProgram extends TodayState {
  const NoProgram();
}

/// Solo hay programas con fecha de inicio futura.
class OnlyUpcoming extends TodayState {
  const OnlyUpcoming(this.next);

  final AssignmentSummaryDto next;
}

class WithProgram extends TodayState {
  const WithProgram({
    required this.program,
    required this.plan,
    this.others = const [],
  });

  final AssignmentDetailDto program;
  final TodayPlan plan;

  /// Programas en paralelo (2026-11-11): los demás en curso, en orden de
  /// activación. Hoy muestra una tarjeta por programa.
  final List<AssignmentDetailDto> others;

  List<AssignmentDetailDto> get all => [program, ...others];
}

@riverpod
Future<TodayState> today(Ref ref) async {
  final sections = await ref.watch(programSectionsProvider.future);
  if (sections.current == null) {
    return sections.upcoming.isEmpty
        ? const NoProgram()
        : OnlyUpcoming(sections.upcoming.first);
  }
  // Con las sesiones del teléfono (pueden no haber llegado a la API todavía)
  final programs = [
    for (final a in sections.currents)
      await ref.watch(programWithLocalProvider(a.assignmentId).future),
  ];

  return WithProgram(
    program: programs.first,
    plan: resolveToday(programs.first, DateTime.now()),
    others: programs.skip(1).toList(),
  );
}
