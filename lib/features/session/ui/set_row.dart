import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../program/data/assignment_dtos.dart';
import '../data/session_plan.dart';

/// Anchos de columna compartidos con el encabezado de la tabla.
/// [normal] = ejercicio suelto; [compact] = dentro de una superserie.
class SetCols {
  const SetCols._(this.set, this.weight, this.reps, this.rir, this.action);

  static const normal = SetCols._(34, 58, 48, 40, 40);
  static const compact = SetCols._(28, 54, 44, 36, 36);
  static const gap = 6.0;

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
  });

  final SetCols cols;
  final WeightUnit unit;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
      color: context.colors.textMuted,
    );
    Widget cell(String text, double width) => SizedBox(
      width: width,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, style: style, maxLines: 1),
      ),
    );

    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SetCols.inset),
        child: SizedBox(
          height: 24,
          child: Row(
            children: [
              cell(compact ? '#' : 'SERIE', cols.set),
              const SizedBox(width: SetCols.gap),
              Expanded(
                child: Text(
                  compact ? 'OBJ.' : 'OBJETIVO',
                  style: style,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
              const SizedBox(width: SetCols.gap),
              cell(unit.api, cols.weight),
              const SizedBox(width: SetCols.gap),
              cell('REPS', cols.reps),
              const SizedBox(width: SetCols.gap),
              cell('RIR', cols.rir),
              const SizedBox(width: SetCols.gap),
              SizedBox(width: cols.action),
            ],
          ),
        ),
      ),
    );
  }
}

/// Una fila de la tabla de series. Guardada → valores como texto; pendiente →
/// "–"; la que sigue ([isNext]) o la que el atleta tocó → inputs. Se guarda
/// sola al salir de la fila (con reps cargadas). Todas llevan cámara.
class SetRow extends StatefulWidget {
  const SetRow({
    super.key,
    required this.setNumber,
    required this.target,
    required this.unit,
    required this.saved,
    required this.isNext,
    required this.cols,
    required this.onSave,
    required this.onVideo,
  });

  final int setNumber;
  final TargetSetDto? target;

  /// Unidad efectiva del ejercicio (switch del día u override).
  final WeightUnit unit;
  final SavedSet? saved;

  /// Primera serie pendiente de la sesión: queda con los inputs abiertos.
  final bool isNext;
  final SetCols cols;
  final void Function(double? weight, WeightUnit unit, int? reps, int? rir)
  onSave;

  /// [requested] = el coach pidió video de esta serie.
  final void Function(bool requested) onVideo;

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late final _weight = TextEditingController(text: _savedWeight(widget.saved));
  late final _reps = TextEditingController(
    text: widget.saved?.reps?.toString() ?? '',
  );
  late final _rir = TextEditingController(
    text: widget.saved?.rir?.toString() ?? '',
  );
  final _weightFocus = FocusNode();

  /// El atleta tocó la fila para cargarla o corregirla.
  bool _editing = false;

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

  bool get _editable => _editing || (widget.isNext && widget.saved == null);

  bool get _dirty {
    final s = widget.saved;
    if (s == null) {
      return _weight.text.trim().isNotEmpty || _reps.text.trim().isNotEmpty;
    }
    return _fmt(_parseWeight(_weight.text)) != _savedWeight(s) ||
        _parseInt(_reps.text) != s.reps ||
        _parseInt(_rir.text) != s.rir;
  }

  @override
  void didUpdateWidget(SetRow old) {
    super.didUpdateWidget(old);
    // Llegó un valor guardado nuevo (sync / otro teléfono) o cambió la unidad,
    // y no se está editando
    final s = widget.saved;
    if (!_editing && s != null) {
      _weight.text = _savedWeight(s);
      _reps.text = s.reps?.toString() ?? '';
      _rir.text = s.rir?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    _rir.dispose();
    _weightFocus.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _weightFocus.requestFocus(),
    );
  }

  void _onFocusChange(bool hasFocus) {
    if (hasFocus) return;
    if (_dirty && _reps.text.trim().isNotEmpty) {
      widget.onSave(
        _parseWeight(_weight.text),
        _rowUnit,
        _parseInt(_reps.text),
        _parseInt(_rir.text),
      );
    }
    if (_editing) setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = widget.target;
    final cols = widget.cols;
    final targetWeight = t?.weightKg == null
        ? null
        : formatWeight(widget.unit.fromKg(t!.weightKg!));
    final objective = [
      ?targetWeight,
      if (t?.reps != null) '${t!.reps}',
    ].join(' × ');
    final objectiveSub = t?.rir != null ? 'RIR ${t!.rir}' : null;

    final Widget weight, reps, rir;
    if (_editable) {
      weight = _Input(
        controller: _weight,
        focusNode: _weightFocus,
        width: cols.weight,
        hint: targetWeight,
        decimal: true,
        label: 'Peso de la serie ${widget.setNumber} en ${_rowUnit.label}',
      );
      reps = _Input(
        controller: _reps,
        width: cols.reps,
        hint: t?.reps?.toString(),
        label: 'Repeticiones de la serie ${widget.setNumber}',
      );
      rir = _Input(
        controller: _rir,
        width: cols.rir,
        hint: t?.rir?.toString(),
        label: 'RIR de la serie ${widget.setNumber}',
        action: TextInputAction.done,
      );
    } else {
      final s = widget.saved;
      weight = _Value(
        width: cols.weight,
        text: s?.weight == null ? null : _savedWeight(s),
        empty: s == null,
      );
      reps = _Value(
        width: cols.reps,
        text: s?.reps?.toString(),
        empty: s == null,
      );
      rir = _Value(width: cols.rir, text: s?.rir?.toString(), empty: s == null);
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
          const SizedBox(width: SetCols.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  objective.isEmpty ? '—' : objective,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: c.turquoise,
                  ),
                ),
                if (objectiveSub != null)
                  Text(
                    objectiveSub,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.25,
                      color: c.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: SetCols.gap),
          weight,
          const SizedBox(width: SetCols.gap),
          reps,
          const SizedBox(width: SetCols.gap),
          rir,
          const SizedBox(width: SetCols.gap),
          SizedBox(
            width: cols.action,
            child: Center(
              child: _CameraButton(
                setNumber: widget.setNumber,
                requested: t?.requestVideo ?? false,
                sent: widget.saved?.hasVideo ?? false,
                uploading: widget.saved?.videoUploading ?? false,
                onTap: () => widget.onVideo(t?.requestVideo ?? false),
              ),
            ),
          ),
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
                  ? 'Cargar serie ${widget.setNumber}'
                  : 'Editar serie ${widget.setNumber}',
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _startEditing,
                child: row,
              ),
            ),
    );
  }
}

/// Valor ya guardado (texto) o "–" si la serie no se cargó.
class _Value extends StatelessWidget {
  const _Value({required this.width, required this.text, required this.empty});

  final double width;
  final String? text;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: width,
      child: Text(
        empty ? '–' : (text ?? '–'),
        textAlign: TextAlign.center,
        maxLines: 1,
        style: TextStyle(
          fontSize: 16,
          fontWeight: empty ? FontWeight.w400 : FontWeight.w600,
          color: empty ? c.textMuted.withValues(alpha: .7) : c.text,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Cámara de cada serie. Pedido por el coach = dorada con punto; no pedido =
/// tachada (igual se puede subir, con confirmación); en la cola = nube
/// turquesa; enviado = turquesa con check.
class _CameraButton extends StatelessWidget {
  const _CameraButton({
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
  Widget build(BuildContext context) {
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
          ? 'Video de la serie $setNumber subiéndose'
          : sent
          ? 'Video de la serie $setNumber enviado, tocar para reemplazarlo'
          : requested
          ? 'Subir video de la serie $setNumber, pedido por tu coach'
          : 'Subir video de la serie $setNumber (tu coach no lo pidió)',
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
                        ? Icon(Icons.check, size: 8, color: c.background)
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

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.width,
    required this.label,
    this.focusNode,
    this.hint,
    this.decimal = false,
    this.action = TextInputAction.next,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final double width;
  final String label;
  final String? hint;
  final bool decimal;

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
              RegExp(decimal ? r'[0-9.,]' : r'[0-9]'),
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
            hintText: hint,
            hintStyle: TextStyle(
              color: c.textMuted.withValues(alpha: .7),
              fontWeight: FontWeight.w500,
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
