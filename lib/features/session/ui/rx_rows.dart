import 'package:flutter/material.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../l10n/l10n.dart';
import '../../program/data/assignment_dtos.dart';
import '../../program/data/prescription.dart';

// Cardio y Movilidad en la Sesión (mockup "App · Sesión con cardio y
// movilidad"): una fila compacta por ejercicio, toda tocable, con el check de
// 22 px. Sin fondos de color: solo borde + etiqueta (violeta / naranja).

Color kindColor(BuildContext context, String kind) =>
    kind == ExerciseKinds.cardio
    ? context.colors.cardio
    : context.colors.mobility;

Color kindTextColor(BuildContext context, String kind) =>
    kind == ExerciseKinds.cardio
    ? context.colors.cardioText
    : context.colors.mobilityText;

String kindName(BuildContext context, String kind) =>
    kind == ExerciseKinds.cardio
    ? context.l10n.kindCardio
    : context.l10n.kindMobility;

/// Check redondo de 22 px (relleno del color del tipo cuando está hecho).
class RxCheck extends StatelessWidget {
  const RxCheck({super.key, required this.done, required this.color});

  final bool done;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? color : Colors.transparent,
        border: done ? null : Border.all(color: c.border, width: 2),
      ),
      child: done ? Icon(Icons.check, size: 14, color: c.background) : null,
    );
  }
}

/// Fila de movilidad (44 px): check · nombre · "2 × 30 s por lado".
class RxRow extends StatelessWidget {
  const RxRow({
    super.key,
    required this.exercise,
    required this.done,
    required this.onToggle,
    this.divider = true,
  });

  final DayExerciseDto exercise;
  final bool done;
  final VoidCallback? onToggle;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rx = formatPrescription(exercise.kind, exercise.prescription);
    return Semantics(
      button: true,
      toggled: done,
      label: '${exercise.exerciseName}, $rx',
      child: InkWell(
        onTap: onToggle,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          decoration: BoxDecoration(
            border: divider ? Border(top: BorderSide(color: c.border)) : null,
          ),
          child: Row(
            children: [
              RxCheck(done: done, color: kindTextColor(context, exercise.kind)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  exercise.exerciseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: done ? c.textMuted : c.text,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(rx, style: TextStyle(fontSize: 13, color: c.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cardio suelto: una tarjeta-fila "CARDIO · Caminadora · 30 min" + intensidad.
class CardioCard extends StatelessWidget {
  const CardioCard({
    super.key,
    required this.exercise,
    required this.done,
    required this.onToggle,
  });

  final DayExerciseDto exercise;
  final bool done;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rx = exercise.prescription;
    final minutes = formatPrescription(exercise.kind, rx, withIntensity: false);
    final title = [
      exercise.exerciseName,
      if (minutes.isNotEmpty) minutes,
    ].join(' · ');
    final color = kindColor(context, exercise.kind);
    return Semantics(
      button: true,
      toggled: done,
      label: [title, ?rx?.intensity].join(', '),
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: done ? color : color.withValues(alpha: .5),
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 36),
              child: Row(
                children: [
                  RxCheck(
                    done: done,
                    color: kindTextColor(context, exercise.kind),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kindName(context, exercise.kind).toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .9,
                            color: kindTextColor(context, exercise.kind),
                          ),
                        ),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: done ? c.textMuted : c.text,
                            decoration: done
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if ((rx?.intensity ?? '').isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      rx!.intensity!,
                      style: TextStyle(fontSize: 13, color: c.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Marco de un combo (o de una movilidad suelta): nombre, "1/3" y la nota del
/// coach arriba; adentro una fila por ejercicio de cardio/movilidad y la
/// tarjeta normal para los de fuerza ([strengthBuilder]).
class ComboCard extends StatelessWidget {
  const ComboCard({
    super.key,
    required this.title,
    required this.exercises,
    required this.isDone,
    required this.onToggle,
    required this.strengthBuilder,
    this.note,
  });

  final String title;
  final String? note;
  final List<DayExerciseDto> exercises;
  final bool Function(DayExerciseDto) isDone;
  final void Function(DayExerciseDto)? onToggle;
  final Widget Function(DayExerciseDto) strengthBuilder;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rxItems = exercises.where((e) => !e.isStrength).toList();
    final kinds = rxItems.map((e) => e.kind).toSet();
    // Solo movilidad = violeta; solo cardio = naranja; mezcla = neutro
    final border = kinds.length == 1
        ? kindColor(context, kinds.first)
        : c.border;
    final titleColor = kinds.length == 1
        ? kindTextColor(context, kinds.first)
        : c.textSecondary;
    final done = rxItems.where(isDone).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .9,
                    color: titleColor,
                  ),
                ),
              ),
              if (rxItems.isNotEmpty)
                Text(
                  context.l10n.rxDoneCount(done, rxItems.length),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: c.textMuted,
                  ),
                ),
            ],
          ),
          if ((note ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 2),
              child: Text(
                '“$note”',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: c.textMuted,
                ),
              ),
            ),
          const SizedBox(height: 4),
          for (final e in exercises)
            if (e.isStrength)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: strengthBuilder(e),
              )
            else
              RxRow(
                exercise: e,
                done: isDone(e),
                onToggle: onToggle == null ? null : () => onToggle!(e),
              ),
        ],
      ),
    );
  }
}
