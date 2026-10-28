import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/core/units/weight_unit.dart';
import 'package:haki_mobile/features/program/data/assignment_dtos.dart';
import 'package:haki_mobile/features/session/data/session_plan.dart';
import 'package:haki_mobile/features/session/data/session_store.dart';

DayExerciseDto ex(String id, {int sets = 3, String? superset}) =>
    DayExerciseDto(
      id: id,
      exerciseName: id,
      supersetGroupId: superset,
      targetSets: [
        for (var n = 1; n <= sets; n++) TargetSetDto(setNumber: n, reps: 10),
      ],
    );

void main() {
  final jalon = ex('jalon', sets: 2);
  final remo = ex('remo', sets: 2, superset: 'g1');
  final curl = ex('curl', sets: 3, superset: 'g1');
  final groups = groupSupersets([jalon, remo, curl]);

  AfterSave after(DayExerciseDto e, int n, {Set<String> saved = const {}}) =>
      afterSave(
        groups,
        e,
        n,
        wasSaved: saved.contains(setKey(e.id, n)),
        isSaved: (r) => saved.contains(r.key),
      );

  test('agrupa superseries y les pone letra', () {
    expect(groups.map((g) => g.letter), [null, 'A']);
    expect(groups[1].badgeOf(curl), 'A2');
  });

  test('superserie se hace por rondas', () {
    expect(workOrder(groups).map((r) => '${r.exercise.id}${r.setNumber}'), [
      'jalon1',
      'jalon2',
      'remo1',
      'curl1',
      'remo2',
      'curl2',
      'curl3',
    ]);
  });

  test('ejercicio suelto: descansa y sigue con la próxima serie', () {
    final a = after(jalon, 1);
    expect(a.rest, isTrue);
    expect(a.next?.key, setKey('jalon', 2));
  });

  test('superserie: no descansa a mitad de ronda', () {
    final a = after(remo, 1, saved: {'jalon#1', 'jalon#2'});
    expect(a.rest, isFalse);
    expect(a.next?.key, setKey('curl', 1));
  });

  test('superserie: descansa al cerrar la ronda y vuelve a A1', () {
    final a = after(curl, 1, saved: {'jalon#1', 'jalon#2', 'remo#1'});
    expect(a.rest, isTrue);
    expect(a.next?.key, setKey('remo', 2));
  });

  test('ronda donde A1 ya no tiene serie: A2 cierra igual', () {
    final saved = {'jalon#1', 'jalon#2', 'remo#1', 'curl#1', 'remo#2'};
    expect(after(curl, 2, saved: saved).rest, isTrue);
  });

  test('editar una serie guardada no dispara descanso', () {
    expect(after(jalon, 1, saved: {'jalon#1'}).rest, isFalse);
  });

  test('última serie pendiente: no descansa', () {
    final all = {for (final r in workOrder(groups)) r.key}..remove('curl#3');
    final a = after(curl, 3, saved: all);
    expect(a.rest, isFalse);
    expect(a.next, isNull);
  });

  test('next sigue hacia adelante y al final vuelve a lo salteado', () {
    expect(after(jalon, 2).next?.key, setKey('remo', 1));
    final all = {for (final r in workOrder(groups)) r.key}
      ..removeAll({'jalon#1', 'curl#3'});
    expect(after(curl, 3, saved: all).next?.key, setKey('jalon', 1));
  });

  test('resumen: series y volumen en la unidad pedida', () {
    LocalSetEntry set(String id, int n, double w, WeightUnit u) =>
        LocalSetEntry(
          dayExerciseId: id,
          setNumber: n,
          weight: w,
          unit: u,
          reps: 10,
          synced: false,
        );
    final local = {
      setKey('jalon', 1): set('jalon', 1, 50, WeightUnit.kg),
      setKey('jalon', 2): set('jalon', 2, 110.231, WeightUnit.lb), // ≈ 50 kg
    };
    final start = DateTime(2026, 10, 15, 18);
    final s = summarize(
      [jalon, remo, curl],
      local,
      unit: WeightUnit.kg,
      startedAt: start,
      completedAt: start.add(const Duration(minutes: 62)),
    );
    expect(s.setsDone, 2);
    expect(s.setsTotal, 7);
    expect(s.volume, closeTo(1000, 0.1));
    expect(s.duration?.inMinutes, 62);
  });

  group('workoutDuration', () {
    final t0 = DateTime(2026, 10, 27, 18);
    DateTime at(int min) => t0.add(Duration(minutes: min));

    test('entreno normal: de entrar a Finalizar', () {
      final d = workoutDuration(
        startedAt: t0,
        completedAt: at(65),
        setTimes: [at(8), at(30), at(60)],
      );
      expect(d?.inMinutes, 65);
    });

    test('entró el domingo y entrenó el martes: solo el tramo de las series', () {
      final d = workoutDuration(
        startedAt: t0.subtract(const Duration(days: 2)),
        completedAt: at(55),
        setTimes: [at(0), at(20), at(50)],
      );
      expect(d?.inMinutes, 55);
    });

    test('se olvidó de Finalizar: termina en la última serie', () {
      final d = workoutDuration(
        startedAt: t0,
        completedAt: at(60 * 20),
        setTimes: [at(5), at(45)],
      );
      expect(d?.inMinutes, 45);
    });

    test('series en días distintos: sin duración', () {
      final d = workoutDuration(
        startedAt: t0,
        completedAt: at(60 * 49),
        setTimes: [at(5), at(60 * 48)],
      );
      expect(d, isNull);
    });

    test('sin series: entrar → Finalizar, salvo que pasen más de 4 h', () {
      expect(
        workoutDuration(startedAt: t0, completedAt: at(40), setTimes: [])
            ?.inMinutes,
        40,
      );
      expect(
        workoutDuration(startedAt: t0, completedAt: at(60 * 30), setTimes: []),
        isNull,
      );
    });
  });
}
