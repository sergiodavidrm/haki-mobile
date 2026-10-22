import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/haki_logo.dart';
import '../providers/login_controller.dart';
import '../../../l10n/l10n.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(loginControllerProvider.notifier).signIn(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = ref.watch(loginControllerProvider);
    final loading = state.isLoading;
    final l = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const HakiLogo(),
                  const SizedBox(height: 10),
                  Text(l.slogan,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.textMuted, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 40),
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
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(labelText: l.authPassword),
                    validator: (v) => (v == null || v.isEmpty) ? l.authEnterPassword : null,
                  ),
                  if (state.hasError) ...[
                    const SizedBox(height: 12),
                    Text(loginErrorMessage(state.error!), style: TextStyle(color: c.danger)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const SizedBox(
                            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l.authSignIn),
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: Divider(color: c.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('o', style: TextStyle(color: c.textMuted)),
                    ),
                    Expanded(child: Divider(color: c.border)),
                  ]),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: loading
                        ? null
                        : () => ref.read(loginControllerProvider.notifier).signInWithGoogle(),
                    icon: const Text('G',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    label: Text(l.authContinueGoogle),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
