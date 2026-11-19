import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../l10n/l10n.dart';
import '../data/auth_repository.dart';
import '../data/password_policy.dart';
import 'password_widgets.dart';

// Olvidé mi contraseña (canvas "Haki · Contraseñas", fila App): email →
// código de 6 dígitos → nueva contraseña. El código se confirma recién al
// guardar la nueva (verifyOTP tipo recovery + updateUser): si se confirmara
// antes aparecería la sesión y el router saltaría a Hoy sin dejar elegirla.
// Al guardar queda la sesión iniciada y el router manda a Hoy.

class ResetEmailScreen extends ConsumerStatefulWidget {
  const ResetEmailScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  ConsumerState<ResetEmailScreen> createState() => _ResetEmailScreenState();
}

class _ResetEmailScreenState extends ConsumerState<ResetEmailScreen> {
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      return setState(() => _error = context.l10n.authInvalidEmail);
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).sendPasswordCode(email);
      if (mounted) context.push(Routes.resetCode(email));
    } catch (e) {
      if (mounted) setState(() => _error = passwordErrorMessage(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(backgroundColor: c.background),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.resetTitle,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(l.resetSubtitle,
                  style: TextStyle(color: c.textMuted, fontSize: 15, height: 1.5)),
              const SizedBox(height: 32),
              TextField(
                controller: _email,
                enabled: !_sending,
                autofocus: widget.initialEmail.isEmpty,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(labelText: l.authEmail),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: c.danger)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _sending ? null : _send,
                child: _sending
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l.resetSendCode),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l.resetRemembered, style: TextStyle(color: c.textMuted)),
                  TextButton(
                    onPressed: () => context.go(Routes.login),
                    child: Text(l.signupSignIn),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetCodeScreen extends ConsumerStatefulWidget {
  const ResetCodeScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ResetCodeScreen> createState() => _ResetCodeScreenState();
}

class _ResetCodeScreenState extends ConsumerState<ResetCodeScreen> {
  final _code = TextEditingController();
  Timer? _timer;
  int _resendIn = passwordCodeCooldown;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _resendIn = passwordCodeCooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _resendIn--);
      if (_resendIn <= 0) t.cancel();
    });
  }

  void _next() {
    if (_code.text.length != passwordCodeLength) return;
    FocusScope.of(context).unfocus();
    context.push(Routes.resetNew(widget.email, _code.text));
  }

  Future<void> _resend() async {
    setState(() => _error = null);
    try {
      await ref.read(authRepositoryProvider).sendPasswordCode(widget.email);
      if (!mounted) return;
      _code.clear();
      _startCooldown();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.codeResent)));
    } catch (e) {
      if (mounted) setState(() => _error = passwordErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(backgroundColor: c.background),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.codeTitle,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(l.resetCodeSubtitle(widget.email),
                  style: TextStyle(color: c.textMuted, fontSize: 15, height: 1.5)),
              const SizedBox(height: 32),
              PasswordCodeField(
                controller: _code,
                autofocus: true,
                // Al completar los 6 dígitos pasa solo a la nueva contraseña
                onChanged: (v) {
                  setState(() {});
                  if (v.length == passwordCodeLength) _next();
                },
              ),
              const SizedBox(height: 10),
              Text(l.codeExpires, style: TextStyle(color: c.textMuted, fontSize: 13)),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: c.danger)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _code.text.length == passwordCodeLength ? _next : null,
                child: Text(l.resetNext),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _resendIn > 0 ? null : _resend,
                child: Text(_resendIn > 0 ? l.codeResendIn(_resendIn) : l.codeResend),
              ),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(l.resetOtherEmail),
              ),
              const SizedBox(height: 16),
              HakiCard(
                padding: const EdgeInsets.all(14),
                radius: 14,
                child: Text(l.codeHelp,
                    style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetNewPasswordScreen extends ConsumerStatefulWidget {
  const ResetNewPasswordScreen({super.key, required this.email, required this.code});

  final String email;
  final String code;

  @override
  ConsumerState<ResetNewPasswordScreen> createState() => _ResetNewPasswordScreenState();
}

class _ResetNewPasswordScreenState extends ConsumerState<ResetNewPasswordScreen> {
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  bool _saving = false;
  bool _badCode = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
    _repeat.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    if (!PasswordChecks(_password.text, email: widget.email).ok) {
      return setState(() => _error = l.signupWeakPassword);
    }
    if (_password.text != _repeat.text) {
      return setState(() => _error = l.signupPasswordsDontMatch);
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
      _badCode = false;
    });
    try {
      // Al confirmar el código aparece la sesión y el router manda a Hoy
      await ref
          .read(authRepositoryProvider)
          .setPasswordWithCode(widget.email, widget.code, _password.text);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = passwordErrorMessage(e);
        _badCode = e is AuthException && e.code == 'otp_expired';
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final checks = PasswordChecks(_password.text, email: widget.email);
    return Scaffold(
      appBar: AppBar(backgroundColor: c.background),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.resetNewTitle,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(l.resetNewSubtitle,
                  style: TextStyle(color: c.textMuted, fontSize: 15, height: 1.5)),
              const SizedBox(height: 32),
              TextField(
                controller: _password,
                enabled: !_saving,
                autofocus: true,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l.passwordNew),
              ),
              const SizedBox(height: 12),
              PasswordRules(checks: checks, showNotEmail: true),
              const SizedBox(height: 12),
              TextField(
                controller: _repeat,
                enabled: !_saving,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(labelText: l.passwordRepeat),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: c.danger)),
                if (_badCode)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: Text(l.resetBackToCode),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving || !checks.ok || _repeat.text.isEmpty ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l.resetSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
