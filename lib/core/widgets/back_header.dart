import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/haki_colors.dart';
import '../../l10n/l10n.dart';

/// Encabezado de pantalla secundaria: volver + título (+ subtítulo).
class BackHeader extends StatelessWidget {
  const BackHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleSize = 26,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Transform.translate(
          offset: const Offset(-10, 0),
          child: IconButton(
            tooltip: context.l10n.commonBack,
            onPressed: () => context.pop(),
            icon: Icon(Icons.chevron_left, size: 28, color: c.text),
          ),
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(-8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: c.text,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 12, color: c.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
