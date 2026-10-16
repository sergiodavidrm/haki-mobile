import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../program/data/assignment_dtos.dart';
import '../../program/data/program_schedule.dart';
import '../../program/providers/program_providers.dart';
import '../../session/providers/session_providers.dart';

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
  const WithProgram({required this.program, required this.plan});

  final AssignmentDetailDto program;
  final TodayPlan plan;
}

@riverpod
Future<TodayState> today(Ref ref) async {
  final sections = await ref.watch(programSectionsProvider.future);
  if (sections.current == null) {
    return sections.upcoming.isEmpty
        ? const NoProgram()
        : OnlyUpcoming(sections.upcoming.first);
  }
  final remote = (await ref.watch(currentProgramDetailProvider.future))!;

  // Lo registrado en el teléfono manda (puede no haber llegado a la API todavía)
  final local = await ref.watch(
    localSessionsOfProvider(remote.assignmentId).future,
  );
  final program = remote.withDayStatuses(
    {
      for (final s in local)
        s.dayId: s.completedAt != null
            ? SessionStatus.completed
            : SessionStatus.inProgress,
    }..removeWhere(
      (dayId, status) =>
          _serverCompleted(remote, dayId) && status != SessionStatus.completed,
    ),
  );

  return WithProgram(
    program: program,
    plan: resolveToday(program, DateTime.now()),
  );
}

bool _serverCompleted(AssignmentDetailDto p, String dayId) => p.weeks
    .expand((w) => w.days)
    .any((d) => d.id == dayId && d.sessionStatus == SessionStatus.completed);
