import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/cache/api_cache.dart';
import '../data/auth_me_dto.dart';
import '../data/auth_repository.dart';

part 'auth_me_provider.g.dart';

// Quién es el usuario logueado para haki-api. Lo usa AthleteGate. Con caché
// (abre al instante con la copia y se actualiza en segundo plano): sin señal
// la app abre igual (Hoy, Programa y la Sesión funcionan offline).
@riverpod
Future<AuthMeDto> authMe(Ref ref) => ref
    .watch(apiCacheProvider)
    .get(
      '/auth/me',
      (j) => AuthMeDto.fromJson(j as Map<String, dynamic>),
      onUpdated: () {
        if (ref.mounted) ref.invalidateSelf();
      },
    );

/// Nombre a mostrar: el completo de haki-api (un atleta invitado entra con
/// email/password y Supabase no tiene su nombre); mientras carga o sin red,
/// el de Supabase o la parte local del email.
@riverpod
String displayName(Ref ref) {
  final fullName = ref.watch(authMeProvider).value?.fullName?.trim();
  if (fullName != null && fullName.isNotEmpty) return fullName;
  return ref.watch(authRepositoryProvider).displayName;
}
