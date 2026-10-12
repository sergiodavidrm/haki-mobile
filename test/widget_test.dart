import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/core/theme/app_theme.dart';
import 'package:haki_mobile/core/theme/haki_colors.dart';

void main() {
  testWidgets('el tema expone los tokens de Haki', (tester) async {
    late HakiColors colors;
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(HakiColors.obsidian),
      home: Builder(builder: (context) {
        colors = context.colors;
        return const SizedBox();
      }),
    ));
    expect(colors.gold, HakiColors.obsidian.gold);
  });
}
