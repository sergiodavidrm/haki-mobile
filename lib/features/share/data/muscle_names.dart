import '../../../l10n/l10n.dart';

// Nombre de un músculo por su clave (haki-api Domain/MuscleKeys; mismas claves
// y textos que el web, MUSCLE.* de es.json/en.json). Una clave que la app no
// conoce todavía (la API sumó un músculo) se muestra legible igual.
String muscleName(String key) => switch (key) {
  'abductors' => l10n.muscleAbductors,
  'abs' => l10n.muscleAbs,
  'adductors' => l10n.muscleAdductors,
  'arms' => l10n.muscleArms,
  'back' => l10n.muscleBack,
  'biceps' => l10n.muscleBiceps,
  'brachialis' => l10n.muscleBrachialis,
  'brachioradialis' => l10n.muscleBrachioradialis,
  'calves' => l10n.muscleCalves,
  'chest' => l10n.muscleChest,
  'core' => l10n.muscleCore,
  'forearms' => l10n.muscleForearms,
  'front_delts' => l10n.muscleFrontDelts,
  'gastrocnemius' => l10n.muscleGastrocnemius,
  'glute_medius' => l10n.muscleGluteMedius,
  'glute_minimus' => l10n.muscleGluteMinimus,
  'glutes' => l10n.muscleGlutes,
  'hamstrings' => l10n.muscleHamstrings,
  'hip_flexors' => l10n.muscleHipFlexors,
  'lats' => l10n.muscleLats,
  'legs' => l10n.muscleLegs,
  'lower_back' => l10n.muscleLowerBack,
  'lower_chest' => l10n.muscleLowerChest,
  'lower_traps' => l10n.muscleLowerTraps,
  'mid_chest' => l10n.muscleMidChest,
  'mid_traps' => l10n.muscleMidTraps,
  'neck' => l10n.muscleNeck,
  'obliques' => l10n.muscleObliques,
  'quads' => l10n.muscleQuads,
  'rear_delts' => l10n.muscleRearDelts,
  'rhomboids' => l10n.muscleRhomboids,
  'rotator_cuff' => l10n.muscleRotatorCuff,
  'serratus' => l10n.muscleSerratus,
  'shoulders' => l10n.muscleShoulders,
  'side_delts' => l10n.muscleSideDelts,
  'soleus' => l10n.muscleSoleus,
  'teres_major' => l10n.muscleTeresMajor,
  'tibialis' => l10n.muscleTibialis,
  'transverse_abs' => l10n.muscleTransverseAbs,
  'traps' => l10n.muscleTraps,
  'triceps' => l10n.muscleTriceps,
  'triceps_long_head' => l10n.muscleTricepsLongHead,
  'upper_back' => l10n.muscleUpperBack,
  'upper_chest' => l10n.muscleUpperChest,
  'upper_traps' => l10n.muscleUpperTraps,
  _ => _humanize(key),
};

String _humanize(String key) {
  final s = key.replaceAll('_', ' ');
  return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
