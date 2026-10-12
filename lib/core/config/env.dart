// Config por ambiente, inyectada al compilar:
//   flutter run --dart-define-from-file=env/dev.json
// Todo lo que va acá queda dentro de la app (es público): nunca poner secretos.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const streamApiKey = String.fromEnvironment('STREAM_API_KEY');
  static const apiUrl = String.fromEnvironment('API_URL');

  // Login con Google: Client ID *Web* de Google Cloud (el mismo que está en
  // Supabase → Auth → Providers → Google). iOS además necesita su Client ID iOS.
  static const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  /// Falla rápido si se corrió sin --dart-define-from-file.
  static void validate() {
    final missing = {
      'SUPABASE_URL': supabaseUrl,
      'SUPABASE_ANON_KEY': supabaseAnonKey,
      'API_URL': apiUrl,
    }.entries.where((e) => e.value.isEmpty).map((e) => e.key);

    if (missing.isNotEmpty) {
      throw StateError(
        'Faltan variables de entorno: ${missing.join(', ')}. '
        'Correr con --dart-define-from-file=env/dev.json',
      );
    }
  }
}
