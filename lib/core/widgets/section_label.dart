import 'package:flutter/material.dart';

import '../theme/haki_colors.dart';

/// Rótulo en mayúsculas con tracking ("HOY · SEMANA 3 DE 6", "EN CURSO").
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: color ?? context.colors.textMuted,
      ),
    );
  }
}
