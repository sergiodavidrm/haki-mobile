import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';

part 'api_check_provider.g.dart';

// Temporal: prueba de punta a punta (login Supabase → JWT → haki-api).
// Se reemplaza cuando exista la pantalla Hoy real.
@riverpod
Future<String> apiCheck(Ref ref) async {
  final res = await ref.watch(apiClientProvider).get<Map<String, dynamic>>('/auth/me');
  return 'API OK · userId ${res.data?['userId']}';
}
