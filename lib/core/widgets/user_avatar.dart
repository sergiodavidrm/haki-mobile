import 'package:flutter/material.dart';

import '../theme/haki_colors.dart';

/// Círculo con las iniciales del nombre ("Sergio Rodríguez" → "SR").
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.highlighted = false,
  });

  final String name;
  final double size;

  /// Borde dorado (cabecera del perfil).
  final bool highlighted;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2);
    return parts.map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.surfaceHigh,
        border: Border.all(
          color: highlighted ? c.gold : c.border,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          color: c.text,
        ),
      ),
    );
  }
}
