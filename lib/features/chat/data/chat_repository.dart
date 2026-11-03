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

/// Grupo del coach en el que está el atleta (`GET chat-groups/me`).
class ChatGroupDto {
  const ChatGroupDto({
    required this.id,
    required this.name,
    required this.channelType,
    required this.channelId,
    required this.athletesCanWrite,
    required this.coachName,
    required this.coachStreamId,
  });

  final String id;
  final String name;
  final String channelType;
  final String channelId;

  /// false = "Solo el coach escribe": el atleta solo reacciona.
  final bool athletesCanWrite;
  final String coachName;

  /// Id del coach en Stream (para marcarlo "Coach" en la lista de integrantes).
  final String coachStreamId;

  factory ChatGroupDto.fromJson(Map<String, dynamic> j) => ChatGroupDto(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    channelType: j['channelType'] as String,
    channelId: j['channelId'] as String,
    athletesCanWrite: j['athletesCanWrite'] as bool? ?? true,
    coachName: j['coachName'] as String? ?? '',
    coachStreamId: j['coachStreamId'] as String? ?? '',
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

  Future<List<ChatGroupDto>> groups() async {
    final res = await _api.get<List<dynamic>>('/chat-groups/me');
    return (res.data ?? const [])
        .map((e) => ChatGroupDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Salir de un grupo (solo el coach lo puede volver a agregar).
  Future<void> leaveGroup(String groupId) =>
      _api.post<void>('/chat-groups/$groupId/leave');
}

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) =>
    ChatRepository(ref.watch(apiClientProvider));
