import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/legal/legal_links.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/password_policy.dart';
import '../../auth/ui/password_widgets.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../../session/data/session_store.dart';
import '../providers/settings_providers.dart';
import '../../share/providers/share_providers.dart';
import '../../levels/providers/level_providers.dart';
import '../../../l10n/l10n.dart';

// Ajustes: cuenta (Mis datos, cambiar contraseña), unidad de peso, vibración del timer,
// tema, idioma y cerrar sesión. Del mockup faltan (sin backend o sin
// integración): subir videos solo con Wi-Fi, notificaciones, Google Fit,
// ayuda, términos y la versión de la app.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final auth = ref.watch(authRepositoryProvider);
    final unit =
        ref.watch(authMeProvider).value?.preferredWeightUnit ?? WeightUnit.kg;
    final savingUnit = ref.watch(weightUnitSaverProvider).isLoading;
    final vibrate = ref.watch(restVibrationProvider);
    final autoRest = ref.watch(autoRestProvider);
    final share = ref.watch(shareWorkoutsEnabledProvider);
    // Solo si el coach prendió los niveles en el web
    final coachLevels = ref.watch(authMeProvider).value?.levelsEnabled ?? false;
    final showLevels = ref.watch(showGamificationProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            BackHeader(title: l.settingsTitle, titleSize: 22),
            const SizedBox(height: 12),
            _Section(l.settingsAccount),
            _Group(
              children: [
                _Row(
                  title: ref.watch(displayNameProvider),
                  subtitle: auth.email,
                  onTap: () => context.push(Routes.personalInfo),
                  trailing: Icon(Icons.chevron_right, color: c.textMuted),
                ),
                // Con contraseña: Cambiar (pide la actual). Solo Google: Crear
                // (pide un código del email).
                _Row(
                  title: auth.hasPassword
                      ? l.settingsChangePassword
                      : l.settingsCreatePassword,
                  subtitle: auth.hasPassword ? null : l.settingsCreatePasswordHint,
                  onTap: () => _showPasswordSheet(context, withCode: !auth.hasPassword),
                  trailing: Icon(Icons.chevron_right, color: c.textMuted),
                ),
              ],
            ),
            _Section(l.settingsTraining),
            _Group(
              children: [
                _Row(
                  title: l.settingsWeightUnit,
                  subtitle: l.settingsWeightUnitHint,
                  trailing: SegmentedButton<WeightUnit>(
                    segments: [
                      for (final u in WeightUnit.values)
                        ButtonSegment(value: u, label: Text(u.label)),
                    ],
                    selected: {unit},
                    showSelectedIcon: false,
                    onSelectionChanged: savingUnit
                        ? null
                        : (s) => _saveUnit(context, ref, s.first),
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: c.gold,
                      selectedForegroundColor: c.onAccent,
                      foregroundColor: c.textMuted,
                      side: BorderSide(color: c.border),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                _Row(
                  title: l.settingsAutoRest,
                  subtitle: l.settingsAutoRestHint,
                  trailing: Switch(
                    value: autoRest,
                    activeTrackColor: c.turquoise,
                    onChanged: ref.read(autoRestProvider.notifier).set,
                  ),
                ),
                _Row(
                  title: l.settingsShare,
                  subtitle: l.settingsShareHint,
                  trailing: Switch(
                    value: share,
                    activeTrackColor: c.turquoise,
                    onChanged: ref.read(shareWorkoutsEnabledProvider.notifier).set,
                  ),
                ),
                if (coachLevels)
                  _Row(
                    title: l.settingsShowLevels,
                    subtitle: l.settingsShowLevelsHint,
                    trailing: Switch(
                      value: showLevels,
                      activeTrackColor: c.turquoise,
                      onChanged: ref.read(showGamificationProvider.notifier).set,
                    ),
                  ),
                _Row(
                  title: l.settingsRestVibration,
                  trailing: Switch(
                    value: vibrate,
                    activeTrackColor: c.turquoise,
                    onChanged: ref.read(restVibrationProvider.notifier).set,
                  ),
                ),
              ],
            ),
            _Section(l.settingsAppearance),
            _Group(
              children: [
                _Row(
                  title: l.settingsTheme,
                  trailing: SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(l.settingsSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(l.settingsThemeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(l.settingsThemeDark),
                      ),
                    ],
                    selected: {ref.watch(appThemeModeProvider)},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) =>
                        ref.read(appThemeModeProvider.notifier).set(s.first),
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: c.gold,
                      selectedForegroundColor: c.onAccent,
                      foregroundColor: c.textMuted,
                      side: BorderSide(color: c.border),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                _Row(
                  title: l.settingsLanguage,
                  trailing: SegmentedButton<AppLanguage>(
                    segments: [
                      ButtonSegment(
                        value: AppLanguage.system,
                        label: Text(l.settingsSystem),
                      ),
                      const ButtonSegment(
                        value: AppLanguage.es,
                        label: Text('ES'),
                      ),
                      const ButtonSegment(
                        value: AppLanguage.en,
                        label: Text('EN'),
                      ),
                    ],
                    selected: {ref.watch(appLanguageSettingProvider)},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => ref
                        .read(appLanguageSettingProvider.notifier)
                        .set(s.first),
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: c.gold,
                      selectedForegroundColor: c.onAccent,
                      foregroundColor: c.textMuted,
                      side: BorderSide(color: c.border),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
            _Section(l.legalSection),
            _Group(
              children: [
                _Row(
                  title: l.legalTermsFull,
                  trailing: Icon(Icons.open_in_new, size: 18, color: c.textMuted),
                  onTap: () => openLegal(LegalUrls.terms),
                ),
                _Row(
                  title: l.legalPrivacyPolicy,
                  trailing: Icon(Icons.open_in_new, size: 18, color: c.textMuted),
                  onTap: () => openLegal(LegalUrls.privacy),
                ),
                _Row(
                  title: l.legalHelp,
                  trailing: Icon(Icons.open_in_new, size: 18, color: c.textMuted),
                  onTap: () => openLegal(LegalUrls.help),
                ),
              ],
            ),
            if (ref.watch(authMeProvider).value?.termsAcceptedAt case final at?) ...[
              const SizedBox(height: 8),
              Text(l.legalAcceptedOn('${formatDayMonth(at)} ${at.year}'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.textMuted, fontSize: 12)),
            ],
            const SizedBox(height: 18),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: c.danger,
                side: BorderSide(color: c.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _signOut(context, ref),
              child: Text(l.settingsSignOut),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _saveUnit(
  BuildContext context,
  WidgetRef ref,
  WeightUnit unit,
) async {
  final ok = await ref.read(weightUnitSaverProvider.notifier).save(unit);
  if (!ok && context.mounted) {
    final error = ref.read(weightUnitSaverProvider).error;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error ?? 'error'))));
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
    child: SectionLabel(text),
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return HakiCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (i, child) in children.indexed)
            DecoratedBox(
              decoration: BoxDecoration(
                border: i == children.length - 1
                    ? null
                    : Border(bottom: BorderSide(color: c.surfaceHigh)),
              ),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, this.subtitle, this.trailing, this.onTap});

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: TextStyle(fontSize: 12, color: c.textMuted),
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );
  }
}

Future<void> _showPasswordSheet(BuildContext context, {required bool withCode}) =>
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PasswordSheet(withCode: withCode),
    );

/// Cambiar contraseña (con la actual) o Crear contraseña (cuenta solo de
/// Google, con un código del email). "¿No te la acordás?" pasa al modo código.
/// Canvas "Haki · Contraseñas" https://claude.ai/artifact/LpgY2gwfCVYaJ5vnMMK3tT.
class _PasswordSheet extends ConsumerStatefulWidget {
  const _PasswordSheet({required this.withCode});

  final bool withCode;

  @override
  ConsumerState<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends ConsumerState<_PasswordSheet> {
  final _current = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  late bool _withCode = widget.withCode;
  // Solo Google: crear (no "cambiar")
  late final bool _creating = widget.withCode;
  Timer? _timer;
  int _resendIn = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final t in [_current, _code, _password, _confirm]) {
      t.addListener(() => setState(() {}));
    }
    if (_withCode) _sendCode();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final t in [_current, _code, _password, _confirm]) {
      t.dispose();
    }
    super.dispose();
  }

  Future<void> _sendCode() async {
    final auth = ref.read(authRepositoryProvider);
    setState(() => _error = null);
    try {
      await auth.sendPasswordCode(auth.email ?? '');
      if (!mounted) return;
      _timer?.cancel();
      setState(() => _resendIn = passwordCodeCooldown);
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return t.cancel();
        setState(() => _resendIn--);
        if (_resendIn <= 0) t.cancel();
      });
    } catch (e) {
      if (mounted) setState(() => _error = passwordErrorMessage(e));
    }
  }

  void _useCode() {
    setState(() => _withCode = true);
    _sendCode();
  }

  bool get _canSave {
    final email = ref.read(authRepositoryProvider).email ?? '';
    final first = _withCode
        ? _code.text.length == passwordCodeLength
        : _current.text.isNotEmpty;
    return first &&
        PasswordChecks(_password.text, email: email).ok &&
        _confirm.text.isNotEmpty;
  }

  Future<void> _save() async {
    if (_password.text != _confirm.text) {
      return setState(() => _error = context.l10n.passwordsDontMatch);
    }
    setState(() => _error = null);
    final saver = ref.read(passwordChangerProvider.notifier);
    final ok = _withCode
        ? await saver.setWithCode(_code.text, _password.text)
        : await saver.change(_current.text, _password.text);
    if (!mounted) return;
    if (ok) {
      final l = context.l10n;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_creating ? l.passwordCreated : l.passwordUpdated)),
      );
    } else {
      setState(
        () => _error = passwordErrorMessage(ref.read(passwordChangerProvider).error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final email = ref.watch(authRepositoryProvider).email ?? '';
    final saving = ref.watch(passwordChangerProvider).isLoading;
    final checks = PasswordChecks(_password.text, email: email);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        20,
        16,
        28 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _creating ? l.settingsCreatePassword : l.settingsChangePassword,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c.text),
            ),
            if (_creating) ...[
              const SizedBox(height: 8),
              Text(l.passwordCreateHint,
                  style: TextStyle(fontSize: 14, height: 1.45, color: c.textSecondary)),
            ],
            const SizedBox(height: 16),
            if (_withCode) ...[
              Text(l.passwordCodeSentTo(email),
                  style: TextStyle(fontSize: 13, color: c.textMuted)),
              const SizedBox(height: 8),
              PasswordCodeField(controller: _code, autofocus: true),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _resendIn > 0 ? null : _sendCode,
                  child: Text(_resendIn > 0 ? l.codeResendIn(_resendIn) : l.codeResend),
                ),
              ),
            ] else ...[
              TextField(
                controller: _current,
                obscureText: true,
                autofocus: true,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l.passwordCurrent),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(onPressed: _useCode, child: Text(l.passwordForgotCurrent)),
              ),
            ],
            const SizedBox(height: 4),
            TextField(
              controller: _password,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: _creating ? l.authPassword : l.passwordNew,
              ),
            ),
            const SizedBox(height: 8),
            PasswordRules(checks: checks),
            const SizedBox(height: 8),
            TextField(
              controller: _confirm,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _canSave ? _save() : null,
              decoration: InputDecoration(labelText: l.passwordRepeat),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: TextStyle(fontSize: 13, color: c.danger)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: saving || !_canSave ? null : _save,
              child: Text(
                saving
                    ? l.commonSaving
                    : _creating
                    ? l.settingsCreatePassword
                    : l.commonSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cerrar sesión borra los datos del teléfono (LocalDataGuard): si queda algo
/// sin subir, avisar antes de perderlo.
Future<void> _signOut(BuildContext context, WidgetRef ref) async {
  final pending = await ref.read(sessionStoreProvider).pendingCount();
  if (pending > 0 && context.mounted) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.signOutPendingTitle),
        content: Text(ctx.l10n.signOutPendingBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.signOutAnyway),
          ),
        ],
      ),
    );
    if (ok != true) return;
  }
  await ref.read(authRepositoryProvider).signOut();
}
