import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/dashed_border.dart';
import '../../home/ui/today_widgets.dart';
import '../data/assignment_dtos.dart';
import '../data/program_schedule.dart';
import '../providers/program_providers.dart';
import 'program_widgets.dart';
import 'programs_list_screen.dart';

// Tab Programa: semanas y días del bloque. Sin [assignmentId] muestra el
// programa en curso; con uno (desde "Mis programas") muestra ese, y solo el
// en curso deja entrar a la Sesión.
class ProgramScreen extends ConsumerStatefulWidget {
  const ProgramScreen({super.key, this.assignmentId, this.resetWeek});

  final String? assignmentId;

  /// Si cambia, el selector vuelve a la semana actual (ver
  /// `Routes.programAtCurrentWeek`).
  final String? resetWeek;

  @override
  ConsumerState<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends ConsumerState<ProgramScreen> {
  /// Semana elegida en el selector, por programa (null = la actual).
  int? _week;
  String? _weekOf;

  @override
  void didUpdateWidget(ProgramScreen old) {
    super.didUpdateWidget(old);
    if (old.resetWeek != widget.resetWeek) _week = null;
  }

  @override
  Widget build(BuildContext context) {
    final sections = ref.watch(programSectionsProvider);
    final id = widget.assignmentId ?? sections.value?.current?.assignmentId;

    // Sin programa en curso el tab muestra directo Mis programas
    if (widget.assignmentId == null &&
        sections.hasValue &&
        sections.value!.current == null) {
      return const ProgramsListScreen(asTab: true);
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(programSectionsProvider);
            if (id != null) ref.invalidate(programDetailProvider(id));
            await ref.read(programSectionsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              if (widget.assignmentId == null)
                _TabHeader(onHistory: () => context.push(Routes.programs))
              else
                const BackHeader(title: 'Programa'),
              const SizedBox(height: 18),
              ...switch (sections) {
                AsyncData(:final value) => _body(value, id),
                AsyncError() => [_offline()],
                _ => [_loading()],
              },
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _body(ProgramSections sections, String? id) {
    if (id == null) return const [];
    final detail = ref.watch(programWithLocalProvider(id));
    return switch (detail) {
      AsyncData(:final value) => _program(sections, value),
      AsyncError() => [_offline()],
      _ => [_loading()],
    };
  }

  List<Widget> _program(ProgramSections sections, AssignmentDetailDto p) {
    final now = DateTime.now();
    final id = p.assignmentId;
    final isCurrent = sections.current?.assignmentId == id;
    final finished = sections.isPast(id) || p.status == 'completed';
    final week = finished ? p.totalWeeks : currentWeekOf(p, now);
    if (_weekOf != id) {
      _weekOf = id;
      _week = null;
    }
    final selected = (_week ?? week).clamp(
      1,
      p.totalWeeks < 1 ? 1 : p.totalWeeks,
    );
    final weekDto = p.weeks.where((w) => w.weekNumber == selected).firstOrNull;
    final canSchedule = !finished && p.status == 'active';

    final label = switch ((isCurrent, finished)) {
      (true, _) =>
        p.hasDates
            ? 'Bloque actual · desde ${formatDayMonth(p.startDate!)}'
            : 'Bloque actual · sin fechas',
      (_, true) =>
        p.startDate != null && p.endDate != null
            ? 'Terminado · ${formatDayMonth(p.startDate!)} – ${formatDayMonth(p.endDate!)}'
            : 'Terminado',
      _ =>
        p.hasDates
            ? 'Próximo · desde ${formatDayMonth(p.startDate!)}'
            : 'Próximo · sin fechas',
    };

    return [
      BlockCard(
        label: label,
        program: p,
        week: week,
        finished: finished,
        datesLink: canSchedule
            ? (p.hasDates ? 'Cambiar fechas' : 'Asignar fechas')
            : null,
        onDates: () => context.push(Routes.assignDates(id)),
      ),
      const SizedBox(height: 18),
      if (p.totalWeeks > 0) ...[
        WeekTabs(
          total: p.totalWeeks,
          selected: selected,
          onSelect: (w) => setState(() => _week = w),
        ),
        const SizedBox(height: 18),
      ],
      if (weekDto == null || weekDto.days.isEmpty)
        _WeekPreparing()
      else
        for (final row in weekRows(p, weekDto, now, highlightNext: isCurrent))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DayRowTile(
              row: row,
              dated: p.hasDates,
              onTap: switch (row.kind) {
                DayRowKind.done => () => context.push(
                  Routes.pastSession(id, row.day.id),
                ),
                DayRowKind.preparing => null,
                _ when isCurrent => () => context.push(
                  Routes.session(id, row.day.id),
                ),
                _ => null,
              },
            ),
          ),
      const SizedBox(height: 8),
      if (widget.assignmentId == null)
        AllProgramsLink(
          count: sections.count,
          onTap: () => context.push(Routes.programs),
        ),
    ];
  }

  Widget _offline() => const TodayInfoCard(
    label: 'Sin conexión',
    title: 'No pudimos cargar tu programa',
    body: 'Revisá tu conexión y deslizá hacia abajo para reintentar.',
  );

  Widget _loading() => const Padding(
    padding: EdgeInsets.only(top: 48),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _TabHeader extends StatelessWidget {
  const _TabHeader({required this.onHistory});

  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            'Programa',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: c.text,
            ),
          ),
        ),
        Material(
          color: c.surfaceHigh,
          shape: CircleBorder(side: BorderSide(color: c.border)),
          child: IconButton(
            tooltip: 'Todos mis programas',
            onPressed: onHistory,
            icon: Icon(Icons.history, size: 20, color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _WeekPreparing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DashedBorder(
      color: c.border,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          'Tu coach está preparando esta semana.',
          style: TextStyle(fontSize: 14, color: c.textMuted),
        ),
      ),
    );
  }
}
