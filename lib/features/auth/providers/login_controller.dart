import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

part 'login_controller.g.dart';

// Estado del formulario de login: idle / loading / error.
// Al loguear bien no navega: el router escucha el cambio de sesión y redirige.
@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(email, password),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    // Si cierra el selector de cuentas no es error: vuelve a idle
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    });
  }
}

String loginErrorMessage(Object error) {
  if (error is AuthException) {
    if (error.code == 'invalid_credentials') return 'Email o contraseña incorrectos';
    if (error.code == 'email_not_confirmed') return 'Confirmá tu email antes de entrar';
  }
  if (error is GoogleSignInException) return 'No se pudo entrar con Google. Intentá de nuevo.';
  return 'No se pudo iniciar sesión. Revisá tu conexión e intentá de nuevo.';
}
