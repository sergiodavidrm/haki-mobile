import 'package:flutter/material.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../program/data/assignment_dtos.dart';
import '../data/session_plan.dart';
import 'set_row.dart';

typedef SaveSet = void Function(
  int setNumber,
  double? weight,
  WeightUnit unit,
  int? reps,
  int? rir,
);

/// Un ejercicio de la sesión: encabezado, nota del coach y tabla de series.
/// Suelto ([badge] null) se dibuja como en el mockup dentro de una tarjeta que
/// pone el que lo usa; en superserie lleva el carril A1/A2 a la izquierda.
class ExerciseBlock extends StatelessWidget {
  const ExerciseBlock({
    super.key,
    required this.exercise,
    required this.unit,
    required this.isUnitOverridden,
    required this.savedFor,
    required this.nextSetNumber,
    required this.onToggleUnit,
    required this.onSaveSet,
    required this.onVideo,
    this.badge,
    this.showRail = true,
  });

  final DayExerciseDto exercise;
  final WeightUnit unit;
  final bool isUnitOverridden;
  final SavedSet? Function(int setNumber) savedFor;

  /// Serie de este ejercicio que toca ahora (null = la siguiente es de otro).
  final int? nextSetNumber;
  final VoidCallback onToggleUnit;
  final SaveSet onSaveSet;

  /// [requested] = el coach pidió video de esa serie.
  final void Function(int setNumber, bool requested) onVideo;

  /// "A1", "A2"… dentro de una superserie.
  final String? badge;

  /// Línea del carril hacia el ejercicio de abajo (false en el último).
  final bool showRail;

  int get _rowCount => setCountOf(exercise);

  int get _doneCount =>
      List.generate(_rowCount, (i) => savedFor(i + 1)).nonNulls.length;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final inSuperset = badge != null;
    final cols = inSuperset ? SetCols.compact : SetCols.normal;
    final done = _doneCount == _rowCount;
    final pendingVideo = exercise.targetSets
        .where(
          (s) => s.requestVideo && !(savedFor(s.setNumber)?.hasVideo ?? false),
        )
        .map((s) => s.setNumber)
        .toList();

    final table = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SetTableHeader(cols: cols, unit: unit, compact: inSuperset),
        for (var n = 1; n <= _rowCount; n++)
          SetRow(
            key: ValueKey('${exercise.id}#$n'),
            setNumber: n,
            target: exercise.targetSets
                .where((s) => s.setNumber == n)
                .firstOrNull,
            unit: unit,
            saved: savedFor(n),
            isNext: nextSetNumber == n,
            cols: cols,
            onSave: (w, u, r, rir) => onSaveSet(n, w, u, r, rir),
            onVideo: (requested) => onVideo(n, requested),
          ),
      ],
    );

    final extras = <Widget>[
      if (pendingVideo.isNotEmpty) ...[
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.videocam_outlined, size: 15, color: c.goldBright),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tu coach pidió video de la ${pendingVideo.length == 1 ? 'serie' : 'series'} '
                '${_joinNumbers(pendingVideo)}. Tocá la cámara para grabar o subir.',
                style: TextStyle(fontSize: 12, color: c.goldBright),
              ),
            ),
          ],
        ),
      ],
    ];

    if (!inSuperset) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const ExerciseIconTile(),
              const SizedBox(width: 12),
              Expanded(
                child: _Title(
                  name: exercise.exerciseName,
                  summary: exerciseSummary(exercise),
                  size: 17,
                ),
              ),
              const SizedBox(width: 8),
              _UnitButton(
                unit: unit,
                overridden: isUnitOverridden,
                onTap: onToggleUnit,
              ),
              if (done) ...[
                const SizedBox(width: 8),
                Semantics(
                  label: 'Ejercicio completo',
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.turquoise,
                    ),
                    child: Icon(Icons.check, size: 18, color: c.background),
                  ),
                ),
              ],
            ],
          ),
          if (exercise.coachNote?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            _CoachNote(exercise.coachNote!.trim()),
          ],
          const SizedBox(height: 10),
          table,
          ...extras,
        ],
      );
    }

    // Carril A1/A2: letra arriba y línea hacia el ejercicio de abajo.
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          width: 26,
          child: Text(
            badge!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: c.turquoise,
            ),
          ),
        ),
        if (showRail)
          Positioned(
            left: 12,
            top: 22,
            bottom: 0,
            width: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.turquoise.withValues(alpha: .55),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.exerciseName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _UnitButton(
                    unit: unit,
                    overridden: isUnitOverridden,
                    onTap: onToggleUnit,
                  ),
                  const SizedBox(width: 6),
                  _ProgressPill(done: _doneCount, total: _rowCount),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                exerciseSummary(exercise),
                style: TextStyle(fontSize: 12, color: c.textMuted),
              ),
              if (exercise.coachNote?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                _CoachNote(exercise.coachNote!.trim()),
              ],
              const SizedBox(height: 6),
              table,
              ...extras,
            ],
          ),
        ),
      ],
    );
  }
}

/// "4 series · 10–12 reps · RIR 1" (el RIR solo si es igual en todas).
String exerciseSummary(DayExerciseDto e) {
  final sets = e.targetSets;
  if (sets.isEmpty) return 'Sin series prescritas';
  final reps = sets.map((s) => s.reps).nonNulls.toList()..sort();
  final rirs = sets.map((s) => s.rir).toSet();
  return [
    '${sets.length} ${sets.length == 1 ? 'serie' : 'series'}',
    if (reps.isNotEmpty)
      '${reps.first == reps.last ? reps.first : '${reps.first}–${reps.last}'} reps',
    if (rirs.length == 1 && rirs.single != null) 'RIR ${rirs.single}',
  ].join(' · ');
}

String _joinNumbers(List<int> n) => n.length == 1
    ? '${n.single}'
    : '${n.sublist(0, n.length - 1).join(', ')} y ${n.last}';

/// Cuadro gris con la mancuerna (ejercicio suelto, abierto o colapsado).
class ExerciseIconTile extends StatelessWidget {
  const ExerciseIconTile({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.fitness_center, size: 22, color: c.textMuted),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.name, required this.summary, required this.size});

  final String name;
  final String summary;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: c.text,
          ),
        ),
        const SizedBox(height: 2),
        Text(summary, style: TextStyle(fontSize: 12, color: c.textMuted)),
      ],
    );
  }
}

class _CoachNote extends StatelessWidget {
  const _CoachNote(this.note);

  final String note;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Coach: ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: c.goldBright,
              ),
            ),
            TextSpan(text: note),
          ],
        ),
        style: TextStyle(fontSize: 13, height: 1.45, color: c.textSecondary),
      ),
    );
  }
}

/// "1/3" series hechas, dentro de una superserie.
class _ProgressPill extends StatelessWidget {
  const _ProgressPill({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: '$done de $total series hechas',
      excludeSemantics: true,
      child: Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: c.turquoiseBorder),
        ),
        child: Text(
          '$done/$total',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: c.turquoiseMuted,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// Pastilla "LB ⇄": invierte la unidad solo para este ejercicio.
class _UnitButton extends StatelessWidget {
  const _UnitButton({
    required this.unit,
    required this.overridden,
    required this.onTap,
  });

  final WeightUnit unit;
  final bool overridden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = overridden ? c.goldBright : c.textSecondary;
    return Semantics(
      button: true,
      label:
          'Unidad de este ejercicio: ${unit.label}. Tocá para cambiar a ${unit.other.label}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        // Zona táctil de 44 px; la pastilla visible mide 28
        child: SizedBox(
          height: 44,
          child: Center(
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: ShapeDecoration(
                color: overridden ? c.goldSurface : c.background,
                shape: StadiumBorder(
                  side: BorderSide(color: overridden ? c.gold : c.border),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    unit.api,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .9,
                      color: fg,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.swap_horiz, size: 12, color: fg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
