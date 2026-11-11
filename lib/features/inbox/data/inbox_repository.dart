import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/cache/api_cache.dart';
import '../../../core/network/api_client.dart';
import 'inbox_dtos.dart';

part 'inbox_repository.g.dart';

class InboxRepository {
  InboxRepository(this._api, this._cache);

  final Dio _api;
  final ApiCache _cache;

  /// Con copia local: la campana se ve sin señal.
  Future<Inbox> getMine({void Function()? onUpdated}) => _cache.get(
    '/inbox/me',
    (j) => Inbox.fromJson(j as Map<String, dynamic>),
    onUpdated: onUpdated,
  );

  /// ids null = todos.
  Future<void> markRead([List<String>? ids]) =>
      _api.post<void>('/inbox/me/read', data: {'ids': ids});
}

@Riverpod(keepAlive: true)
InboxRepository inboxRepository(Ref ref) =>
    InboxRepository(ref.watch(apiClientProvider), ref.watch(apiCacheProvider));
