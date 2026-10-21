import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/auth_repository.dart';
import '../db/app_database.dart';
import '../network/api_client.dart';

part 'api_cache.g.dart';

// GET con respaldo local para lo que tiene que abrir sin señal (Hoy, Programa,
// la Sesión). Guarda el JSON de cada respuesta en la BD local
// (CachedResponses), por usuario. Se borra con AppDatabase.wipe (cerrar
// sesión / otro usuario).
//
// Con [onUpdated] es *stale-while-revalidate* (2026-10-21): si hay copia la
// devuelve al instante y pide a la API en segundo plano; si la respuesta
// cambió la guarda y llama a [onUpdated] (el provider se recarga y lee la
// copia nueva). Así la app abre en el acto aunque la señal sea mala. Sin copia
// (primera vez) espera la red. Sin [onUpdated]: primero la red y, sin
// respuesta del servidor, la copia (un 4xx/5xx no cae a la copia).
class ApiCache {
  ApiCache(this._api, this._db, this._userId);

  final Dio _api;
  final AppDatabase _db;
  final String? Function() _userId;

  /// Cuándo se pidió cada clave a la API por última vez (en memoria). Dentro
  /// de [_fresh] no se vuelve a pedir en segundo plano: evita el pedido doble
  /// cuando [onUpdated] recarga el provider.
  final _fetchedAt = <String, DateTime>{};
  static const _fresh = Duration(seconds: 30);

  /// Hasta cuándo las lecturas van primero a la red aunque haya copia.
  DateTime? _networkFirstUntil;

  /// La próxima lectura vuelve a pedir a la API. [wait] = esperar la
  /// respuesta en vez de mostrar la copia (pull-to-refresh: el atleta pidió
  /// datos nuevos); sin [wait] (volver a primer plano) se muestra la copia y
  /// se actualiza en segundo plano.
  void expire({bool wait = false}) {
    _fetchedAt.clear();
    if (wait) {
      _networkFirstUntil = DateTime.now().add(const Duration(seconds: 10));
    }
  }

  String _key(String path) => '${_userId() ?? '-'}:$path';

  Future<T> get<T>(
    String path,
    T Function(Object? json) parse, {
    void Function()? onUpdated,
  }) async {
    final key = _key(path);
    final waitNetwork =
        _networkFirstUntil != null &&
        DateTime.now().isBefore(_networkFirstUntil!);
    if (onUpdated != null && !waitNetwork) {
      final cached = await _read(key);
      if (cached != null) {
        try {
          final value = parse(jsonDecode(cached));
          final last = _fetchedAt[key];
          if (last == null || DateTime.now().difference(last) > _fresh) {
            unawaited(_revalidate(path, key, cached, onUpdated));
          }
          return value;
        } catch (_) {
          // Copia que ya no se puede leer (cambió el formato): va la red
        }
      }
    }

    try {
      return parse(await _fetch(path, key));
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      final cached = await _read(key);
      if (cached == null) rethrow;
      return parse(jsonDecode(cached));
    }
  }

  Future<void> _revalidate(
    String path,
    String key,
    String old,
    void Function() onUpdated,
  ) async {
    try {
      final data = await _fetch(path, key);
      if (jsonEncode(data) != old) onUpdated();
    } catch (_) {
      // Sin señal o error: queda la copia
    }
  }

  Future<Object?> _fetch(String path, String key) async {
    final res = await _api.get<Object?>(path);
    final data = res.data;
    _fetchedAt[key] = DateTime.now();
    await _db
        .into(_db.cachedResponses)
        .insertOnConflictUpdate(
          CachedResponsesCompanion.insert(
            key: key,
            json: jsonEncode(data),
            savedAt: DateTime.now(),
          ),
        );
    return data;
  }

  Future<String?> _read(String key) async => (await (_db.select(
    _db.cachedResponses,
  )..where((c) => c.key.equals(key))).getSingleOrNull())?.json;
}

@Riverpod(keepAlive: true)
ApiCache apiCache(Ref ref) {
  final auth = ref.watch(authRepositoryProvider);
  return ApiCache(
    ref.watch(apiClientProvider),
    ref.watch(appDatabaseProvider),
    () => auth.userId,
  );
}
