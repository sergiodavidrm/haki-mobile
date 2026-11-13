import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/core/theme/app_theme.dart';
import 'package:haki_mobile/core/theme/haki_colors.dart';
import 'package:haki_mobile/core/theme/rank_colors.dart';
import 'package:haki_mobile/features/auth/data/auth_me_dto.dart';
import 'package:haki_mobile/features/auth/providers/auth_me_provider.dart';
import 'package:haki_mobile/features/levels/data/level_dto.dart';
import 'package:haki_mobile/features/levels/providers/level_providers.dart';
import 'package:haki_mobile/features/levels/ui/level_widgets.dart';
import 'package:haki_mobile/features/levels/ui/levels_screen.dart';
import 'package:haki_mobile/features/levels/ui/new_rank_screen.dart';
import 'package:haki_mobile/features/levels/ui/rank_icon.dart';
import 'package:haki_mobile/l10n/app_localizations.dart';

LevelDto _level({Rank rank = Rank.warrior}) => LevelDto.fromJson({
  'xp': 5320,
  'level': 7,
  'rank': rank.name,
  'rankNumber': 2,
  'levelXp': 820,
  'levelCost': 1100,
  'nextRank': rank == Rank.shogun ? null : Rank.values[rank.index + 1].name,
  'nextRankLevel': 10,
  'weekXp': 640,
  'showLevels': true,
  'badges': [
    {'key': 'streak_4', 'group': 'streak', 'target': 4, 'points': 100, 'value': 6, 'unlockedOn': '2026-10-18'},
    {'key': 'streak_8', 'group': 'streak', 'target': 8, 'points': 100, 'value': 6, 'unlockedOn': null},
    {'key': 'workouts_1', 'group': 'workouts', 'target': 1, 'points': 100, 'value': 26, 'unlockedOn': '2026-09-21'},
    {'key': 'tons_100', 'group': 'tons', 'target': 100, 'points': 250, 'value': 82.4, 'unlockedOn': null},
    {'key': 'program_perfect', 'group': 'programs_perfect', 'target': 1, 'points': 500, 'value': 0, 'unlockedOn': null},
  ],
  'recent': [],
});

Widget _app(Widget home, {Brightness brightness = Brightness.dark}) => ProviderScope(
  overrides: [
    levelProvider.overrideWith((ref) async => _level()),
    authMeProvider.overrideWith((ref) async => const AuthMeDto(
      exists: true, userId: 'u1', role: 'CLIENT', coachName: 'Andrés Solano', experience: 2)),
  ],
  child: MaterialApp(
    theme: buildAppTheme(
      brightness == Brightness.dark ? HakiColors.obsidian : HakiColors.light,
      brightness: brightness,
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    home: home,
  ),
);

void main() {
  testWidgets('Nivel y logros se dibuja en los dos temas', (tester) async {
    for (final b in Brightness.values) {
      await tester.pumpWidget(_app(const LevelsScreen(), brightness: b));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Guerrero'), findsWidgets);
      expect(find.text('Logros · 2 de 5'.toUpperCase()), findsOneWidget);
      expect(find.text('6 de 8'), findsOneWidget);
    }
  });

  testWidgets('Nuevo rango y los 5 íconos', (tester) async {
    for (final r in Rank.values) {
      await tester.pumpWidget(_app(NewRankScreen(rank: r, level: rankStartLevel[r]!)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: r.name);
      expect(find.byType(RankIcon), findsOneWidget);
    }
    expect(find.text('Andrés lo va a ver'), findsOneWidget);
  });

  testWidgets('Anillo de nivel en el último rango (sin siguiente)', (tester) async {
    await tester.pumpWidget(_app(Center(child: LevelRing(level: _level(rank: Rank.shogun)))));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
