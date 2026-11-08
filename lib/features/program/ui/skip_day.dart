import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/haki_colors.dart';
import '../../../l10n/l10n.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../../session/data/session_store.dart';
import '../data/assignment_dtos.dart';

// "No voy a hacer este día" (2026-11-07, canvas "Haki · Tema v2"): se marca
// deslizando el día a la izquierda en el tab Programa o con el botón de la
// Sesión sin nada registrado. Cuenta como no hecho en adherencia y racha, pero
// resuelve "qué toca hoy" (pasa al siguiente). Offline como las series.

/// Hoja de confirmación con la nota opcional para el coach. true = marcado.
Future<bool> confirmSkipDay(
  BuildContext context,
  WidgetRef ref, {
  required String assignmentId,
  required DayDto day,
}) async {
  final coach = ref.read(authMeProvider).value?.coachName?.trim();
  final note = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.colors.surface,
    builder: (_) => _SkipSheet(dayTitle: day.title, coachName: coach),
  );
  if (note == null) return false;
  return ref
      .read(sessionStoreProvider)
      .skip(assignmentId, day.id, note: note);
}

class _SkipSheet extends StatefulWidget {
  const _SkipSheet({required this.dayTitle, this.coachName});

  final String dayTitle;
  final String? coachName;

  @override
  State<_SkipSheet> createState() => _SkipSheetState();
}

class _SkipSheetState extends State<_SkipSheet> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final coach = widget.coachName;
    final first = coach == null || coach.isEmpty ? null : coach.split(' ').first;

    Widget info(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 17, color: c.textMuted),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: c.textSecondary),
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.skipSheetTitle(widget.dayTitle),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: c.text,
              ),
            ),
            const SizedBox(height: 14),
            info(Icons.info_outline, l.skipSheetCounts),
            info(Icons.arrow_forward, l.skipSheetNext),
            info(Icons.undo, l.skipSheetUndo),
            const SizedBox(height: 8),
            Text(
              first == null ? l.skipNoteLabelNoCoach : l.skipNoteLabel(first),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _note,
              minLines: 2,
              maxLines: 4,
              maxLength: 1000,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(counterText: ''),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => Navigator.pop(context, _note.text),
              child: Text(l.skipConfirm),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: c.textSecondary,
                minimumSize: const Size.fromHeight(44),
              ),
              child: Text(l.commonCancel),
            ),
          ],
        ),
      ),
    );
  }
}

const _hintKey = 'swipe_hint_shown';

/// Envuelve un día del tab Programa: deslizar a la izquierda muestra
/// "✕ No lo haré" (o "Deshacer" si ya está marcado) y lo dispara al soltar.
/// Con [hint] el día asoma solo 48 px y vuelve, **una sola vez** en la vida
/// de la app (`swipe_hint_shown`; también se marca al deslizar a mano).
class SkipSwipe extends StatefulWidget {
  const SkipSwipe({
    super.key,
    required this.id,
    required this.skipped,
    required this.onSwipe,
    required this.child,
    this.hint = false,
    this.radius = 20,
  });

  final String id;
  final bool skipped;

  /// Marcar (con la hoja) o deshacer. El día no se va de la lista.
  final Future<void> Function() onSwipe;
  final Widget child;
  final bool hint;
  final double radius;

  @override
  State<SkipSwipe> createState() => _SkipSwipeState();
}

class _SkipSwipeState extends State<SkipSwipe>
    with SingleTickerProviderStateMixin {
  /// Deslizando (o volviendo a su lugar): se ve la acción de atrás.
  bool _dragging = false;

  late final _peek = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final Animation<double> _dx = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0.0, end: -48.0).chain(CurveTween(curve: Curves.easeOut)),
      weight: 30,
    ),
    TweenSequenceItem(tween: ConstantTween(-48.0), weight: 35),
    TweenSequenceItem(
      tween: Tween(begin: -48.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
      weight: 35,
    ),
  ]).animate(_peek);

  @override
  void initState() {
    super.initState();
    if (widget.hint) unawaited(_maybeHint());
  }

  Future<void> _maybeHint() async {
    final prefs = SharedPreferencesAsync();
    try {
      if (await prefs.getBool(_hintKey) ?? false) return;
      await prefs.setBool(_hintKey, true);
    } catch (_) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) await _peek.forward();
  }

  @override
  void dispose() {
    _peek.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = dark ? c.track : c.textSecondary;
    final fg = dark ? c.text : c.surface;
    // Fondo a todo el ancho, sin bordes propios: el ClipRRect de abajo le da
    // la forma del día, así parece que la acción está debajo del card
    final background = Container(
      color: bgColor,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.skipped ? Icons.undo_rounded : Icons.close_rounded,
            color: fg,
            size: 20,
          ),
          const SizedBox(height: 2),
          Text(
            widget.skipped ? l.skipUndo : l.skipSwipeAction,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );

    // La sombra del card va afuera del recorte (si no, este día se vería
    // distinto a los demás en el tema claro)
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: c.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        // El gris va debajo del card entero (no solo en la franja que deja
        // libre: Dismissible recorta su background a esa franja y las
        // esquinas del card dejaban ver el fondo). Solo mientras se desliza.
        child: AnimatedBuilder(
          animation: _peek,
          builder: (context, child) => Stack(
            children: [
              if (_dragging || _peek.isAnimating)
                Positioned.fill(child: background),
              child!,
            ],
          ),
          child: _dismissible(),
        ),
      ),
    );
  }

  Widget _dismissible() {
    return Dismissible(
      key: ValueKey('skip-${widget.id}-${widget.skipped}'),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {DismissDirection.endToStart: .3},
      background: const SizedBox.shrink(),
      onUpdate: (d) {
        final dragging = d.progress > 0;
        if (dragging != _dragging) setState(() => _dragging = dragging);
      },
      confirmDismiss: (_) async {
        unawaited(
          SharedPreferencesAsync().setBool(_hintKey, true).catchError((_) {}),
        );
        await widget.onSwipe();
        return false;
      },
      child: AnimatedBuilder(
        animation: _peek,
        builder: (context, child) => Transform.translate(
          offset: Offset(_peek.isAnimating ? _dx.value : 0, 0),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
