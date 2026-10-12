import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../data/auth_me_dto.dart';

part 'auth_me_provider.g.dart';

// Quién es el usuario logueado para haki-api. Lo usa AthleteGate.
@riverpod
Future<AuthMeDto> authMe(Ref ref) async {
  final res = await ref.watch(apiClientProvider).get<Map<String, dynamic>>('/auth/me');
  return AuthMeDto.fromJson(res.data!);
}
