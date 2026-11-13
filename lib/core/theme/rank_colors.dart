import 'package:flutter/material.dart';

/// Rangos del nivel (decidido 2026-11-13, canvas "Haki · Niveles y logros"):
/// Despertar 1–4, Guerrero 5–9, Samurái 10–14, Daimyō 15–19, Shōgun 20+.
/// La clave es la de la API (`rank`).
enum Rank { awakening, warrior, samurai, daimyo, shogun }

Rank rankOf(String? key) => Rank.values.asNameMap()[key] ?? Rank.awakening;

/// Primer nivel de cada rango
const rankStartLevel = {
  Rank.awakening: 1,
  Rank.warrior: 5,
  Rank.samurai: 10,
  Rank.daimyo: 15,
  Rank.shogun: 20,
};

/// Metales que suben de valor: bronce, plata, acero, oro, carmesí. Solo en el
/// anillo, el ícono y la pantalla de nuevo rango; el resto sigue dorado. El
/// carmesí nunca en textos de estado (se leería como error).
Color rankColor(BuildContext context, Rank rank) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (rank) {
    Rank.awakening => dark ? const Color(0xFFC7865A) : const Color(0xFF9A5E34),
    Rank.warrior => dark ? const Color(0xFFC4CCD6) : const Color(0xFF5E6A78),
    Rank.samurai => dark ? const Color(0xFF7FA8D1) : const Color(0xFF3D6A99),
    Rank.daimyo => dark ? const Color(0xFFE0B64A) : const Color(0xFF8A6A12),
    Rank.shogun => dark ? const Color(0xFFE5484D) : const Color(0xFFB42318),
  };
}

/// Fondo suave del rango (pastillas, medalla)
Color rankSoft(BuildContext context, Rank rank) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (rank) {
    Rank.awakening => dark ? const Color(0xFF2A1F17) : const Color(0xFFF6ECE4),
    Rank.warrior => dark ? const Color(0xFF22262B) : const Color(0xFFECEFF3),
    Rank.samurai => dark ? const Color(0xFF18222D) : const Color(0xFFE6EEF6),
    Rank.daimyo => dark ? const Color(0xFF2A2410) : const Color(0xFFFBF4E2),
    Rank.shogun => dark ? const Color(0xFF2D1517) : const Color(0xFFFBE9E9),
  };
}
