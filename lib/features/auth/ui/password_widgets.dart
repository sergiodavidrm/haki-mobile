import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../l10n/l10n.dart';
import '../data/password_policy.dart';

// Piezas comunes de Crear cuenta, Olvidé mi contraseña y Ajustes → contraseña
// (canvas "Haki · Contraseñas" https://claude.ai/artifact/LpgY2gwfCVYaJ5vnMMK3tT).

const passwordCodeLength = 6;
const passwordCodeCooldown = 60;

/// Requisitos que se tildan mientras escribe.
class PasswordRules extends StatelessWidget {
  const PasswordRules({super.key, required this.checks, this.showNotEmail = false});

  final PasswordChecks checks;
  final bool showNotEmail;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PasswordRule(ok: checks.length, text: l.signupRuleLength),
        PasswordRule(ok: checks.letter, text: l.signupRuleLetter),
        PasswordRule(ok: checks.digit, text: l.signupRuleDigit),
        if (showNotEmail)
          PasswordRule(
            ok: checks.notEmail && checks.password.isNotEmpty,
            text: l.signupRuleNotEmail,
          ),
      ],
    );
  }
}

class PasswordRule extends StatelessWidget {
  const PasswordRule({super.key, required this.ok, required this.text});

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

/// Código de 6 dígitos del email (mismo campo que Crear cuenta).
class PasswordCodeField extends StatelessWidget {
  const PasswordCodeField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.autofocus = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    enabled: enabled,
    autofocus: autofocus,
    keyboardType: TextInputType.number,
    autofillHints: const [AutofillHints.oneTimeCode],
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(passwordCodeLength),
    ],
    textAlign: TextAlign.center,
    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: 12),
    decoration: InputDecoration(labelText: context.l10n.codeLabel, counterText: ''),
    onChanged: onChanged,
  );
}

/// Errores de Supabase al cambiar, crear o recuperar la contraseña.
String passwordErrorMessage(Object? error) {
  if (error is AuthException) {
    return switch (error.code) {
      'invalid_credentials' => l10n.passwordCurrentWrong,
      'same_password' => l10n.passwordSame,
      'weak_password' => l10n.signupWeakPassword,
      // Supabase usa otp_expired también para un código equivocado
      'otp_expired' => l10n.codeInvalid,
      'over_email_send_rate_limit' || 'over_request_rate_limit' => l10n.passwordCodeTooSoon,
      _ => l10n.passwordChangeFailed,
    };
  }
  return l10n.errorOfflineRetry;
}
