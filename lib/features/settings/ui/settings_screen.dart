import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_client.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../../session/data/session_store.dart';
import '../providers/settings_providers.dart';
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
                if (auth.hasPassword)
                  _Row(
                    title: l.settingsChangePassword,
                    onTap: () => _showPasswordSheet(context),
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

Future<void> _showPasswordSheet(BuildContext context) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: context.colors.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder: (_) => const _PasswordSheet(),
);

class _PasswordSheet extends ConsumerStatefulWidget {
  const _PasswordSheet();

  @override
  ConsumerState<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends ConsumerState<_PasswordSheet> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final p = _password.text;
    if (p.length < 6) {
      return setState(() => _error = context.l10n.passwordMinLength);
    }
    if (p != _confirm.text) {
      return setState(() => _error = context.l10n.passwordsDontMatch);
    }
    setState(() => _error = null);
    final ok = await ref.read(passwordChangerProvider.notifier).change(p);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.passwordUpdated)));
    } else {
      setState(
        () => _error = _passwordError(ref.read(passwordChangerProvider).error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final saving = ref.watch(passwordChangerProvider).isLoading;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        20,
        16,
        28 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.settingsChangePassword,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: c.text,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _password,
            obscureText: true,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: l.passwordNew),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirm,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(labelText: l.passwordRepeat),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: TextStyle(fontSize: 13, color: c.danger)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: saving ? null : _save,
            child: Text(saving ? l.commonSaving : l.commonSave),
          ),
        ],
      ),
    );
  }
}

/// Errores de Supabase al cambiar la contraseña, traducidos.
String _passwordError(Object? error) {
  if (error is AuthException) {
    return switch (error.code) {
      'same_password' => l10n.passwordSame,
      'weak_password' => l10n.passwordWeak,
      'reauthentication_needed' => l10n.passwordReauth,
      _ => l10n.passwordChangeFailed,
    };
  }
  return l10n.errorOfflineRetry;
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
