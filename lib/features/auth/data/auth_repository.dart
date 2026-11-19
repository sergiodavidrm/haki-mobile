import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';
import '../../../core/supabase/supabase_providers.dart';

part 'auth_repository.g.dart';

// Los atletas entran con email/password (cuenta creada en la app y confirmada
// con el código del email) o con Google. Google con el mismo email (ya
// confirmado) queda vinculado por Supabase al mismo usuario → mismo userId en
// haki-api. La invitación del coach se acepta después, con la sesión
// (InvitationRepository).
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

  /// Tiene contraseña: cuenta creada con email, o de Google que después creó
  /// una. Supabase no le agrega la identidad `email` a una cuenta de Google
  /// que guarda contraseña, por eso además se marca `has_password` en
  /// user_metadata (ver [setPassword]).
  bool get hasPassword {
    final user = _auth.currentUser;
    if (user == null) return false;
    if (user.identities?.any((i) => i.provider == 'email') ?? false) return true;
    return user.userMetadata?['has_password'] == true;
  }

  Stream<AuthState> authChanges() => _auth.onAuthStateChange;

  /// Guarda la contraseña nueva y marca `has_password`.
  Future<void> setPassword(String password) => _auth.updateUser(
    UserAttributes(password: password, data: {'has_password': true}),
  );

  /// Cambiar: comprueba la actual con un login (Supabase no la pide para
  /// cambiarla) y después guarda la nueva. Mismo usuario: no cambia nada más.
  Future<void> changePassword(String current, String password) async {
    final email = this.email;
    if (email == null) throw StateError('Sin sesión');
    await _auth.signInWithPassword(email: email, password: current);
    await setPassword(password);
  }

  /// Manda el código de 6 dígitos para crear o recuperar la contraseña
  /// (plantilla "Reset password" de Supabase con `{{ .Token }}`). Si el email
  /// no tiene cuenta, Supabase no avisa.
  Future<void> sendPasswordCode(String email) =>
      _auth.resetPasswordForEmail(email.trim());

  /// Confirma el código y guarda la contraseña. Con o sin sesión: sin sesión
  /// (olvidé mi contraseña) deja la sesión iniciada y el router manda a Hoy.
  /// Supabase valida este código siempre, aunque "Secure password change"
  /// esté apagado (el nonce de `reauthenticate()` solo se valida con esa
  /// opción prendida: por eso no se usa).
  Future<void> setPasswordWithCode(
    String email,
    String code,
    String password,
  ) async {
    await _auth.verifyOTP(
      type: OtpType.recovery,
      email: email.trim(),
      token: code.trim(),
    );
    await setPassword(password);
  }

  Future<void> signIn(String email, String password) =>
      _auth.signInWithPassword(email: email.trim(), password: password);

  /// Crea la cuenta. Con "Confirm email" de Supabase no hay sesión hasta
  /// confirmar con el código de 6 dígitos que llega por email (plantilla
  /// "Confirm signup" con `{{ .Token }}`). Si el email ya tiene cuenta,
  /// Supabase no da error (para no revelar qué emails existen) y no manda nada.
  Future<void> signUp(String email, String password) =>
      _auth.signUp(email: email.trim(), password: password);

  /// Confirma el email con el código; deja la sesión iniciada (el router
  /// redirige solo).
  Future<void> verifySignupCode(String email, String code) => _auth.verifyOTP(
    type: OtpType.signup,
    email: email.trim(),
    token: code.trim(),
  );

  Future<void> resendSignupCode(String email) =>
      _auth.resend(type: OtpType.signup, email: email.trim());

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

  /// Lo que hay que hacer con la sesión todavía abierta (p. ej. borrar este
  /// teléfono de los push de la API, que necesita el JWT). Sin red no frena.
  Future<void> Function()? beforeSignOut;

  Future<void> signOut() async {
    try {
      await beforeSignOut?.call().timeout(const Duration(seconds: 4));
    } catch (_) {}
    // Para que la próxima vez vuelva a mostrar el selector de cuentas
    if (_googleInit != null) await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(supabaseClientProvider).auth);
