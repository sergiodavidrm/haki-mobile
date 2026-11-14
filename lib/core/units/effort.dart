import '../../l10n/l10n.dart';

/// Esfuerzo de las series (2026-11-14): la API guarda y manda siempre RIR
/// (0–5, con medio punto). El coach elige cómo se ve y se carga
/// (`/auth/me` `effortScale`): RIR o RPE = 10 − RIR. Como kg/lb.
enum EffortScale {
  rir,
  rpe;

  static EffortScale parse(String? s) => s == 'rpe' ? rpe : rir;

  String get label => this == rpe ? 'RPE' : 'RIR';
}

/// RIR → valor en la escala (RPE = 10 − RIR)
double? toScale(double? rir, EffortScale scale) =>
    rir == null ? null : (scale == EffortScale.rpe ? 10 - rir : rir);

/// Valor en la escala → RIR, redondeado al medio punto y entre 0 y 5
double toRir(double value, EffortScale scale) {
  final rir = scale == EffortScale.rpe ? 10 - value : value;
  return ((rir.clamp(0, 5) * 2).roundToDouble()) / 2;
}

/// "8" / "8,5" (coma en español). El tope del RIR se lee "5+" (lejos del
/// fallo; RPE 5)
String formatEffort(double? rir, EffortScale scale) {
  final v = toScale(rir, scale);
  if (v == null) return '–';
  if (scale == EffortScale.rir && v >= 5) return '5+';
  final text = v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  return appLocale.languageCode == 'es' ? text.replaceAll('.', ',') : text;
}

/// "RPE 8,5" / "RIR 1,5"
String effortText(double? rir, EffortScale scale) =>
    rir == null ? '' : '${scale.label} ${formatEffort(rir, scale)}';

/// Pasos del panel, de más fácil a más duro: RIR 4 … 0 (RPE 6 … 10)
const effortSteps = [4.0, 3.5, 3.0, 2.5, 2.0, 1.5, 1.0, 0.5, 0.0];

/// "Duro", "Muy duro"… según el RIR
String effortTitle(AppLocalizations l, double rir) {
  if (rir >= 3) return l.effortModerate;
  if (rir >= 1.5) return l.effortHard;
  if (rir >= 1) return l.effortVeryHard;
  if (rir > 0) return l.effortNearFailure;
  return l.effortFailure;
}

/// "Te quedaban 2 reps", "Te quedaban 1 o 2 reps"…
String effortHint(AppLocalizations l, double rir) {
  if (rir >= 4) return l.effortHintFourPlus;
  if (rir == 0) return l.effortHintNone;
  if (rir == 0.5) return l.effortHintMaybeOne;
  if (rir == rir.roundToDouble()) return l.effortHintN(rir.toInt());
  return l.effortHintRange(rir.floor(), rir.ceil());
}
