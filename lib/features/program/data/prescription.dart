import '../../../l10n/l10n.dart';

// Cardio / Movilidad (2026-11-03, haki-api Domain/Prescription.cs). No tienen
// series: el coach pone una prescripción y el atleta solo marca Hecho. No
// suman a volumen, e1RM, récords ni series por músculo.

abstract final class ExerciseKinds {
  static const strength = 'strength';
  static const cardio = 'cardio';
  static const mobility = 'mobility';
}

/// Cardio: [minutes] + [intensity] ("zona 2"). Movilidad: [sets] × [amount]
/// [unit] (reps | seconds) + [perSide].
class PrescriptionDto {
  const PrescriptionDto({
    this.minutes,
    this.intensity,
    this.sets,
    this.amount,
    this.unit,
    this.perSide = false,
  });

  final int? minutes;
  final String? intensity;
  final int? sets;
  final int? amount;
  final String? unit;
  final bool perSide;

  factory PrescriptionDto.fromJson(Map<String, dynamic> j) => PrescriptionDto(
    minutes: (j['minutes'] as num?)?.toInt(),
    intensity: j['intensity'] as String?,
    sets: (j['sets'] as num?)?.toInt(),
    amount: (j['amount'] as num?)?.toInt(),
    unit: j['unit'] as String?,
    perSide: j['perSide'] as bool? ?? false,
  );
}

/// "Caminadora · 30 min" se arma afuera; esto da "30 min" / "2 × 30 s por lado".
/// [withIntensity] = false para cuando la intensidad va aparte.
String formatPrescription(
  String kind,
  PrescriptionDto? rx, {
  bool withIntensity = true,
}) {
  if (rx == null) return '';
  final l = l10n;
  if (kind == ExerciseKinds.cardio) {
    return [
      if (rx.minutes != null) '${rx.minutes} ${l.rxMin}',
      if (withIntensity && (rx.intensity ?? '').isNotEmpty) rx.intensity!,
    ].join(' · ');
  }
  if (kind == ExerciseKinds.mobility) {
    if (rx.amount == null) return '';
    final amount = rx.unit == 'seconds' ? '${rx.amount} ${l.rxSec}' : '${rx.amount}';
    final base = rx.sets == null ? amount : '${rx.sets} × $amount';
    return rx.perSide ? '$base ${l.rxPerSide}' : base;
  }
  return '';
}
