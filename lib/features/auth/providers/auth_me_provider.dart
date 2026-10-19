import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/cache/api_cache.dart';
import '../data/auth_me_dto.dart';

part 'auth_me_provider.g.dart';

// Quién es el usuario logueado para haki-api. Lo usa AthleteGate. Con caché:
// sin señal la app abre igual (Hoy, Programa y la Sesión funcionan offline).
@riverpod
Future<AuthMeDto> authMe(Ref ref) => ref
    .watch(apiCacheProvider)
    .get('/auth/me', (j) => AuthMeDto.fromJson(j as Map<String, dynamic>));
