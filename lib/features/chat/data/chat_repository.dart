import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';

part 'chat_repository.g.dart';

/// Token de Stream del usuario logueado (lo firma la API: el secret de Stream
/// nunca está en la app).
class StreamTokenDto {
  const StreamTokenDto({
    required this.token,
    required this.userId,
    required this.userName,
  });

  final String token;

  /// Id del usuario en Stream (el Guid sin guiones).
  final String userId;
  final String userName;

  factory StreamTokenDto.fromJson(Map<String, dynamic> j) => StreamTokenDto(
    token: j['token'] as String,
    userId: j['userId'] as String,
    userName: j['userName'] as String? ?? '',
  );
}

class ChatRepository {
  ChatRepository(this._api);

  final Dio _api;

  Future<StreamTokenDto> token() async {
    final res = await _api.get<Map<String, dynamic>>('/stream/token');
    return StreamTokenDto.fromJson(res.data!);
  }

  /// Canal general con el coach (lo crea si no existe). Devuelve (type, id).
  Future<(String, String)> generalChannel() async {
    final res = await _api.post<Map<String, dynamic>>(
      '/stream/channel/general',
    );
    return (
      res.data!['channelType'] as String,
      res.data!['channelId'] as String,
    );
  }
}

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) =>
    ChatRepository(ref.watch(apiClientProvider));
