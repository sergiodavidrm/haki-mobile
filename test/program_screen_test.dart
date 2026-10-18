import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/core/theme/app_theme.dart';
import 'package:haki_mobile/core/theme/haki_colors.dart';
import 'package:haki_mobile/features/program/data/assignment_dtos.dart';
import 'package:haki_mobile/features/program/data/program_schedule.dart';
import 'package:haki_mobile/features/program/providers/program_providers.dart';
import 'package:haki_mobile/features/program/ui/program_screen.dart';

Future<void> pump(WidgetTester tester, ProgramSections sections) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [programSectionsProvider.overrideWith((_) async => sections)],
      child: MaterialApp(
        theme: buildAppTheme(HakiColors.obsidian),
        home: const ProgramScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin programa en curso el tab muestra Mis programas', (
    tester,
  ) async {
    await pump(
      tester,
      ProgramSections(
        upcoming: [
          AssignmentSummaryDto(
            assignmentId: 'a',
            blockName: 'Bloque de Intensificación',
            status: 'active',
            startDate: null,
            endDate: null,
            totalWeeks: 4,
            completedWeeks: 0,
            blockUpdatedAt: DateTime.utc(2026, 1, 1),
            activatedAt: null,
          ),
        ],
      ),
    );
    expect(find.text('Mis programas'), findsOneWidget);
    expect(find.byTooltip('Volver'), findsNothing);
    expect(find.text('Bloque de Intensificación'), findsOneWidget);
    expect(find.text('Asignar fechas'), findsOneWidget);
  });

  testWidgets('sin ningún programa', (tester) async {
    await pump(tester, const ProgramSections());
    expect(find.text('Mis programas'), findsOneWidget);
    expect(find.text('Todavía no tenés programas'), findsOneWidget);
  });
}
