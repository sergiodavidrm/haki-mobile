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
