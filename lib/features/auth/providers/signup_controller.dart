import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../l10n/l10n.dart';
import '../data/auth_repository.dart';

part 'signup_controller.g.dart';

// Crear cuenta: idle / loading / error. Al crearla bien la pantalla va al
// código (todavía no hay sesión).
@riverpod
class SignUpController extends _$SignUpController {
  @override
  FutureOr<void> build() {}

  Future<bool> signUp(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signUp(email, password),
    );
    return !state.hasError;
  }
}

// Confirmar con el código. Al confirmar no navega: aparece la sesión y el
// router redirige a Hoy (AthleteGate muestra la invitación).
@riverpod
class SignUpCodeController extends _$SignUpCodeController {
  @override
  FutureOr<void> build() {}

  Future<void> verify(String email, String code) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).verifySignupCode(email, code),
    );
  }

  Future<bool> resend(String email) async {
    try {
      await ref.read(authRepositoryProvider).resendSignupCode(email);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

String signUpErrorMessage(Object error) {
  if (error is AuthException) {
    if (error.code == 'weak_password') return l10n.signupWeakPassword;
    // Supabase usa otp_expired también para un código equivocado
    if (error.code == 'otp_expired') return l10n.codeInvalid;
  }
  return l10n.signupError;
}
