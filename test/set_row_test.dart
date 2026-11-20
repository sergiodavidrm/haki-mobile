import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/core/theme/app_theme.dart';
import 'package:haki_mobile/core/theme/haki_colors.dart';
import 'package:haki_mobile/core/units/effort.dart';
import 'package:haki_mobile/core/units/weight_unit.dart';
import 'package:haki_mobile/features/auth/providers/auth_me_provider.dart';
import 'package:haki_mobile/features/program/data/assignment_dtos.dart';
import 'package:haki_mobile/features/session/data/session_plan.dart';
import 'package:haki_mobile/features/session/ui/set_row.dart';
import 'package:haki_mobile/l10n/l10n.dart';

// Serie ya guardada (60 kg × 10 · RIR 2): la fila está cerrada hasta que la tocan.
Future<void> pumpRow(
  WidgetTester tester, {
  bool videos = true,
  void Function(double? rir)? onSave,
  EffortScale scale = EffortScale.rir,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        videosEnabledProvider.overrideWithValue(videos),
        effortScaleProvider.overrideWithValue(scale),
      ],
      child: MaterialApp(
        theme: buildAppTheme(HakiColors.obsidian),
        locale: const Locale('es'),
        supportedLocales: supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: SetRow(
            setNumber: 1,
            target: const TargetSetDto(setNumber: 1, reps: 10),
            unit: WeightUnit.kg,
            saved: const SavedSet(
              weight: 60,
              unit: WeightUnit.kg,
              reps: 10,
              rir: 2,
              synced: true,
            ),
            cols: SetCols.normal,
            onSave: (_, _, _, rir) => onSave?.call(rir),
            onVideo: (_) {},
          ),
        ),
      ),
    ),
  );
}

/// Texto del campo que quedó con el foco.
String? focusedText(WidgetTester tester) {
  final field = tester
      .widgetList<TextField>(find.byType(TextField))
      .where((f) => f.focusNode?.hasFocus ?? false)
      .firstOrNull;
  return field?.controller?.text;
}

void main() {
  testWidgets('tocar las reps abre la fila con el foco en reps', (
    tester,
  ) async {
    await pumpRow(tester);
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    expect(focusedText(tester), '10');
  });

  testWidgets('con RIR, tocar el RIR deja el foco en el RIR (teclado)', (
    tester,
  ) async {
    double? saved;
    await pumpRow(tester, onSave: (rir) => saved = rir);
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    expect(focusedText(tester), '2');
    // Acepta medio punto
    await tester.enterText(find.byType(TextField).last, '1,5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(saved, 1.5);
  });

  testWidgets('con RPE, tocar el RPE abre el panel (sin teclado)', (
    tester,
  ) async {
    double? saved;
    await pumpRow(
      tester,
      scale: EffortScale.rpe,
      onSave: (rir) => saved = rir,
    );
    // RIR 2 = RPE 8
    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();
    expect(find.text('Duro'), findsOneWidget);
    expect(focusedText(tester), isNull);
    // + = más duro: RPE 8 → 8,5 (RIR 1,5) y Listo guarda la serie
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();
    expect(saved, 1.5);
  });

  testWidgets('tocar el peso (o el resto de la fila) deja el foco en el peso', (
    tester,
  ) async {
    await pumpRow(tester);
    await tester.tap(find.text('60'));
    await tester.pumpAndSettle();
    expect(focusedText(tester), '60');
  });

  testWidgets('sin videos, una serie que ya tiene video sigue con la cámara', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [videosEnabledProvider.overrideWithValue(false)],
        child: MaterialApp(
          theme: buildAppTheme(HakiColors.obsidian),
          locale: const Locale('es'),
          supportedLocales: supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: SetCameraButton(
              setNumber: 1,
              requested: false,
              sent: true,
              uploading: false,
              onTap: () {},
            ),
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);
  });

  testWidgets('sin videos (el coach no los pide) no hay cámara', (
    tester,
  ) async {
    await pumpRow(tester, videos: false);
    expect(find.byType(SetCameraButton), findsOneWidget);
    expect(find.byIcon(Icons.videocam_outlined), findsNothing);
    expect(find.byIcon(Icons.videocam_off_outlined), findsNothing);
  });

  group('tocar el objetivo copia peso y reps', () {
    // Serie sin cargar con objetivo 35 × 12 · RIR 2
    late List<(double?, WeightUnit, int?, double?)> saves;

    Future<void> pumpTarget(
      WidgetTester tester, {
      EffortScale scale = EffortScale.rir,
      SavedSet? saved,
    }) async {
      saves = [];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [effortScaleProvider.overrideWithValue(scale)],
          child: MaterialApp(
            theme: buildAppTheme(HakiColors.obsidian),
            locale: const Locale('es'),
            supportedLocales: supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(
              body: Column(
                children: [
                  SetRow(
                    setNumber: 1,
                    target: const TargetSetDto(
                      setNumber: 1,
                      weightKg: 35,
                      reps: 12,
                      rir: 2,
                    ),
                    unit: WeightUnit.kg,
                    saved: saved,
                    cols: SetCols.normal,
                    onSave: (w, u, r, rir) => saves.add((w, u, r, rir)),
                    onVideo: (_) {},
                  ),
                  const TextField(key: Key('otro')),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('con RIR: copia y deja el foco en el RIR vacío', (
      tester,
    ) async {
      await pumpTarget(tester);
      await tester.tap(find.text('35 × 12'));
      await tester.pumpAndSettle();
      expect(focusedText(tester), '');
      await tester.enterText(find.byType(TextField).at(2), '3');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(saves.single, (35.0, WeightUnit.kg, 12, 3.0));
    });

    testWidgets('con RIR: salir sin esfuerzo guarda peso y reps', (
      tester,
    ) async {
      await pumpTarget(tester);
      await tester.tap(find.text('35 × 12'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('otro')));
      await tester.pumpAndSettle();
      expect(saves.single, (35.0, WeightUnit.kg, 12, null));
    });

    testWidgets('con RPE: copia y abre el panel', (tester) async {
      await pumpTarget(tester, scale: EffortScale.rpe);
      await tester.tap(find.text('35 × 12'));
      await tester.pumpAndSettle();
      expect(find.text('Listo'), findsOneWidget);
      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();
      // Arranca en lo pedido (RIR 2) y el atleta lo confirmó con Listo
      expect(saves.single, (35.0, WeightUnit.kg, 12, 2.0));
    });

    testWidgets('una serie ya cargada no se pisa', (tester) async {
      await pumpTarget(
        tester,
        saved: const SavedSet(
          weight: 30,
          unit: WeightUnit.kg,
          reps: 10,
          rir: 1,
          synced: true,
        ),
      );
      await tester.tap(find.text('35 × 12'));
      await tester.pumpAndSettle();
      // Abre la fila como antes (foco en el peso), sin copiar
      expect(focusedText(tester), '30');
    });
  });

  group('unidad con la fila abierta', () {
    // Serie sin cargar; [unit] la maneja el test (switch del día o del ejercicio).
    late ValueNotifier<WeightUnit> dayUnit;
    late List<(double?, WeightUnit)> saves;

    Future<void> pumpEmpty(WidgetTester tester) async {
      dayUnit = ValueNotifier(WeightUnit.kg);
      saves = [];
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildAppTheme(HakiColors.obsidian),
            locale: const Locale('es'),
            supportedLocales: supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(
              body: Column(
                children: [
                  ValueListenableBuilder(
                    valueListenable: dayUnit,
                    builder: (_, unit, _) => SetTableHeader(
                      cols: SetCols.normal,
                      unit: unit,
                      onToggleUnit: () => dayUnit.value = unit.other,
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: dayUnit,
                    builder: (_, unit, _) => SetRow(
                      setNumber: 1,
                      target: null,
                      unit: unit,
                      saved: null,
                      cols: SetCols.normal,
                      onSave: (w, u, _, _) => saves.add((w, u)),
                      onVideo: (_) {},
                    ),
                  ),
                  const TextField(key: Key('otro')),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('–').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '100');
    }

    testWidgets('cambiar la unidad (día o ejercicio) convierte el peso que se está escribiendo', (
      tester,
    ) async {
      await pumpEmpty(tester);
      dayUnit.value = WeightUnit.lb;
      await tester.pump();
      expect(focusedText(tester), '220.5');
      await tester.tap(find.byKey(const Key('otro')));
      await tester.pump();
      expect(saves.single.$1, 220.5);
      expect(saves.single.$2, WeightUnit.lb);
    });
  
    testWidgets('tocar "KG" del encabezado convierte sin cerrar la fila', (
      tester,
    ) async {
      await pumpEmpty(tester);
      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pump();
      expect(focusedText(tester), '220.5');
      expect(saves, isEmpty);
      expect(find.text('LB'), findsOneWidget);
    });
  });
}
