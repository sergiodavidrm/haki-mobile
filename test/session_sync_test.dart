import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
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

  /// path → código de error que responde (p. ej. 409 al firmar un video).
  final errors = <String, int>{};

  /// Cuerpo del último POST /workout-sessions.
  Map<String, dynamic>? lastSession;

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
    if (o.method == 'POST' && o.path == '/workout-sessions') {
      lastSession = Map<String, dynamic>.from(o.data as Map);
    }
    final error = errors[o.path];
    if (error != null) {
      return ResponseBody.fromString(
        jsonEncode({'detail': 'error'}),
        error,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }
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

  test(
    'la nota del atleta sube aunque no haya series y se puede borrar',
    () async {
      await store.saveNote(
        assignmentId: 'a1',
        dayId: 'd1',
        dayExerciseId: 'ex1',
        note: '  Me molestó el hombro  ',
      );
      await settle();

      expect(api.calls, [
        'POST /workout-sessions',
        'POST /workout-sessions/ses-1/exercise-logs',
        'PUT /workout-sessions/exercise-logs/log-1/note',
      ]);
      final note = await db.select(db.localNotes).getSingle();
      expect(note.note, 'Me molestó el hombro');
      expect(note.synced, isTrue);

      // Vacía = se borra (se manda null)
      api.calls.clear();
      await store.saveNote(
        assignmentId: 'a1',
        dayId: 'd1',
        dayExerciseId: 'ex1',
        note: '   ',
      );
      await settle();
      expect(api.calls, ['PUT /workout-sessions/exercise-logs/log-1/note']);
      expect((await db.select(db.localNotes).getSingle()).note, isNull);

      await db.wipe();
      expect(await db.select(db.localNotes).get(), isEmpty);
    },
  );

  test('sin señal la nota cuenta como pendiente', () async {
    api.offline = true;
    await store.saveNote(
      assignmentId: 'a1',
      dayId: 'd1',
      dayExerciseId: 'ex1',
      note: 'nota',
    );
    await settle();
    // la nota + la sesión sin crear en la API
    expect(await store.pendingCount(), 2);
  });

  test('un video con 409 al firmar (el coach no pide videos) se descarta', () async {
    api.errors['/set-logs/sl-1/video/signature'] = 409;
    final file = File(
      '${Directory.systemTemp.path}/haki_test_${DateTime.now().microsecondsSinceEpoch}.mp4',
    )..writeAsBytesSync([0]);
    await db
        .into(db.localVideos)
        .insert(
          LocalVideosCompanion.insert(
            assignmentId: 'a1',
            dayId: 'd1',
            dayExerciseId: 'ex1',
            setNumber: 1,
            setLogId: const Value('sl-1'),
            filePath: Value(file.path),
            compressed: const Value(true),
            createdAt: DateTime.now(),
          ),
        );

    sync.kick();
    await settle();

    expect(api.calls, contains('POST /set-logs/sl-1/video/signature'));
    // Fuera de la cola (no reintenta para siempre) y sin el archivo
    expect(await db.select(db.localVideos).get(), isEmpty);
    expect(file.existsSync(), isFalse);
  });

  test('Finalizar rechazado con 409 (día vacío) reabre el día y no traba la cola', () async {
    api.errors['/workout-sessions/ses-1/complete'] = 409;
    await saveSet(1);
    await store.complete('a1', 'd1');
    await settle();

    expect(api.calls, contains('PUT /workout-sessions/ses-1/complete'));
    final session = await db.select(db.localSessions).getSingle();
    expect(session.completedAt, isNull);
    expect(session.completeSynced, isFalse);
    expect(await store.pendingCount(), 0);
  });

  test('abrir un día sin cargar nada no crea la sesión en la API', () async {
    await store.start('a1', 'd1');
    await settle();

    expect(api.calls, isEmpty);
    expect(await store.pendingCount(), 0);
  });

  test(
    'la fecha de la sesión es la de la primera serie, no la de abrir el día',
    () async {
      // Abrió el día hace 3 días (sin cargar nada) y entrenó hoy
      await db
          .into(db.localSessions)
          .insert(
            LocalSessionsCompanion.insert(
              assignmentId: 'a1',
              dayId: 'd1',
              startedAt: DateTime.now().subtract(const Duration(days: 3)),
            ),
          );
      await saveSet(1);
      await settle();

      final today = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      expect(
        api.lastSession?['scheduledDate'],
        '${today.year}-${two(today.month)}-${two(today.day)}',
      );
    },
  );
}
