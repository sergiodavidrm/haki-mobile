import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/app_database.dart';
import '../network/api_client.dart';

part 'api_cache.g.dart';

// GET con respaldo local para lo que tiene que abrir sin señal (Hoy, Programa,
// la Sesión). Primero la red; si responde se guarda el JSON en la BD local
// (CachedResponses); si no hay conexión (sin respuesta del servidor) se usa lo
// último guardado. Un error del servidor (4xx/5xx) no cae al caché: se
// propaga. Se borra con AppDatabase.wipe (cerrar sesión / otro usuario).
class ApiCache {
  ApiCache(this._api, this._db);

  final Dio _api;
  final AppDatabase _db;

  Future<T> get<T>(String path, T Function(Object? json) parse) async {
    try {
      final res = await _api.get<Object?>(path);
      final data = res.data;
      await _db
          .into(_db.cachedResponses)
          .insertOnConflictUpdate(
            CachedResponsesCompanion.insert(
              key: path,
              json: jsonEncode(data),
              savedAt: DateTime.now(),
            ),
          );
      return parse(data);
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      final cached = await (_db.select(
        _db.cachedResponses,
      )..where((c) => c.key.equals(path))).getSingleOrNull();
      if (cached == null) rethrow;
      return parse(jsonDecode(cached.json));
    }
  }
}

@Riverpod(keepAlive: true)
ApiCache apiCache(Ref ref) =>
    ApiCache(ref.watch(apiClientProvider), ref.watch(appDatabaseProvider));
