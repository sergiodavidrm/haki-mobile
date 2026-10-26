import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';

part 'invitation_repository.g.dart';

/// `GET /invitations/me`: la invitación pendiente para el email de la sesión.
class MyInvitationDto {
  const MyInvitationDto({
    required this.id,
    required this.email,
    required this.coachName,
    this.coachingSince,
  });

  final String id;
  final String email;
  final String coachName;

  /// Año en que el coach empezó (para "N años de experiencia").
  final int? coachingSince;

  factory MyInvitationDto.fromJson(Map<String, dynamic> j) => MyInvitationDto(
    id: j['id'] as String,
    email: j['email'] as String,
    coachName: j['coachName'] as String,
    coachingSince: (j['coachingSince'] as num?)?.toInt(),
  );
}

// El atleta acepta la invitación con su sesión: la API toma el email del JWT
// y solo acepta si coincide con el de la invitación.
class InvitationRepository {
  InvitationRepository(this._api);

  final Dio _api;

  Future<MyInvitationDto?> getMine() async {
    final res = await _api.get<Map<String, dynamic>>('/invitations/me');
    final invitation = res.data?['invitation'];
    return invitation == null
        ? null
        : MyInvitationDto.fromJson(invitation as Map<String, dynamic>);
  }

  Future<void> accept(String invitationId) =>
      _api.post<void>('/invitations/$invitationId/accept');
}

@Riverpod(keepAlive: true)
InvitationRepository invitationRepository(Ref ref) =>
    InvitationRepository(ref.watch(apiClientProvider));
