import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../l10n/l10n.dart';
import '../data/password_policy.dart';
import '../providers/signup_controller.dart';

// Crear cuenta con email y contraseña (Google está en el Login). Después va
// al código de 6 dígitos que manda Supabase.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repeat = TextEditingController();

  @override
  void initState() {
    super.initState();
    // La lista de requisitos se tilda mientras escribe
    _password.addListener(() => setState(() {}));
    _email.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final email = _email.text.trim();
    final ok = await ref
        .read(signUpControllerProvider.notifier)
        .signUp(email, _password.text);
    if (ok && mounted) context.push(Routes.signUpCode(email));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final state = ref.watch(signUpControllerProvider);
    final loading = state.isLoading;
    final checks = PasswordChecks(_password.text, email: _email.text);

    return Scaffold(
      appBar: AppBar(backgroundColor: c.background),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.signupTitle,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(l.signupSubtitle,
                    style: TextStyle(color: c.textMuted, fontSize: 15, height: 1.5)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _email,
                  enabled: !loading,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: l.authEmail),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? l.authInvalidEmail : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  enabled: !loading,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: l.authPassword),
                  validator: (_) => checks.ok ? null : l.signupWeakPassword,
                ),
                const SizedBox(height: 12),
                _Rule(ok: checks.length, text: l.signupRuleLength),
                _Rule(ok: checks.letter, text: l.signupRuleLetter),
                _Rule(ok: checks.digit, text: l.signupRuleDigit),
                _Rule(
                  ok: checks.notEmail && _password.text.isNotEmpty,
                  text: l.signupRuleNotEmail,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _repeat,
                  enabled: !loading,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(labelText: l.signupRepeatPassword),
                  validator: (v) =>
                      v == _password.text ? null : l.signupPasswordsDontMatch,
                ),
                if (state.hasError) ...[
                  const SizedBox(height: 12),
                  Text(signUpErrorMessage(state.error!),
                      style: TextStyle(color: c.danger)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox(
                          width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l.signupSubmit),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l.signupHaveAccount, style: TextStyle(color: c.textMuted)),
                    TextButton(
                      onPressed: loading ? null : () => context.go(Routes.login),
                      child: Text(l.signupSignIn),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.ok, required this.text});

  final bool ok;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(ok ? Icons.check : Icons.circle_outlined,
            size: 18, color: ok ? c.turquoise : c.textMuted),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(fontSize: 13, color: ok ? c.textSecondary : c.textMuted)),
      ]),
    );
  }
}
