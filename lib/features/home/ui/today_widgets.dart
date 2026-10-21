import 'package:flutter/material.dart';

import '../../../core/format/dates.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/pill_chip.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/segmented_progress.dart';
import '../../program/data/assignment_dtos.dart';
import '../../program/data/program_schedule.dart';

/// Tira L–D de la semana (programas con fechas por día). Punto = hay entreno;
/// relleno turquesa = hecho; dorado = hoy.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.days});

  final List<StripDay> days;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final d in days)
          Semantics(
            label:
                '${formatShortDate(d.date)}: ${switch (d.kind) {
                  StripDayKind.done => 'entreno hecho',
                  StripDayKind.planned => 'entreno',
                  StripDayKind.none => 'sin entreno',
                }}',
            excludeSemantics: true,
            child: SizedBox(
              width: 44,
              child: Column(
                children: [
                  Text(
                    weekdayInitial(d.date),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: d.isToday ? c.goldBright : c.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: d.isToday
                          ? c.gold
                          : (d.kind == StripDayKind.done
                                ? c.turquoiseSurface
                                : Colors.transparent),
                    ),
                    child: Text(
                      '${d.date.day}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: d.isToday
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: d.isToday
                            ? c.onAccent
                            : (d.kind == StripDayKind.done
                                  ? c.turquoise
                                  : c.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: switch (d.kind) {
                        StripDayKind.done => c.turquoise,
                        StripDayKind.planned =>
                          d.isToday ? c.goldBright : Colors.transparent,
                        StripDayKind.none => Colors.transparent,
                      },
                      border: d.kind == StripDayKind.planned && !d.isToday
                          ? Border.all(color: c.goldBright)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// "Semana 2 del programa · 2 de 4 entrenos" (programas sin día de la semana
/// asignado). Es la semana del programa, no la del calendario: la racha del
/// Perfil cuenta por semana de calendario y por eso pueden no coincidir.
class WeekProgressCard extends StatelessWidget {
  const WeekProgressCard({super.key, required this.week});

  final WeekDto week;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = week.days
        .where((d) => d.sessionStatus == SessionStatus.completed)
        .length;
    return HakiCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Semana ${week.weekNumber} del programa',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: c.text,
                ),
              ),
              Text(
                '$done de ${week.days.length} entrenos',
                style: TextStyle(fontSize: 13, color: c.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedProgress(total: week.days.length, done: done),
        ],
      ),
    );
  }
}

/// Tarjeta grande de Hoy para un día con entreno.
class TrainingDayCard extends StatelessWidget {
  const TrainingDayCard({
    super.key,
    required this.program,
    required this.plan,
    required this.onStart,
  });

  final AssignmentDetailDto program;
  final TrainingDay plan;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final day = plan.day;
    final label =
        '${plan.isScheduledToday ? 'Hoy' : 'Siguiente'} · Semana ${plan.week.weekNumber} de ${program.totalWeeks}';

    return HakiCard(
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(label, color: c.goldBright),
          const SizedBox(height: 14),
          Text(
            day.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: c.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            program.blockName,
            style: TextStyle(fontSize: 14, color: c.textMuted),
          ),
          const SizedBox(height: 14),
          if (day.exercises.isEmpty)
            Text(
              'Tu coach lo está preparando.',
              style: TextStyle(fontSize: 14, color: c.textSecondary),
            )
          else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PillChip(
                  '${day.exercises.length} ${day.exercises.length == 1 ? 'ejercicio' : 'ejercicios'}',
                ),
                if (day.supersetCount > 0)
                  PillChip(
                    '${day.supersetCount} ${day.supersetCount == 1 ? 'superserie' : 'superseries'}',
                    tone: PillTone.turquoise,
                  ),
                if (day.videoRequestCount > 0)
                  PillChip(
                    '${day.videoRequestCount} ${day.videoRequestCount == 1 ? 'video pedido' : 'videos pedidos'}',
                    tone: PillTone.gold,
                    icon: Icons.videocam_outlined,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            switch (day.sessionStatus) {
              SessionStatus.completed => Row(
                children: [
                  Icon(Icons.check_circle, color: c.turquoise, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Entreno completado',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: c.turquoise,
                    ),
                  ),
                ],
              ),
              SessionStatus.inProgress => FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Continuar entreno'),
              ),
              SessionStatus.pending => FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Empezar entreno'),
              ),
            },
          ],
        ],
      ),
    );
  }
}

/// Tarjeta de Hoy sin entreno: descanso, semana completa, programa terminado,
/// sin programa, etc.
class TodayInfoCard extends StatelessWidget {
  const TodayInfoCard({
    super.key,
    required this.label,
    required this.title,
    this.body,
  });

  final String label;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return HakiCard(
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label, color: c.goldBright),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: c.text,
            ),
          ),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(
              body!,
              style: TextStyle(fontSize: 14, height: 1.45, color: c.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
