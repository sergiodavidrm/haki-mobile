import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../l10n/l10n.dart';
import '../providers/signup_controller.dart';

const _codeLength = 6;
const _resendCooldown = 60;

// Código de 6 dígitos del email de Supabase. Al confirmarlo aparece la sesión
// y el router manda a Hoy (AthleteGate muestra la invitación).
class SignUpCodeScreen extends ConsumerStatefulWidget {
  const SignUpCodeScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<SignUpCodeScreen> createState() => _SignUpCodeScreenState();
}

class _SignUpCodeScreenState extends ConsumerState<SignUpCodeScreen> {
  final _code = TextEditingController();
  Timer? _timer;
  int _resendIn = _resendCooldown;

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
    setState(() => _resendIn = _resendCooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _resendIn--);
      if (_resendIn <= 0) t.cancel();
    });
  }

  void _verify() {
    if (_code.text.length != _codeLength) return;
    FocusScope.of(context).unfocus();
    ref.read(signUpCodeControllerProvider.notifier).verify(widget.email, _code.text);
  }

  Future<void> _resend() async {
    final ok = await ref.read(signUpCodeControllerProvider.notifier).resend(widget.email);
    if (!ok || !mounted) return;
    _startCooldown();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.codeResent)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final state = ref.watch(signUpCodeControllerProvider);
    final loading = state.isLoading;

    return Scaffold(
      appBar: AppBar(backgroundColor: c.background),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: c.turquoiseSurface,
                    border: Border.all(color: c.turquoiseBorder),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.mail_outline, color: c.turquoise),
                ),
              ),
              const SizedBox(height: 24),
              Text(l.codeTitle,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(l.codeSubtitle(widget.email),
                  style: TextStyle(color: c.textMuted, fontSize: 15, height: 1.5)),
              const SizedBox(height: 32),
              TextField(
                controller: _code,
                enabled: !loading,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_codeLength),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 12),
                decoration: InputDecoration(labelText: l.codeLabel, counterText: ''),
                // Al completar los 6 dígitos confirma solo
                onChanged: (v) {
                  setState(() {});
                  if (v.length == _codeLength) _verify();
                },
              ),
              const SizedBox(height: 10),
              Text(l.codeExpires, style: TextStyle(color: c.textMuted, fontSize: 13)),
              if (state.hasError) ...[
                const SizedBox(height: 12),
                Text(signUpErrorMessage(state.error!), style: TextStyle(color: c.danger)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: loading || _code.text.length != _codeLength ? null : _verify,
                child: loading
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l.codeConfirm),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _resendIn > 0 || loading ? null : _resend,
                child: Text(_resendIn > 0 ? l.codeResendIn(_resendIn) : l.codeResend),
              ),
              const SizedBox(height: 24),
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
