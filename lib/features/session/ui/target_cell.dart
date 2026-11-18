import 'package:flutter/material.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/units/effort.dart';
import '../../../core/units/weight_unit.dart';
import '../../../l10n/l10n.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../../program/data/assignment_dtos.dart';

/// Objetivo de una serie (Sesión y Sesión pasada, 2026-11-17): arriba
/// "35 × 12" (o "12 reps" sin peso) y abajo el esfuerzo ("RIR 2"). Antes
/// "12 reps · RIR 2" iba abajo dentro de un FittedBox y quedaba ilegible en
/// la columna angosta de una superserie o con letra grande en el teléfono.
class TargetCell extends StatelessWidget {
  const TargetCell({
    super.key,
    required this.target,
    required this.unit,
    this.color,
  });

  final TargetSetDto? target;
  final WeightUnit unit;

  /// Color de la línea de arriba (turquesa en la Sesión, apagado en la pasada)
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = target;
    final scale = effortScaleOf(context);
    // "35 × 12" sin unidad (Sergio, 2026-11-17: la unidad ya está en el
    // encabezado KG/LB de la tabla). Sin peso: "12 reps". Abajo solo el
    // esfuerzo ("RIR 2"): 2 líneas por serie como mucho.
    final weight = t?.weightKg == null
        ? null
        : formatWeight(unit.fromKg(t!.weightKg!));
    final main = weight != null
        ? [weight, if (t?.reps != null) '${t!.reps}'].join(' × ')
        : t?.reps == null
        ? null
        : '${t!.reps} ${context.l10n.repsShort}';
    final sub = t?.rir == null ? '' : effortText(t!.rir, scale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Uno largo ("308.6 × 12") se achica antes que cortarse
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            main ?? '—',
            maxLines: 1,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: color ?? c.turquoise,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        if (sub.isNotEmpty)
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, height: 1.25, color: c.textMuted),
          ),
      ],
    );
  }
}
