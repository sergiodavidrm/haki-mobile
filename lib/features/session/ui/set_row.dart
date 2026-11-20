import 'effort_panel.dart';
import 'target_cell.dart';
import '../../../core/units/effort.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../../program/data/assignment_dtos.dart';
import '../data/session_plan.dart';
import '../../../l10n/l10n.dart';

/// Anchos de columna compartidos con el encabezado de la tabla.
/// [normal] = ejercicio suelto; [compact] = dentro de una superserie.
class SetCols {
  const SetCols._(this.set, this.weight, this.reps, this.rir, this.action);

  static const normal = SetCols._(34, 58, 48, 40, 40);
  static const compact = SetCols._(28, 54, 44, 36, 36);
  static const gap = 6.0;

  /// Entre la serie y el objetivo, un poco más (2026-11-12, Sergio: el
  /// objetivo quedaba pegado al número). Se descuenta del objetivo, que es
  /// la columna flexible.
  static const afterSet = 14.0;

  /// Sin la columna de la cámara (el coach no pide videos, 2026-11-12): su
  /// ancho y su espacio van a KG / REPS / RIR (mismo tamaño de letra, celdas
  /// más anchas para tocar). Igual en todos los ejercicios: quedan alineados.
  static SetCols of({required bool compact, required bool camera}) {
    final base = compact ? SetCols.compact : SetCols.normal;
    if (camera) return base;
    final extra = base.action + gap;
    return SetCols._(
      base.set,
      base.weight + extra * .4,
      base.reps + extra * .35,
      base.rir + extra * .25,
      0,
    );
  }

  bool get hasAction => action > 0;

  /// Padding lateral de cada fila (deja lugar al fondo de la fila "Siguiente").
  static const inset = 6.0;

  final double set;
  final double weight;
  final double reps;
  final double rir;
  final double action;
}

/// Encabezado de la tabla de series. Los textos se achican si no entran.
class SetTableHeader extends StatelessWidget {
  const SetTableHeader({
    super.key,
    required this.cols,
    required this.unit,
    this.compact = false,
    this.onToggleUnit,
    this.unitOverridden = false,
  });

  final SetCols cols;
  final WeightUnit unit;
  final bool compact;

  /// Tocar "KG" cambia la unidad solo de este ejercicio (y convierte, también
  /// la fila abierta). null = no se toca (Sesión pasada).
  final VoidCallback? onToggleUnit;

  /// La unidad del ejercicio no es la del día: va en dorado.
  final bool unitOverridden;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
      color: context.colors.textMuted,
    );
    // Los títulos de columna no se leen (la fila ya dice qué es cada valor);
    // el botón de la unidad sí
    Widget cell(String text, double width) => ExcludeSemantics(
      child: SizedBox(
        width: width,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(text, style: style, maxLines: 1),
        ),
      ),
    );

    final toggle = onToggleUnit;
    final unitCell = toggle == null
        ? cell(unit.api, cols.weight)
        : _UnitHeaderButton(
            width: cols.weight,
            unit: unit,
            overridden: unitOverridden,
            style: style,
            onTap: toggle,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SetCols.inset),
      child: SizedBox(
        height: 24,
        child: Row(
          children: [
            cell(compact ? '#' : context.l10n.setHeader, cols.set),
            const SizedBox(width: SetCols.afterSet),
            Expanded(
              // Se achica si no entra, como los demás títulos (2026-11-17:
              // "OBJETIVO" se cortaba en "OBJETIV" con letra grande)
              child: ExcludeSemantics(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    compact
                        ? context.l10n.targetHeaderShort
                        : context.l10n.targetHeader,
                    style: style,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: SetCols.gap),
            unitCell,
            const SizedBox(width: SetCols.gap),
            cell(context.l10n.repsHeader, cols.reps),
            const SizedBox(width: SetCols.gap),
            cell(effortScaleOf(context).label, cols.rir),
            if (cols.hasAction) ...[
              const SizedBox(width: SetCols.gap),
              SizedBox(width: cols.action),
            ],
          ],
        ),
      ),
    );
  }
}

/// "KG ⇄" del encabezado: cambia la unidad de este ejercicio (convierte todo
/// el ejercicio, también la fila abierta). Dorado si no es la del día. No
/// saca el foco de la fila abierta (si no, se guardaría y cerraría).
class _UnitHeaderButton extends StatelessWidget {
  const _UnitHeaderButton({
    required this.width,
    required this.unit,
    required this.overridden,
    required this.style,
    required this.onTap,
  });

  final double width;
  final WeightUnit unit;
  final bool overridden;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = overridden ? context.colors.goldBright : style.color;
    return TextFieldTapRegion(
      child: Semantics(
        button: true,
        label: context.l10n.exerciseUnitToggle(unit.label, unit.other.label),
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: width,
            height: 24,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(unit.api, style: style.copyWith(color: color)),
                  const SizedBox(width: 2),
                  Icon(Icons.swap_horiz, size: 11, color: color),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Una fila de la tabla de series. Guardada → valores como texto; pendiente →
/// "–"; solo la que el atleta tocó → inputs (una sola abierta en toda la
/// Sesión). Se guarda sola al salir de la fila. Todas llevan cámara.
class SetRow extends StatefulWidget {
  const SetRow({
    super.key,
    required this.setNumber,
    required this.target,
    required this.unit,
    required this.saved,
    required this.cols,
    required this.onSave,
    required this.onVideo,
  });

  final int setNumber;
  final TargetSetDto? target;

  /// Unidad efectiva del ejercicio (switch del día u override).
  final WeightUnit unit;
  final SavedSet? saved;
  final SetCols cols;
  final void Function(double? weight, WeightUnit unit, int? reps, double? rir)
  onSave;

  /// [requested] = el coach pidió video de esta serie.
  final void Function(bool requested) onVideo;

  @override
  State<SetRow> createState() => _SetRowState();
}

/// Campo que recibe el foco al abrir la fila: el que el atleta tocó.
enum _Field { weight, reps, rir }

class _SetRowState extends State<SetRow> {
  late final _weight = TextEditingController(text: _savedWeight(widget.saved));
  late final _reps = TextEditingController(
    text: widget.saved?.reps?.toString() ?? '',
  );
  /// Esfuerzo en RIR. Con RPE se carga con el panel de la escalera; con RIR,
  /// con el teclado como antes (acepta medio punto: 1,5).
  late double? _rir = widget.saved?.rir;
  late final _rirText = TextEditingController(text: _plainRir(widget.saved?.rir));
  final _weightFocus = FocusNode();
  final _repsFocus = FocusNode();
  final _rirFocus = FocusNode();

  static String _plainRir(double? rir) =>
      rir == null ? '' : formatEffort(rir, EffortScale.rir);

  static double? _parseRir(String s) {
    final v = double.tryParse(s.trim().replaceAll(',', '.').replaceAll('+', ''));
    return v == null ? null : toRir(v, EffortScale.rir);
  }

  /// El panel de la escalera solo va con RPE (decisión de Sergio 2026-11-14)
  bool get _usesPanel => effortScaleOf(context) == EffortScale.rpe;

  /// El panel de esfuerzo está abierto: perder el foco no cierra la fila.
  bool _pickingEffort = false;

  /// El atleta tocó la fila para cargarla o corregirla.
  bool _editing = false;

  /// Fila abierta en la Sesión: abrir otra cierra (y guarda) la anterior.
  /// Antes la serie que seguía quedaba abierta sola y había varias con
  /// inputs a la vez.
  static final _openRow = ValueNotifier<_SetRowState?>(null);

  @override
  void initState() {
    super.initState();
    _openRow.addListener(_onOtherOpened);
  }

  void _onOtherOpened() {
    if (_editing && _openRow.value != this) _commit();
  }

  static String _fmt(double? v) => v == null ? '' : formatWeight(v);
  static double? _parseWeight(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.'));
  static int? _parseInt(String s) => int.tryParse(s.trim());

  /// Todo se muestra y se carga en la unidad efectiva del ejercicio: una
  /// serie guardada en otra unidad se convierte (140 kg → 308.6 lb).
  WeightUnit get _rowUnit => widget.unit;

  String _savedWeight(SavedSet? s) => s?.weight == null
      ? ''
      : formatWeight(widget.unit.fromKg(s!.unit.toKg(s.weight!)));

  bool get _editable => _editing;

  bool get _dirty {
    final s = widget.saved;
    if (s == null) {
      return _weight.text.trim().isNotEmpty ||
          _reps.text.trim().isNotEmpty ||
          _rir != null;
    }
    return _fmt(_parseWeight(_weight.text)) != _savedWeight(s) ||
        _parseInt(_reps.text) != s.reps ||
        _rir != s.rir;
  }

  @override
  void didUpdateWidget(SetRow old) {
    super.didUpdateWidget(old);
    // Llegó un valor guardado nuevo (sync / otro teléfono) o cambió la unidad,
    // y no se está editando
    final s = widget.saved;
    // Cambió la unidad (del día o del ejercicio) con la fila abierta: el peso
    // escrito también se convierte (si no, "100" pensado en kg se guardaba
    // como 100 lb)
    if (_editing && old.unit != widget.unit) {
      final w = _parseWeight(_weight.text);
      if (w != null) {
        _weight.text = formatWeight(widget.unit.fromKg(old.unit.toKg(w)));
      }
    }
    if (!_editing && s != null) {
      _weight.text = _savedWeight(s);
      _reps.text = s.reps?.toString() ?? '';
      _rir = s.rir;
      _rirText.text = _plainRir(s.rir);
    }
  }

  @override
  void dispose() {
    _openRow.removeListener(_onOtherOpened);
    if (_openRow.value == this) _openRow.value = null;
    _weight.dispose();
    _reps.dispose();
    _rirText.dispose();
    _rirFocus.dispose();
    _weightFocus.dispose();
    _repsFocus.dispose();
    super.dispose();
  }

  /// Abre la fila con el foco en la columna que tocó (peso si tocó otra parte
  /// de la fila, como el objetivo).
  void _startEditing([_Field field = _Field.weight]) {
    if (field == _Field.rir && _usesPanel) {
      _pickEffort();
      return;
    }
    setState(() => _editing = true);
    _openRow.value = this;
    final focus = switch (field) {
      _Field.weight => _weightFocus,
      _Field.reps => _repsFocus,
      _Field.rir => _rirFocus,
    };
    WidgetsBinding.instance.addPostFrameCallback((_) => focus.requestFocus());
  }

  /// Se puede copiar el objetivo: serie sin cargar, cerrada y con peso o reps
  /// pedidos.
  bool get _canCopyTarget {
    final t = widget.target;
    return !_editing &&
        widget.saved == null &&
        t != null &&
        (t.weightKg != null || t.reps != null);
  }

  /// Toque en el objetivo de una serie vacía (2026-11-19, opción B): pasa el
  /// peso y las reps pedidos a la fila y abre el esfuerzo (escalera con RPE,
  /// teclado en la celda con RIR). El esfuerzo no se copia: lo tiene que
  /// poner el atleta (las pistas de Rendimiento comparan el real con el
  /// pedido). Se guarda al salir de la fila, como siempre.
  void _copyTarget() {
    final t = widget.target!;
    HapticFeedback.selectionClick();
    _weight.text = t.weightKg == null
        ? ''
        : formatWeight(widget.unit.fromKg(t.weightKg!));
    _reps.text = t.reps?.toString() ?? '';
    setState(() => _editing = true);
    _openRow.value = this;
    if (_usesPanel) {
      _pickEffort();
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _rirFocus.requestFocus(),
      );
    }
  }

  void _onFocusChange(bool hasFocus) {
    if (!hasFocus && !_pickingEffort) _commit();
  }

  /// Panel de esfuerzo (escalera curva) en lugar del teclado. "Listo" guarda
  /// la serie y cierra la fila; cerrarlo sin elegir deja el valor como estaba.
  Future<void> _pickEffort() async {
    _pickingEffort = true;
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await showEffortPanel(
      context,
      scale: effortScaleOf(context),
      initialRir: _rir ?? widget.target?.rir,
    );
    _pickingEffort = false;
    if (!mounted) return;
    if (picked != null) _rir = picked.rir;
    _commit();
  }

  /// Guarda si hubo cambios y cierra la fila.
  void _commit() {
    // Con RIR el valor sale del campo de texto (con RPE lo pone el panel)
    if (!_usesPanel) _rir = _parseRir(_rirText.text);
    // Cualquier cambio en peso, reps o RIR se guarda tal cual: lo que no
    // escribió queda vacío (antes exigía reps y un atleta que solo cargaba el
    // peso no guardaba nada).
    if (_dirty) {
      widget.onSave(
        _parseWeight(_weight.text),
        _rowUnit,
        _parseInt(_reps.text),
        _rir,
      );
    }
    if (_editing) setState(() => _editing = false);
    if (_openRow.value == this) _openRow.value = null;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = widget.target;
    final cols = widget.cols;
    final scale = effortScaleOf(context);
    // Objetivo: TargetCell (peso arriba, "12 reps · RIR 2" abajo). Los
    // inputs van sin placeholder: el hint parecía un valor cargado.

    final Widget weight, reps, rir;
    if (_editable) {
      weight = _Input(
        controller: _weight,
        focusNode: _weightFocus,
        width: cols.weight,
        decimal: true,
        label: context.l10n.setWeightLabel(widget.setNumber, _rowUnit.label),
      );
      reps = _Input(
        controller: _reps,
        focusNode: _repsFocus,
        width: cols.reps,
        label: context.l10n.setRepsLabel(widget.setNumber),
        action: _usesPanel ? TextInputAction.done : TextInputAction.next,
      );
      rir = _usesPanel
          ? _EffortCell(
              width: cols.rir,
              text: _rir == null ? null : formatEffort(_rir, scale),
              label: context.l10n.setEffortLabel(scale.label, widget.setNumber),
              onTap: _pickEffort,
            )
          : _Input(
              controller: _rirText,
              focusNode: _rirFocus,
              width: cols.rir,
              decimal: true,
              plus: true,
              label: context.l10n.setRirLabel(widget.setNumber),
              action: TextInputAction.done,
            );
    } else {
      final s = widget.saved;
      weight = _Value(
        width: cols.weight,
        text: s?.weight == null ? null : _savedWeight(s),
        empty: s == null,
        onTap: () => _startEditing(_Field.weight),
      );
      reps = _Value(
        width: cols.reps,
        text: s?.reps?.toString(),
        empty: s == null,
        onTap: () => _startEditing(_Field.reps),
      );
      rir = _Value(
        width: cols.rir,
        text: s?.rir == null ? null : formatEffort(s!.rir, scale),
        empty: s == null,
        onTap: () => _startEditing(_Field.rir),
      );
    }

    final row = Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: SetCols.inset,
        vertical: 4,
      ),
      child: Row(
        children: [
          SizedBox(
            width: cols.set,
            child: Text(
              '${widget.setNumber}',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, color: c.textMuted),
            ),
          ),
          const SizedBox(width: SetCols.afterSet),
          Expanded(
            child: _canCopyTarget
                ? Semantics(
                    button: true,
                    label: context.l10n.setCopyTarget(widget.setNumber),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _copyTarget,
                      child: TargetCell(target: t, unit: widget.unit),
                    ),
                  )
                : TargetCell(target: t, unit: widget.unit),
          ),
          const SizedBox(width: SetCols.gap),
          weight,
          const SizedBox(width: SetCols.gap),
          reps,
          const SizedBox(width: SetCols.gap),
          rir,
          if (cols.hasAction) ...[
            const SizedBox(width: SetCols.gap),
            SizedBox(
              width: cols.action,
              child: Center(
                child: SetCameraButton(
                  setNumber: widget.setNumber,
                  requested: t?.requestVideo ?? false,
                  sent: widget.saved?.hasVideo ?? false,
                  uploading: widget.saved?.videoUploading ?? false,
                  onTap: () => widget.onVideo(t?.requestVideo ?? false),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _onFocusChange,
      child: _editable
          ? row
          : Semantics(
              button: true,
              label: widget.saved == null
                  ? context.l10n.setLog(widget.setNumber)
                  : context.l10n.setEdit(widget.setNumber),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _startEditing,
                child: row,
              ),
            ),
    );
  }
}

/// Valor ya guardado (texto) o "–" si la serie no se cargó. Tocarlo abre la
/// fila con el foco en este campo (toda la altura de la fila es tocable).
class _Value extends StatelessWidget {
  const _Value({
    required this.width,
    required this.text,
    required this.empty,
    required this.onTap,
  });

  final double width;
  final String? text;
  final bool empty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: 40,
        child: Center(
          child: Text(
            empty ? '–' : (text ?? '–'),
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              fontSize: 16,
              fontWeight: empty ? FontWeight.w400 : FontWeight.w600,
              color: empty ? c.textMuted : c.text,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cámara de cada serie. Pedido por el coach = dorada con punto; no pedido =
/// tachada (igual se puede subir, con confirmación); en la cola = nube
/// turquesa; enviado = turquesa con check.
/// Cámara de una serie (Sesión y Sesión pasada): dorada = pedida por el coach,
/// tachada = no pedida, nube = en la cola, turquesa = subido. Si el coach no
/// pide videos (`videosEnabledProvider`) solo se muestra en una serie que ya
/// tiene video (subido o en la cola).
class SetCameraButton extends ConsumerWidget {
  const SetCameraButton({
    super.key,
    required this.setNumber,
    required this.requested,
    required this.sent,
    required this.uploading,
    required this.onTap,
  });

  final int setNumber;
  final bool requested;
  final bool sent;
  final bool uploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(videosEnabledProvider) && !sent && !uploading) {
      return const SizedBox.shrink();
    }
    final c = context.colors;
    final (bg, side, fg, icon) = uploading
        ? (
            c.turquoiseSurface,
            BorderSide(color: c.turquoise, width: 1.5),
            c.turquoise,
            Icons.cloud_upload_outlined,
          )
        : sent
        ? (
            c.turquoiseSurface,
            BorderSide.none,
            c.turquoise,
            Icons.videocam_outlined,
          )
        : requested
        ? (
            c.goldSurface,
            BorderSide(color: c.gold, width: 1.5),
            c.goldBright,
            Icons.videocam_outlined,
          )
        : (
            Colors.transparent,
            BorderSide(color: c.border, width: 1.5),
            c.textMuted,
            Icons.videocam_off_outlined,
          );

    return Semantics(
      button: true,
      label: uploading
          ? context.l10n.setVideoUploading(setNumber)
          : sent
          ? context.l10n.setVideoSent(setNumber)
          : requested
          ? context.l10n.setVideoRequested(setNumber)
          : context.l10n.setVideoNotRequested(setNumber),
      excludeSemantics: true,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Material(
              color: bg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: side,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onTap,
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(icon, size: 19, color: fg),
                ),
              ),
            ),
            if (!uploading && (sent || requested))
              Positioned(
                top: sent ? 0 : 1,
                right: sent ? 0 : 1,
                child: IgnorePointer(
                  child: Container(
                    width: sent ? 15 : 9,
                    height: sent ? 15 : 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sent ? c.turquoise : c.goldBright,
                      border: Border.all(color: c.surface, width: 2),
                    ),
                    child: sent
                        ? Icon(Icons.check, size: 8, color: c.onAccent)
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Celda del esfuerzo con la fila abierta: se ve como un campo, pero al
/// tocarla sube el panel de la escalera (no el teclado).
class _EffortCell extends StatelessWidget {
  const _EffortCell({
    required this.width,
    required this.text,
    required this.label,
    required this.onTap,
  });

  final double width;
  final String? text;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: label,
      value: text,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: width,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.gold, width: 1.5),
          ),
          child: Text(
            text ?? '',
            maxLines: 1,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: c.text,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.width,
    required this.label,
    this.focusNode,
    this.decimal = false,
    this.plus = false,
    this.action = TextInputAction.next,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final double width;
  final String label;
  final bool decimal;

  /// Acepta "+" (RIR "5+")
  final bool plus;

  /// next = pasa al siguiente campo; done en el último (cierra el teclado y
  /// la fila se guarda sola).
  final TextInputAction action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: c.gold, width: 1.5),
    );
    return Semantics(
      label: label,
      child: SizedBox(
        width: width,
        height: 38,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: action,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(plus ? r'[0-9.,+]' : decimal ? r'[0-9.,]' : r'[0-9]'),
            ),
          ],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: c.text,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 2,
              vertical: 9,
            ),
            filled: true,
            fillColor: c.background,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: c.goldBright, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
