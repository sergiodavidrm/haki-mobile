import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/share/providers/share_providers.dart';
import 'package:haki_mobile/features/share/ui/stickers.dart';
import 'package:haki_mobile/l10n/app_localizations.dart';
import 'package:haki_mobile/core/units/weight_unit.dart';
import 'package:haki_mobile/features/profile/data/records.dart';
import 'package:haki_mobile/features/program/data/assignment_dtos.dart';
import 'package:haki_mobile/features/share/data/share_stickers.dart';

// Stickers para historias (2026-11-12): qué suma cada período.

Map<String, dynamic> ex(
  String id,
  String exerciseId,
  List<List<num>> sets, {
  List<String> primary = const [],
  List<String> secondary = const [],
}) => {
  'id': id,
  'exerciseId': exerciseId,
  'exerciseName': exerciseId,
  'targetSets': [
    for (var i = 0; i < sets.length; i++) {'setNumber': i + 1, 'reps': 10},
  ],
  'actualSets': [
    for (var i = 0; i < sets.length; i++)
      {'setNumber': i + 1, 'weight': sets[i][0], 'weightUnit': 'KG', 'reps': sets[i][1]},
  ],
  'primaryMuscles': primary,
  'secondaryMuscles': secondary,
};

Map<String, dynamic> day(
  String id,
  int n,
  List<Map<String, dynamic>> exercises, {
  DateTime? done,
}) => {
  'id': id,
  'dayNumber': n,
  'sessionStatus': done == null ? 'pending' : 'completed',
  'exercises': exercises,
  if (done != null) 'startedAt': done.toIso8601String(),
  if (done != null) 'completedAt': done.toIso8601String(),
};

AssignmentDetailDto program(
  List<List<Map<String, dynamic>>> weeks, {
  DateTime? start,
  List<Map<String, dynamic>> mappings = const [],
  List<Map<String, dynamic>> targets = const [],
}) => AssignmentDetailDto.fromJson({
  'assignmentId': 'p1',
  'blockName': 'Fuerza',
  'numberOfWeeks': weeks.length,
  if (start != null) 'startDate': start.toIso8601String(),
  'weeks': [
    for (var i = 0; i < weeks.length; i++) {'weekNumber': i + 1, 'days': weeks[i]},
  ],
  'dayMappings': mappings,
  'muscleTargets': targets,
  'blockUpdatedAt': '2026-11-01T00:00:00Z',
});

PersonalRecordDto rec(String name, DateTime date, double e1, double? prev) =>
    PersonalRecordDto(
      exerciseId: name,
      exerciseName: name,
      assignmentId: 'p1',
      date: date,
      e1RmKg: e1,
      weightKg: e1,
      unit: WeightUnit.kg,
      reps: 1,
      previousE1RmKg: prev,
    );

void main() {
  test('series por músculo: principal 1, secundario ½; sin reps no cuenta', () {
    final p = program([
      [
        day('d1', 1, [
          ex('e1', 'squat', [[100, 5], [100, 5]], primary: ['quads'], secondary: ['glutes']),
          ex('e2', 'curl', [[20, 0]], primary: ['biceps']),
        ], done: DateTime(2026, 11, 10, 18)),
      ],
    ]);
    final t = trainedDaysOf(p, const {}).single;
    expect(t.sets, 2);
    expect(t.setsTotal, 3);
    expect(t.volumeKg, 1000);
    expect(t.muscleSets, {'quads': 2, 'glutes': 1});
    expect(t.date, DateTime.utc(2026, 11, 10));
  });

  test('volumen vs. la semana pasada solo en los ejercicios en común', () {
    final p = program([
      [day('w1', 1, [ex('a', 'squat', [[100, 10]]), ex('b', 'leg', [[50, 10]])], done: DateTime(2026, 11, 3))],
      [day('w2', 1, [ex('c', 'squat', [[110, 10]]), ex('d', 'press', [[200, 10]])], done: DateTime(2026, 11, 10))],
    ]);
    final all = trainedDaysOf(p, const {});
    final t = all.firstWhere((x) => x.day.id == 'w2');
    final d = buildShareDay(
      program: p,
      trained: t,
      local: const {},
      prs: const [],
      sameDayLastWeek: sameDayLastWeekOf(t, all),
    );
    expect(d.volumeChange, closeTo(0.1, 1e-9)); // 1100 vs 1000 (sentadilla)
  });

  test('semana: hecho, faltó, pendiente y descanso; 1 de 3', () {
    // Lunes 9-nov; días lun / mié / vie
    final p = program(
      [
        [
          day('d1', 1, [ex('a', 'squat', [[100, 5]])], done: DateTime(2026, 11, 9, 7)),
          day('d2', 2, [ex('b', 'squat', const [])]),
          day('d3', 3, [ex('c', 'squat', const [])]),
        ],
      ],
      start: DateTime.utc(2026, 11, 9),
      mappings: [
        {'dayNumber': 1, 'weekDay': 'MON'},
        {'dayNumber': 2, 'weekDay': 'WED'},
        {'dayNumber': 3, 'weekDay': 'FRI'},
      ],
      targets: [{'muscleKey': 'chest', 'targetSets': 10}],
    );
    final trained = trainedDaysOf(p, const {});
    final w = buildShareWeek(
      start: DateTime.utc(2026, 11, 9),
      today: DateTime(2026, 11, 12),
      programs: [p],
      trained: trained,
      records: const [],
      mainProgram: p,
    );
    expect(w.marks, [
      WeekMark.done, WeekMark.rest, WeekMark.missed, WeekMark.rest,
      WeekMark.pending, WeekMark.rest, WeekMark.rest,
    ]);
    expect(w.done, 1);
    expect(w.planned, 3);
    expect(w.complete, isFalse);
    // El programa pide pecho aunque no lo entrenó: igual sale en la lista
    expect(w.muscles.map((m) => m.key), contains('chest'));
  });

  test('mes: del 1 al 7 el que terminó; después el en curso', () {
    expect(monthToShare(DateTime(2026, 11, 3)), (month: DateTime.utc(2026, 10), toDate: false));
    expect(monthToShare(DateTime(2026, 11, 12)), (month: DateTime.utc(2026, 11), toDate: true));
    expect(monthToShare(DateTime(2027, 1, 2)).month, DateTime.utc(2026, 12));
  });

  test('récords del período: solo PRs (no primeras veces), el que más subió primero', () {
    final r = recordsIn(
      [
        rec('a', DateTime(2026, 11, 10), 100, 98),
        rec('b', DateTime(2026, 11, 11), 120, 110),
        rec('c', DateTime(2026, 11, 11), 50, null),
        rec('d', DateTime(2026, 11, 2), 80, 70),
      ],
      DateTime.utc(2026, 11, 9),
      DateTime.utc(2026, 11, 16),
    );
    expect(r.map((x) => x.exerciseName), ['b', 'a']);
  });

  testWidgets('todos los stickers se dibujan sin desbordar, con y sin fondo', (tester) async {
    final p = program(
      [
        [day('w1', 1, [ex('a', 'Sentadilla', [[100, 10]], primary: ['quads'])], done: DateTime(2026, 11, 2))],
        [day('w2', 1, [ex('c', 'Sentadilla', [[110, 10], [110, 8]], primary: ['quads'], secondary: ['glutes'])], done: DateTime(2026, 11, 9))],
      ],
      start: DateTime.utc(2026, 11, 2),
      mappings: [{'dayNumber': 1, 'weekDay': 'MON'}],
      targets: [{'muscleKey': 'quads', 'targetSets': 6}],
    );
    final trained = trainedDaysOf(p, const {});
    final t = trained.last;
    final records = [rec('Sentadilla', DateTime(2026, 11, 9), 146, 133)];
    final data = ShareData(
      day: buildShareDay(program: p, trained: t, local: const {}, prs: const [], sameDayLastWeek: sameDayLastWeekOf(t, trained)),
      week: buildShareWeek(start: DateTime.utc(2026, 11, 9), today: DateTime(2026, 11, 12), programs: [p], trained: trained, records: records, mainProgram: p, streakWeeks: 3),
      month: buildShareMonth(today: DateTime.utc(2026, 11, 12), trained: trained, records: records),
      initial: SharePeriod.day,
      unit: WeightUnit.kg,
    );
    for (final bg in [null, 0, 3]) {
      for (final k in StickerKind.values) {
        if (!availableStickers(data, k.period).contains(k)) continue;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('es'),
            home: Center(child: Sticker(kind: k, data: data, background: bg)),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '$k fondo $bg');
      }
    }
  });
}
