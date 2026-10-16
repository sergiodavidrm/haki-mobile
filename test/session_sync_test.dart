import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/core/db/app_database.dart';
import 'package:haki_mobile/core/units/weight_unit.dart';
import 'package:haki_mobile/features/session/data/session_store.dart';
import 'package:haki_mobile/features/session/data/session_sync.dart';

/// API falsa: registra cada request y responde lo mínimo que lee el sync.
class FakeApi implements HttpClientAdapter {
  final calls = <String>[];
  bool offline = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<Uint8List>? body,
    Future<void>? cancel,
  ) async {
    if (offline) {
      throw DioException.connectionError(
        requestOptions: o,
        reason: 'sin señal',
      );
    }
    calls.add('${o.method} ${o.path}');
    final data = switch (o.path) {
      '/workout-sessions' => {'id': 'ses-1'},
      final p when p.endsWith('/exercise-logs') => {'id': 'log-1'},
      _ => <String, dynamic>{},
    };
    return ResponseBody.fromString(
      jsonEncode(data),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakeApi api;
  late SessionSync sync;
  late SessionStore store;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeApi();
    sync = SessionSync(db, Dio()..httpClientAdapter = api);
    store = SessionStore(db, sync);
  });

  tearDown(() async {
    sync.dispose();
    await db.close();
  });

  Future<void> settle() async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  Future<void> saveSet(int n) => store.saveSet(
    assignmentId: 'a1',
    dayId: 'd1',
    dayExerciseId: 'ex1',
    setNumber: n,
    weight: 45,
    unit: WeightUnit.lb,
    reps: 10,
    rir: 2,
  );

  test(
    'sube sesión → exercise-log → series → complete, en ese orden',
    () async {
      await saveSet(1);
      await saveSet(2);
      await store.complete('a1', 'd1');
      await settle();

      expect(api.calls, [
        'POST /workout-sessions',
        'POST /workout-sessions/ses-1/exercise-logs',
        'PUT /workout-sessions/exercise-logs/log-1/sets/1',
        'PUT /workout-sessions/exercise-logs/log-1/sets/2',
        'PUT /workout-sessions/ses-1/complete',
      ]);
      final sets = await db.select(db.localSets).get();
      expect(sets.every((s) => s.synced), isTrue);
      expect(sets.first.weightUnit, 'LB');
    },
  );

  test(
    'sin señal queda todo guardado local y sin marcar como subido',
    () async {
      api.offline = true;
      await saveSet(1);
      await settle();

      final sets = await db.select(db.localSets).get();
      expect(sets.single.synced, isFalse);
      final session = await db.select(db.localSessions).getSingle();
      expect(session.remoteId, isNull);
    },
  );

  test('editar una serie ya subida la vuelve a mandar', () async {
    await saveSet(1);
    await settle();
    api.calls.clear();

    await store.saveSet(
      assignmentId: 'a1',
      dayId: 'd1',
      dayExerciseId: 'ex1',
      setNumber: 1,
      weight: 50,
      unit: WeightUnit.lb,
      reps: 8,
      rir: 1,
    );
    await settle();

    // Reusa la sesión y el exercise-log ya creados
    expect(api.calls, ['PUT /workout-sessions/exercise-logs/log-1/sets/1']);
  });

  test('pendingCount cuenta lo que falta subir y wipe borra todo', () async {
    api.offline = true;
    await saveSet(1);
    await saveSet(2);
    await settle();
    // 2 series + la sesión sin crear en la API
    expect(await store.pendingCount(), 3);

    api.offline = false;
    sync.kick();
    await settle();
    expect(await store.pendingCount(), 0);

    await db.wipe();
    expect(await db.select(db.localSets).get(), isEmpty);
    expect(await db.select(db.localSessions).get(), isEmpty);
    expect(await db.select(db.localExerciseLogs).get(), isEmpty);
  });
}
