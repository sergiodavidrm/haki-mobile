import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/env.dart';
import '../supabase/supabase_providers.dart';

part 'api_client.g.dart';

// Cliente HTTP para haki-api (equivalente a DataService + authInterceptor del web).
// Base: Env.apiUrl (ya incluye /api/v1). Agrega el JWT de Supabase a cada request;
// supabase_flutter refresca el token solo, así que siempre se lee el actual.
@Riverpod(keepAlive: true)
Dio apiClient(Ref ref) {
  final auth = ref.watch(supabaseClientProvider).auth;

  final dio = Dio(BaseOptions(
    baseUrl: Env.apiUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = auth.currentSession?.accessToken;
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    },
  ));

  return dio;
}

/// Mensaje para mostrar de un error de la API: el `detail` del ProblemDetails
/// (ApiExceptionHandler) o uno genérico según el caso.
String apiErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['detail'] is String) {
      return data['detail'] as String;
    }
    if (error.response == null) return 'Sin conexión. Probá de nuevo.';
  }
  return 'Algo salió mal. Probá de nuevo.';
}
