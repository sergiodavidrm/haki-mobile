import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';
import '../../../l10n/l10n.dart';

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
    if (error.code == 'invalid_credentials') return l10n.authWrongCredentials;
    if (error.code == 'email_not_confirmed') return l10n.authConfirmEmail;
  }
  if (error is GoogleSignInException) return l10n.authGoogleError;
  return l10n.authGenericError;
}
