import 'package:flutter/material.dart';

import '../theme/haki_colors.dart';

/// Pantalla temporal para los tabs que todavía no están construidos.
class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(message, style: TextStyle(fontSize: 14, color: c.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
