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

  group('Descanso automático (autoRestBetweenSets)', () {
    test('entre series del mismo ejercicio: arranca', () {
      expect(autoRestBetweenSets(after(jalon, 1), jalon), isTrue);
    });

    test('al terminar el ejercicio y pasar a otro: no arranca', () {
      final a = after(jalon, 2, saved: {setKey(jalon.id, 1)});
      expect(a.next?.exercise.id, remo.id);
      expect(autoRestBetweenSets(a, jalon), isFalse);
    });

    test('superserie a mitad de ronda: no (va sin pausa)', () {
      expect(autoRestBetweenSets(after(remo, 1), remo), isFalse);
    });

    test('superserie al terminar la ronda: arranca (sigue la misma superserie)', () {
      final a = after(curl, 1, saved: {setKey(remo.id, 1)});
      expect(autoRestBetweenSets(a, curl), isTrue);
    });

    test('editar una serie ya guardada: no arranca', () {
      final a = after(jalon, 1, saved: {setKey(jalon.id, 1)});
      expect(autoRestBetweenSets(a, jalon), isFalse);
    });
  });

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

    test(
      'entró el domingo y entrenó el martes: solo el tramo de las series',
      () {
        final d = workoutDuration(
          startedAt: t0.subtract(const Duration(days: 2)),
          completedAt: at(55),
          setTimes: [at(0), at(20), at(50)],
        );
        expect(d?.inMinutes, 55);
      },
    );

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
        workoutDuration(
          startedAt: t0,
          completedAt: at(40),
          setTimes: [],
        )?.inMinutes,
        40,
      );
      expect(
        workoutDuration(startedAt: t0, completedAt: at(60 * 30), setTimes: []),
        isNull,
      );
    });
  });

  group('savedSetFor con corrección del coach', () {
    final saved = DateTime.utc(2026, 11, 1, 10);
    LocalSetEntry local({bool synced = true, double weight = 1000}) =>
        LocalSetEntry(
          dayExerciseId: 'a',
          setNumber: 1,
          weight: weight,
          unit: WeightUnit.lb,
          reps: 10,
          synced: synced,
          savedAt: saved,
        );
    DayExerciseDto withRemote(double kg, DateTime updatedAt) => DayExerciseDto(
      id: 'a',
      exerciseName: 'a',
      supersetGroupId: null,
      loggedSets: [
        LoggedSetDto(
          setNumber: 1,
          weightKg: kg,
          weightUnit: 'LB',
          reps: 10,
          updatedAt: updatedAt,
        ),
      ],
    );
    final later = saved.add(const Duration(days: 1));

    test('el coach la corrigió después: gana el servidor', () {
      final s = savedSetFor(withRemote(45.359, later), 1, {
        setKey('a', 1): local(),
      })!;
      expect(s.weight, closeTo(100, 0.01));
    });

    test('mismos valores (la subida del atleta): sigue la local, tal cual', () {
      final s = savedSetFor(withRemote(453.592, later), 1, {
        setKey('a', 1): local(),
      })!;
      expect(s.weight, 1000);
    });

    test('sin subir o servidor más viejo: gana la local', () {
      expect(
        savedSetFor(withRemote(45.359, later), 1, {
          setKey('a', 1): local(synced: false),
        })!.weight,
        1000,
      );
      expect(
        savedSetFor(
          withRemote(45.359, saved.subtract(const Duration(hours: 1))),
          1,
          {setKey('a', 1): local()},
        )!.weight,
        1000,
      );
    });
  });

  group('noteFor', () {
    DayExerciseDto withNote(String? n) => DayExerciseDto(
      id: 'a',
      exerciseName: 'a',
      supersetGroupId: null,
      athleteNote: n,
    );

    test('sin nada local: la de la API', () {
      expect(noteFor(withNote('de la api'), const {}), 'de la api');
    });

    test('la del teléfono gana, también si la borró', () {
      expect(noteFor(withNote('vieja'), const {'a': 'nueva'}), 'nueva');
      expect(noteFor(withNote('vieja'), const {'a': null}), isNull);
    });

    test('vacía o solo espacios = sin nota', () {
      expect(noteFor(withNote('   '), const {}), isNull);
    });
  });

  test('día parcial: menos de la mitad de las series de fuerza con reps', () {
    LocalSetEntry set(String id, int n, {int? reps = 10}) => LocalSetEntry(
      dayExerciseId: id,
      setNumber: n,
      weight: 50,
      unit: WeightUnit.kg,
      reps: reps,
      synced: false,
    );
    final day = [ex('a', sets: 4), ex('b', sets: 3)]; // 7 series
    final three = {
      for (var n = 1; n <= 3; n++) setKey('a', n): set('a', n),
      setKey('b', 1): set('b', 1, reps: null), // sin reps no cuenta
    };
    expect(setProgressOf(day, three), (done: 3, total: 7));
    DayDto completed(Map<String, LocalSetEntry> local) {
      final p = setProgressOf(day, local);
      return DayDto(
        id: 'd',
        dayNumber: 1,
        name: null,
        sessionStatus: SessionStatus.completed,
        workoutSessionId: null,
        exercises: day,
      ).withSetProgress(p.done, p.total);
    }

    expect(completed(three).isPartial, isTrue);
    expect(completed(three).partialProgress, closeTo(3 / 7, 1e-9));
    final four = {...three, setKey('a', 4): set('a', 4)};
    expect(completed(four).isPartial, isFalse); // 4 de 7: no es parcial
  });
}
