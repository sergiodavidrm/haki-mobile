import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/effort_colors.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/units/effort.dart';
import '../../../l10n/l10n.dart';

/// Panel de esfuerzo de la Sesión (canvas "Haki · Control de esfuerzo", opción
/// C · escalera curva): reemplaza al teclado para el RPE / RIR. Barras que
/// crecen en curva hacia el fallo; se tocan o se arrastra el dedo; − / + de a
/// medio punto; el ícono de teclado deja escribirlo; "?" explica la escala.
/// Devuelve `(rir: …)` (null en rir = borrado) o null si se cerró sin elegir.
Future<({double? rir})?> showEffortPanel(
  BuildContext context, {
  required EffortScale scale,
  double? initialRir,
}) => showModalBottomSheet<({double? rir})>(
  context: context,
  isScrollControlled: true,
  backgroundColor: context.colors.surface,
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
  builder: (_) => _EffortPanel(scale: scale, initialRir: initialRir ?? 2),
);

class _EffortPanel extends StatefulWidget {
  const _EffortPanel({required this.scale, required this.initialRir});

  final EffortScale scale;
  final double initialRir;

  @override
  State<_EffortPanel> createState() => _EffortPanelState();
}

class _EffortPanelState extends State<_EffortPanel> {
  late double _rir = widget.initialRir.clamp(0, 4).toDouble();
  bool _typing = false;
  final _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  void _set(double rir) {
    final v = ((rir.clamp(0, 4) * 2).roundToDouble()) / 2;
    if (v != _rir) {
      HapticFeedback.selectionClick();
      setState(() => _rir = v);
    }
  }

  // Posición horizontal del dedo → barra (izquierda = fácil)
  void _fromDx(double dx, double width) {
    final i = (dx / width * effortSteps.length).floor().clamp(0, effortSteps.length - 1);
    _set(effortSteps[i]);
  }

  void _done() {
    if (_typing) {
      final raw = _typed.text.trim().replaceAll(',', '.');
      if (raw.isEmpty) {
        Navigator.pop(context, (rir: null));
        return;
      }
      final v = double.tryParse(raw);
      if (v == null) return;
      Navigator.pop(context, (rir: toRir(v, widget.scale)));
      return;
    }
    Navigator.pop(context, (rir: _rir));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final color = effortColor(_rir);
    final scale = widget.scale;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatEffort(_rir, scale),
                  style: TextStyle(fontSize: 52, height: .95, fontWeight: FontWeight.w900, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(effortTitle(l, _rir), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.text)),
                        Text(effortHint(l, _rir), style: TextStyle(fontSize: 13, color: c.textMuted)),
                      ],
                    ),
                  ),
                ),
                // "? RPE": qué es la escala
                Semantics(
                  button: true,
                  label: scale == EffortScale.rpe ? l.effortWhatIsRpe : l.effortWhatIsRir,
                  excludeSemantics: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showHelp(context, scale),
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.fromLTRB(6, 0, 10, 0),
                      decoration: BoxDecoration(
                        color: c.surfaceHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: c.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: c.border, shape: BoxShape.circle),
                            child: Text('?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: c.text)),
                          ),
                          const SizedBox(width: 6),
                          Text(scale.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1, color: c.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_typing)
              SizedBox(
                height: 150,
                child: Center(
                  child: SizedBox(
                    width: 160,
                    child: TextField(
                      controller: _typed,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                      onSubmitted: (_) => _done(),
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: c.text),
                      decoration: InputDecoration(
                        hintText: scale == EffortScale.rpe ? '6 – 10' : '0 – 5',
                        helperText: l.effortTypeHelp,
                      ),
                    ),
                  ),
                ),
              )
            else
              // Escalera: tocar o arrastrar
              LayoutBuilder(
                builder: (context, box) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) => _fromDx(d.localPosition.dx, box.maxWidth),
                  onHorizontalDragUpdate: (d) => _fromDx(d.localPosition.dx, box.maxWidth),
                  child: Semantics(
                    slider: true,
                    value: formatEffort(_rir, scale),
                    increasedValue: formatEffort((_rir - .5).clamp(0, 4), scale),
                    decreasedValue: formatEffort((_rir + .5).clamp(0, 4), scale),
                    onIncrease: () => _set(_rir - .5),
                    onDecrease: () => _set(_rir + .5),
                    child: SizedBox(
                      height: 150,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final step in effortSteps) _Bar(step: step, selected: _rir, scale: scale),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                _SquareButton(
                  tooltip: _typing ? l.effortUseBars : l.effortType,
                  icon: _typing ? Icons.bar_chart_rounded : Icons.keyboard_outlined,
                  onTap: () => setState(() {
                    _typing = !_typing;
                    _typed.text = _typing ? '' : _typed.text;
                  }),
                ),
                if (!_typing) ...[
                  const SizedBox(width: 8),
                  _SquareButton(tooltip: l.effortLess, icon: Icons.remove, onTap: () => _set(_rir + .5)),
                  const SizedBox(width: 8),
                  _SquareButton(tooltip: l.effortMore, icon: Icons.add, onTap: () => _set(_rir - .5)),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(onPressed: _done, child: Text(l.effortDone)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.step, required this.selected, required this.scale});

  final double step;
  final double selected;
  final EffortScale scale;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final on = step >= selected; // las de la izquierda hasta la elegida
    final t = (4 - step) / 4;
    final color = effortColor(step);
    return Container(
      width: 30,
      height: 40 + 104 * t * t, // curva: crece cada vez más rápido hacia el fallo
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: on ? color : c.surfaceHigh,
        borderRadius: BorderRadius.circular(15),
        boxShadow: step == selected
            ? [BoxShadow(color: c.surface, spreadRadius: 3), BoxShadow(color: color, spreadRadius: 5)]
            : null,
      ),
      child: Text(
        formatEffort(step, scale),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: on ? Colors.black : c.textMuted),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.tooltip, required this.icon, required this.onTap});

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: c.border)),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(width: 52, height: 48, child: Icon(icon, color: c.text)),
        ),
      ),
    );
  }
}

/// "¿Qué es el RPE?" / "¿Qué es el RIR?" (botón ?). Se cierra con Entendido,
/// tocando afuera o deslizando.
void _showHelp(BuildContext context, EffortScale scale) {
  final l = context.l10n;
  final rpe = scale == EffortScale.rpe;
  final examples = [
    (0.0, l.effortFailure, l.effortHintNone),
    (2.0, l.effortHard, l.effortHintN(2)),
    (4.0, l.effortModerate, l.effortHintFourPlus),
  ];
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (context) {
      final c = context.colors;
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(rpe ? l.effortWhatIsRpe : l.effortWhatIsRir,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.text)),
              const SizedBox(height: 8),
              Text(rpe ? l.effortRpeExplain : l.effortRirExplain,
                  style: TextStyle(fontSize: 14, height: 1.5, color: c.textSecondary)),
              const SizedBox(height: 12),
              for (final (rir, title, hint) in examples)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.surfaceHigh,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: effortColor(rir), borderRadius: BorderRadius.circular(12)),
                        child: Text(formatEffort(rir, scale),
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.text)),
                            Text(hint, style: TextStyle(fontSize: 13, color: c.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Text(l.effortHalfTip, style: TextStyle(fontSize: 12, height: 1.45, color: c.textMuted)),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: FilledButton(onPressed: () => Navigator.pop(context), child: Text(l.effortGotIt)),
              ),
            ],
          ),
        ),
      );
    },
  );
}
