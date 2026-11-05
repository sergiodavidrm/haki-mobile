import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/progress/data/progress_report.dart';

Map<String, dynamic> row(String id, List<num?> values, {bool bw = false}) => {
  'exerciseId': id,
  'name': 'Ej $id',
  'bodyweight': bw,
  'values': values,
  'best': [
    for (final v in values)
      v == null
          ? null
          : {'weightKg': 50, 'weightUnit': 'KG', 'reps': 5, 'value': v},
  ],
};

Map<String, dynamic> report({
  required List<Map<String, dynamic>> rows,
  List<List<String>> cells = const [],
}) => {
  'period': 'block',
  'from': '2026-10-12',
  'to': '2026-11-08',
  'program': {
    'assignmentId': 'a',
    'name': 'Torso · Pierna',
    'status': 'active',
    'totalWeeks': 6,
    'currentWeek': 4,
  },
  'columns': [
    {'label': 'S1', 'weekNumber': 1, 'state': 'done'},
    {'label': 'S2', 'weekNumber': 2, 'state': 'done'},
    {'label': 'S3', 'weekNumber': 3, 'state': 'partial'},
  ],
  'bands': [],
  'kpis': {'done': 7, 'due': 8, 'currentDone': 1, 'currentPlanned': 4},
  'rows': rows,
  'constancy': {
    'rows': [
      for (final c in cells) {'cells': c},
    ],
  },
};

void main() {
  test('fromJson: columnas, filas y KPIs', () {
    final r = ProgressReport.fromJson(
      report(
        rows: [
          row('1', [100, 103, null]),
        ],
      ),
    );
    expect(r.isRange, isFalse);
    expect(r.columns.map((c) => c.state), [
      ColumnState.done,
      ColumnState.done,
      ColumnState.partial,
    ]);
    expect(r.exercises.single.values, [100, 103, null]);
    expect(r.exercises.single.best[1]!.reps, 5);
    expect((r.done, r.due, r.program!.currentWeek), (7, 8, 4));
  });

  test('semana completa: hizo todo lo que tocaba', () {
    final r = ProgressReport.fromJson(
      report(
        rows: const [],
        cells: [
          ['done', 'done', 'pending'],
          ['done', 'missed', 'future'],
          ['none', 'done', 'future'],
        ],
      ),
    );
    expect(r.weekFull, [true, false, false]);
    expect(weekIsFull(['rest', 'rest']), isFalse);
    expect(r.weekFill, [1, 2 / 3, 0]);
    expect(weekFillOf(['rest', 'none']), 0);
  });

  test(
    'ejercicios ordenados por cuánto subieron, sin los que no tienen datos',
    () {
      final r = ProgressReport.fromJson(
        report(
          rows: [
            row('a', [100, 101, null]),
            row('b', [50, 60, 62]),
            row('c', [null, null, null]),
            row('d', [80, null, null]),
          ],
        ),
      );
      final t = trendsOf(r);
      expect(t.map((x) => x.exercise.exerciseId), ['b', 'a', 'd']);
      expect(t.first.pct, 24);
      expect(t.last.pct, isNull, reason: 'una sola semana con datos');
    },
  );

  test('récords: superan todas las semanas anteriores del período', () {
    expect(prMask([100, 103, 102, null, 105]), [
      false,
      true,
      false,
      false,
      true,
    ]);
    expect(prMask([null, 90]), [false, false]);
  });

  test('período: query para la API', () {
    expect(ProgressPeriod.block.query, 'period=block&byExercise=true');
    expect(
      ProgressPeriod.weeks12.query,
      'period=weeks&weeks=12&byExercise=true',
    );
  });
}
