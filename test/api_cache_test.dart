import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/core/cache/api_cache.dart';
import 'package:haki_mobile/core/db/app_database.dart';

/// Responde [body] con [status], o falla sin respuesta si [offline].
class FakeServer implements HttpClientAdapter {
  bool offline = false;
  int status = 200;
  Object body = {'v': 1};

  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<Uint8List>? requestStream,
    Future<void>? cancel,
  ) async {
    if (offline) {
      throw DioException.connectionError(
        requestOptions: o,
        reason: 'sin señal',
      );
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late AppDatabase db;
  late FakeServer server;
  late ApiCache cache;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    server = FakeServer();
    cache = ApiCache(Dio()..httpClientAdapter = server, db);
  });

  tearDown(() => db.close());

  int parse(Object? j) => (j as Map)['v'] as int;

  test('sin señal devuelve lo último que respondió la API', () async {
    expect(await cache.get('/x', parse), 1);
    server.body = {'v': 2};
    expect(await cache.get('/x', parse), 2);

    server.offline = true;
    expect(await cache.get('/x', parse), 2);
  });

  test('sin señal y sin nada guardado falla', () async {
    server.offline = true;
    expect(cache.get('/x', parse), throwsA(isA<DioException>()));
  });

  test('un error del servidor no cae al caché', () async {
    await cache.get('/x', parse);
    server.status = 500;
    expect(cache.get('/x', parse), throwsA(isA<DioException>()));
  });

  test('wipe borra el caché (cerrar sesión)', () async {
    await cache.get('/x', parse);
    await db.wipe();
    server.offline = true;
    expect(cache.get('/x', parse), throwsA(isA<DioException>()));
  });
}
