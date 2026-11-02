import 'package:flutter/material.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../l10n/l10n.dart';

/// Nota del atleta para el coach sobre un ejercicio (mockup "Sesión"): sin
/// nota = botón punteado "Agregar nota para tu coach"; al tocarlo, campo con
/// Cancelar / Guardar nota; guardada = "Tu nota: …" con Editar. La ve el coach
/// en el web (builder y detalle del día del Resumen). Sesión y Sesión pasada.
class AthleteNote extends StatefulWidget {
  const AthleteNote({super.key, required this.note, required this.onSave});

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
    if (note == null) {
      return OutlinedButton.icon(
        onPressed: _start,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          foregroundColor: c.textSecondary,
          side: BorderSide(color: c.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.edit_outlined, size: 16),
        label: Text(l.noteAdd),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 16,
              color: c.turquoise,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${l.sessionYourNote}: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.turquoise,
                    ),
                  ),
                  TextSpan(text: note),
                ],
              ),
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: c.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: _start,
            style: TextButton.styleFrom(
              foregroundColor: c.goldBright,
              minimumSize: const Size(0, 32),
              visualDensity: VisualDensity.compact,
            ),
            child: Text(l.noteEdit),
          ),
        ],
      ),
    );
  }
}
