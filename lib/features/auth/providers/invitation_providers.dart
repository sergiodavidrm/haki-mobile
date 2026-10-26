import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/cache/api_cache.dart';
import '../data/invitation_repository.dart';
import 'auth_me_provider.dart';

part 'invitation_providers.g.dart';

/// Invitación pendiente del usuario logueado (sin caché: hace falta la red
/// para aceptarla igual).
@riverpod
Future<MyInvitationDto?> myInvitation(Ref ref) =>
    ref.watch(invitationRepositoryProvider).getMine();

@riverpod
class InvitationAccepter extends _$InvitationAccepter {
  @override
  FutureOr<void> build() {}

  /// Acepta y recarga `/auth/me` desde la red: con eso AthleteGate deja pasar
  /// a la app.
  Future<void> accept(String invitationId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(invitationRepositoryProvider).accept(invitationId);
      ref.read(apiCacheProvider).expire(wait: true);
      ref.invalidate(authMeProvider);
    });
  }
}
