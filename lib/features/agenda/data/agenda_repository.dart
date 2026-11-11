import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/cache/api_cache.dart';
import '../../../core/network/api_client.dart';
import 'agenda_dtos.dart';

part 'agenda_repository.g.dart';

class AgendaRepository {
  AgendaRepository(this._api, this._cache);

  final Dio _api;
  final ApiCache _cache;

  /// Con copia local: la sesión de hoy se ve aunque no haya señal.
  Future<List<MyAgendaEvent>> getMine(
    DateTime from,
    DateTime to, {
    void Function()? onUpdated,
  }) => _cache.get(
    '/agenda/me?from=${_utc(from)}&to=${_utc(to)}',
    (j) => [
      for (final e in j as List) MyAgendaEvent.fromJson(e as Map<String, dynamic>),
    ],
    onUpdated: onUpdated,
  );

  Future<void> decline(String eventId, String? reason) => _api.put<void>(
    '/agenda/me/$eventId/decline',
    data: {'reason': reason},
  );

  Future<void> undoDecline(String eventId) =>
      _api.delete<void>('/agenda/me/$eventId/decline');

  /// "Voy" (borra el "No puedo ir")
  Future<void> confirm(String eventId) =>
      _api.put<void>('/agenda/me/$eventId/confirm');

  Future<void> undoConfirm(String eventId) =>
      _api.delete<void>('/agenda/me/$eventId/confirm');

  static String _utc(DateTime d) =>
      Uri.encodeQueryComponent(d.toUtc().toIso8601String());
}

@Riverpod(keepAlive: true)
AgendaRepository agendaRepository(Ref ref) =>
    AgendaRepository(ref.watch(apiClientProvider), ref.watch(apiCacheProvider));
