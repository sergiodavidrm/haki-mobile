import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';
import '../../../core/supabase/supabase_providers.dart';

part 'auth_repository.g.dart';

// Los atletas entran con email/password (los crea la invitación del coach) o con
// Google. Google con el mismo email (ya confirmado por la invitación) queda
// vinculado por Supabase al mismo usuario → mismo userId en haki-api.
class AuthRepository {
  AuthRepository(this._auth);

  final GoTrueClient _auth;
  Future<void>? _googleInit;

  bool get isLoggedIn => _auth.currentSession != null;

  String? get email => _auth.currentUser?.email;

  String? get userId => _auth.currentUser?.id;

  /// Nombre de Supabase (Google lo trae en `full_name`/`name`); si no hay,
  /// la parte local del email.
  String get displayName {
    final meta = _auth.currentUser?.userMetadata ?? const {};
    final name = (meta['full_name'] ?? meta['name']) as String?;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    return email?.split('@').first ?? '';
  }

  /// Entra con email/password (la invitación le pidió una). Solo con Google no
  /// tiene contraseña que cambiar.
  bool get hasPassword =>
      _auth.currentUser?.identities?.any((i) => i.provider == 'email') ?? false;

  Stream<AuthState> authChanges() => _auth.onAuthStateChange;

  Future<void> changePassword(String password) =>
      _auth.updateUser(UserAttributes(password: password));

  Future<void> signIn(String email, String password) =>
      _auth.signInWithPassword(email: email.trim(), password: password);

  /// Login nativo (selector de cuentas del sistema) → id token → Supabase.
  /// Devuelve false si el usuario cerró el selector.
  Future<bool> signInWithGoogle() async {
    if (Env.googleWebClientId.isEmpty) {
      throw StateError('Falta GOOGLE_WEB_CLIENT_ID en env/*.json');
    }
    final google = GoogleSignIn.instance;
    await (_googleInit ??= google.initialize(
      serverClientId: Env.googleWebClientId,
      clientId: Env.googleIosClientId.isEmpty ? null : Env.googleIosClientId,
    ));

    final GoogleSignInAccount account;
    try {
      account = await google.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return false;
      rethrow;
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) throw StateError('Google no devolvió id token');

    await _auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
    return true;
  }

  Future<void> signOut() async {
    // Para que la próxima vez vuelva a mostrar el selector de cuentas
    if (_googleInit != null) await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(supabaseClientProvider).auth);
