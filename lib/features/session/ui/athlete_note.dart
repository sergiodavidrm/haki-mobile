import 'package:flutter/material.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../l10n/l10n.dart';

/// Nota del atleta para el coach sobre un ejercicio. Desde 2026-11-12 (canvas
/// https://claude.ai/artifact/3PrQxDXazxPxDCAtJq1Kjp, opción B): sin nota =
/// pastilla chica "✎ Nota" a la derecha de [leading] (la línea de Sem.
/// pasada) en vez del botón a todo el ancho; con nota = una línea "Tu nota: …"
/// debajo, que se toca para editar. Al tocar, campo con Cancelar / Guardar
/// nota. La ve el coach en el web. Sesión y Sesión pasada.
class AthleteNote extends StatefulWidget {
  const AthleteNote({
    super.key,
    required this.note,
    required this.onSave,
    this.leading,
  });

  /// Lo que va a la izquierda de la pastilla (la línea de Sem. pasada)
  final Widget? leading;

  /// Nota actual (null = sin nota).
  final String? note;

  /// Vacía = borrarla.
  final ValueChanged<String?> onSave;

  @override
  State<AthleteNote> createState() => _AthleteNoteState();
}

class _AthleteNoteState extends State<AthleteNote> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _editing = false;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _start() {
    _controller.text = widget.note ?? '';
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _save() {
    final text = _controller.text.trim();
    setState(() => _editing = false);
    if (text != (widget.note ?? '')) widget.onSave(text.isEmpty ? null : text);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;

    if (_editing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            const SizedBox(height: 10),
          ],
          Text(
            l.noteLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            focusNode: _focus,
            minLines: 3,
            maxLines: 5,
            maxLength: 1000,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(fontSize: 14, height: 1.45, color: c.text),
            decoration: InputDecoration(
              hintText: l.noteHint,
              counterText: '',
              filled: true,
              fillColor: c.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: c.gold, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: c.gold, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => setState(() => _editing = false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  foregroundColor: c.textSecondary,
                  side: BorderSide(color: c.border),
                ),
                child: Text(l.commonCancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                child: Text(l.noteSave),
              ),
            ],
          ),
        ],
      );
    }

    final note = widget.note;
    final leading = widget.leading;
    // Sin nota: pastilla chica a la derecha de la línea de Sem. pasada
    final chip = Semantics(
      button: true,
      label: l.noteAdd,
      excludeSemantics: true,
      child: Material(
        color: c.surfaceHigh,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: _start,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined, size: 13, color: c.textSecondary),
                const SizedBox(width: 5),
                Text(
                  l.noteShort,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (note == null) {
      return Row(
        children: [
          Expanded(child: leading ?? const SizedBox.shrink()),
          const SizedBox(width: 8),
          chip,
        ],
      );
    }

    // Con nota: una línea debajo, tocarla la edita
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (leading != null) ...[leading, const SizedBox(height: 6)],
        Semantics(
          button: true,
          hint: l.noteEdit,
          child: InkWell(
            onTap: _start,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 13,
                          color: c.textMuted,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: '${l.sessionYourNote}: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: c.textSecondary,
                      ),
                    ),
                    TextSpan(text: '"$note"'),
                  ],
                ),
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                  color: c.textMuted,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
