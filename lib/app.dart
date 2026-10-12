import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/haki_colors.dart';

class HakiApp extends ConsumerWidget {
  const HakiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Haki',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(HakiColors.obsidian),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
