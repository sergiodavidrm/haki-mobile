import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../../body/data/body_measures.dart';
import '../../body/providers/body_providers.dart';
import '../data/personal_info.dart';
import '../providers/settings_providers.dart';
import '../../../l10n/l10n.dart';

// Ajustes → Mis datos (mockup "Mis datos"): nombre, género, estatura y
// lesiones editables; email y objetivo (lo define el coach) solo lectura; el
// peso sale del último registro y se carga en Peso corporal. Lo edita también
// el coach desde el web: gana el último que guarda. Sin aviso al coach.
class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  late final PersonalInfoDto? _initial = ref
      .read(authMeProvider)
      .value
      ?.personal;
  late final _name = TextEditingController(
    text: ref.read(authMeProvider).value?.fullName ?? '',
  );
  late final _cm = TextEditingController(
    text: _initial?.heightCm == null ? '' : formatWeight(_initial!.heightCm!),
  );
  late final _feet = TextEditingController(text: _ftIn?.feet.toString() ?? '');
  late final _inches = TextEditingController(
    text: _ftIn?.inches.toString() ?? '',
  );
  late final _injuries = TextEditingController(text: _initial?.injuries ?? '');
  late Gender? _gender = _initial?.gender;
  late HeightUnit _unit = _initial?.heightUnit ?? HeightUnit.cm;
  String? _error;

  ({int feet, int inches})? get _ftIn =>
      _initial?.heightCm == null ? null : cmToFeetInches(_initial!.heightCm!);

  @override
  void dispose() {
    _name.dispose();
    _cm.dispose();
    _feet.dispose();
    _inches.dispose();
    _injuries.dispose();
    super.dispose();
  }

  /// Estatura en cm de lo escrito (null = vacía); en ft+in convierte.
  double? get _heightCm {
    if (_unit == HeightUnit.cm) {
      return double.tryParse(_cm.text.trim().replaceAll(',', '.'));
    }
    final feet = int.tryParse(_feet.text.trim());
    final inches = int.tryParse(_inches.text.trim());
    if (feet == null && inches == null) return null;
    return feetInchesToCm(feet ?? 0, inches ?? 0);
  }

  /// Al cambiar de unidad se pasa lo escrito a la otra.
  void _setUnit(HeightUnit unit) {
    final cm = _heightCm;
    setState(() => _unit = unit);
    if (cm == null) return;
    if (unit == HeightUnit.cm) {
      _cm.text = formatWeight(cm);
    } else {
      final v = cmToFeetInches(cm);
      _feet.text = '${v.feet}';
      _inches.text = '${v.inches}';
    }
  }

  Future<void> _save() async {
    final l = context.l10n;
    final name = _name.text.trim();
    final cm = _heightCm;
    if (name.isEmpty) return setState(() => _error = l.personalNameRequired);
    if (cm != null && (cm < 50 || cm > 260)) {
      return setState(() => _error = l.personalHeightInvalid);
    }
    setState(() => _error = null);
    final injuries = _injuries.text.trim();
    final ok = await ref
        .read(personalInfoSaverProvider.notifier)
        .save(
          fullName: name,
          gender: _gender,
          heightCm: cm,
          heightUnit: _unit,
          injuries: injuries.isEmpty ? null : injuries,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.personalSaved)));
      context.pop();
    } else {
      setState(
        () => _error = apiErrorMessage(
          ref.read(personalInfoSaverProvider).error ?? 'error',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final me = ref.watch(authMeProvider).value;
    final coach = me?.coachName?.split(' ').first;
    final saving = ref.watch(personalInfoSaverProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            BackHeader(title: l.personalTitle, titleSize: 22),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Text(
                coach == null ? l.personalIntroNoCoach : l.personalIntro(coach),
                style: TextStyle(fontSize: 13, color: c.textMuted),
              ),
            ),
            _Section(l.personalSection),
            HakiCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l.personalName),
                  ),
                  const SizedBox(height: 14),
                  _Label(l.personalEmail),
                  Container(
                    height: 48,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: c.surfaceHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _initial?.email ?? '',
                      style: TextStyle(fontSize: 16, color: c.textMuted),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _Help(l.personalEmailHint),
                  const SizedBox(height: 14),
                  _Label(l.personalGender),
                  _Segmented<Gender>(
                    values: Gender.values,
                    labelOf: (g) => switch (g) {
                      Gender.m => l.genderMale,
                      Gender.f => l.genderFemale,
                      Gender.other => l.genderOther,
                    },
                    selected: _gender,
                    onChanged: (g) => setState(() => _gender = g),
                    expand: true,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _Label(l.personalHeight)),
                      _Segmented<HeightUnit>(
                        values: HeightUnit.values,
                        labelOf: (u) => u == HeightUnit.cm ? 'cm' : 'ft',
                        selected: _unit,
                        onChanged: (u) {
                          if (u != null) _setUnit(u);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_unit == HeightUnit.cm)
                    Row(
                      children: [
                        _NumberField(
                          controller: _cm,
                          width: 120,
                          decimal: true,
                          label: l.personalHeight,
                        ),
                        const SizedBox(width: 10),
                        _Unit('cm'),
                      ],
                    )
                  else
                    Row(
                      children: [
                        _NumberField(
                          controller: _feet,
                          width: 80,
                          label: '${l.personalHeight} ft',
                        ),
                        const SizedBox(width: 8),
                        _Unit('ft'),
                        const SizedBox(width: 12),
                        _NumberField(
                          controller: _inches,
                          width: 80,
                          label: '${l.personalHeight} in',
                        ),
                        const SizedBox(width: 8),
                        _Unit('in'),
                      ],
                    ),
                ],
              ),
            ),
            _Section(l.personalInjuriesSection),
            HakiCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _injuries,
                    minLines: 3,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l.personalInjuries,
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _Help(l.personalInjuriesHint),
                ],
              ),
            ),
            _Section(l.personalGoalSection),
            HakiCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (goalLabel(_initial?.primaryGoal) case final goal?)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: c.goldSurface,
                        border: Border.all(color: c.goldBorder),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        goal,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: c.goldBright,
                        ),
                      ),
                    )
                  else
                    Text(
                      l.personalGoalNone,
                      style: TextStyle(fontSize: 14, color: c.textSecondary),
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _Help('${l.personalGoalHint} '),
                      InkWell(
                        onTap: () => context.go(Routes.chat),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            l.personalGoalWrite,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: c.turquoise,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _Section(l.personalWeightSection),
            const _WeightRow(),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!, style: TextStyle(fontSize: 13, color: c.danger)),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: saving ? null : _save,
              child: Text(saving ? l.commonSaving : l.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}

/// Último peso registrado → Peso corporal (no se edita acá).
class _WeightRow extends ConsumerWidget {
  const _WeightRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final unit = ref.watch(bodyWeightUnitProvider);
    final last = seriesOf(
      ref.watch(bodyLogsProvider).value ?? const [],
      null,
    ).lastOrNull;
    return HakiCard(
      onTap: () => context.push(Routes.weight),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  last == null
                      ? '–'
                      : '${formatWeight(unit.fromKg(last.value))} ${unit.label}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (last != null) formatDayMonth(last.date),
                    l.personalWeightHint,
                  ].join(' · '),
                  style: TextStyle(fontSize: 12, color: c.textMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: c.textMuted),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
    child: SectionLabel(text),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.colors.textSecondary,
      ),
    ),
  );
}

class _Help extends StatelessWidget {
  const _Help(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 12,
      height: 1.4,
      color: context.colors.textMuted,
    ),
  );
}

class _Unit extends StatelessWidget {
  const _Unit(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 15, color: context.colors.textMuted),
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.width,
    required this.label,
    this.decimal = false,
  });

  final TextEditingController controller;
  final double width;
  final String label;
  final bool decimal;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Semantics(
      label: label,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(decimal ? r'[0-9.,]' : r'[0-9]'),
          ),
        ],
      ),
    ),
  );
}

/// Selector como el de Ajustes (dorado el elegido). [selected] null = ninguno
/// (género sin cargar); tocar el elegido no lo desmarca.
class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.values,
    required this.labelOf,
    required this.selected,
    required this.onChanged,
    this.expand = false,
  });

  final List<T> values;
  final String Function(T) labelOf;
  final T? selected;
  final ValueChanged<T?> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final button = SegmentedButton<T>(
      segments: [
        for (final v in values)
          ButtonSegment(value: v, label: Text(labelOf(v))),
      ],
      selected: {?selected},
      emptySelectionAllowed: true,
      showSelectedIcon: false,
      onSelectionChanged: (s) {
        if (s.isNotEmpty) onChanged(s.first);
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: c.gold,
        selectedForegroundColor: c.onAccent,
        foregroundColor: c.textMuted,
        side: BorderSide(color: c.border),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        visualDensity: VisualDensity.compact,
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
