import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/format/dates.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/theme/share_story_colors.dart';
import '../../../core/widgets/back_header.dart';
import '../../../l10n/l10n.dart';
import '../data/share_format.dart';
import '../data/share_stickers.dart';
import '../providers/share_providers.dart';
import 'stickers.dart';

// Compartir (2026-11-12): Día / Semana / Mes → sticker → fondo → Compartir
// (menú del teléfono) o Guardar (galería). Sin foto: el atleta lo pega en
// Instagram sobre la suya. Canvas https://claude.ai/artifact/XgxAnMeTfAh9gdVjzmFy2t
class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({
    super.key,
    this.assignmentId = '',
    this.dayId = '',
    this.period,
  });

  /// Vacíos = se entró sin un entreno (Perfil → Tu progreso)
  final String assignmentId;
  final String dayId;

  /// Pestaña pedida por la ruta (?periodo=semana|mes)
  final SharePeriod? period;

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final _sticker = GlobalKey();
  SharePeriod? _period;
  final _picked = <SharePeriod, StickerKind>{};
  int? _background;
  double _opacity = 0.7;
  bool _busy = false;

  Future<Uint8List> _png() async {
    final boundary =
        _sticker.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1080 / stickerWidth);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/haki_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(await _png());
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path, mimeType: 'image/png')]),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      if (!await Gal.hasPermission() && !await Gal.requestPermission()) {
        throw StateError('gallery');
      }
      await Gal.putImageBytes(
        await _png(),
        name: 'haki_${DateTime.now().millisecondsSinceEpoch}',
      );
      messenger.showSnackBar(SnackBar(content: Text(l.shareSaved)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.shareSaveError)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final data = ref.watch(shareDataProvider(widget.assignmentId, widget.dayId));
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: BackHeader(title: l.shareTitle, titleSize: 20),
            ),
            Expanded(
              child: switch (data) {
                AsyncData(:final value) => _content(value),
                AsyncError() => Center(
                  child: Text(
                    l.summaryError,
                    style: TextStyle(color: c.textMuted),
                  ),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(ShareData d) {
    final l = context.l10n;
    final c = context.colors;
    var period = _period ?? widget.period ?? d.initial;
    if (period == SharePeriod.day && d.day == null) period = SharePeriod.week;
    final kinds = availableStickers(d, period);
    final kind = kinds.contains(_picked[period])
        ? _picked[period]!
        : kinds.firstOrNull;
    final now = DateTime.now();
    final subs = {
      SharePeriod.day: d.day == null
          ? '—'
          : (widget.dayId.isEmpty
                ? formatShortDate(d.day!.date)
                : l.sharePeriodDaySub),
      SharePeriod.week: stickerWeekRange(d.week.start),
      SharePeriod.month: formatMonthYear(d.month.month).split(' ').first,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Día / Semana / Mes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                for (final p in SharePeriod.values)
                  Expanded(
                    child: _PeriodTab(
                      label: switch (p) {
                        SharePeriod.day => l.sharePeriodDay,
                        SharePeriod.week => l.sharePeriodWeek,
                        SharePeriod.month => l.sharePeriodMonth,
                      },
                      sub: subs[p]!,
                      selected: p == period,
                      dot: p == SharePeriod.month && now.day <= 7,
                      onTap: p == SharePeriod.day && d.day == null
                          ? null
                          : () => setState(() => _period = p),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (period == SharePeriod.week && d.week.complete)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l.shareWeekDone,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: c.goldBright,
              ),
            ),
          ),

        // 2. Vista previa (cuadriculado = transparente; no sale en la imagen)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CustomPaint(
                painter: _CheckerPainter(),
                child: kind == null
                    ? Center(
                        child: Text(
                          l.shareNothing,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: RepaintBoundary(
                              key: _sticker,
                              child: Sticker(
                                kind: kind,
                                data: d,
                                background: _background,
                                opacity: _opacity,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),

        // 3. Sticker
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final k in kinds)
                SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 32 - 12) / 3,
                  child: _StickerChip(
                    icon: stickerIcon(k),
                    label: stickerLabel(context, k),
                    selected: k == kind,
                    onTap: () => setState(() => _picked[period] = k),
                  ),
                ),
            ],
          ),
        ),

        // 4. Fondo
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                child: Text(l.shareBackground, style: _label(c)),
              ),
              _Choice(
                label: l.shareNoBackground,
                selected: _background == null,
                onTap: () => setState(() => _background = null),
              ),
              const SizedBox(width: 8),
              for (var i = 0; i < ShareStoryColors.backgrounds.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Semantics(
                    button: true,
                    selected: _background == i,
                    label: [
                      l.shareColorObsidian,
                      l.shareColorGold,
                      l.shareColorTurquoise,
                      l.shareColorWhite,
                    ][i],
                    child: GestureDetector(
                      onTap: () => setState(() => _background = i),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: ShareStoryColors.backgrounds[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _background == i ? c.goldBright : c.border,
                            width: _background == i ? 3 : 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_background != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(l.shareOpacity, style: _label(c)),
                ),
                Expanded(
                  child: Slider(
                    value: _opacity,
                    min: 0.2,
                    max: 1,
                    divisions: 16,
                    onChanged: (v) => setState(() => _opacity = v),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${(_opacity * 100).round()} %',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

        // 5. Compartir / Guardar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: kind == null || _busy ? null : _share,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l.shareAction),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: kind == null || _busy ? null : _save,
                    child: Text(l.shareSave),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle _label(HakiColors c) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: c.textMuted,
  );
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
    this.dot = false,
  });

  final String label;
  final String sub;
  final bool selected;
  final bool dot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = onTap == null
        ? c.textMuted
        : (selected ? c.goldBright : c.textSecondary);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? c.goldSurface : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    if (dot) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: c.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StickerChip extends StatelessWidget {
  const _StickerChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.goldBright : c.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? c.goldSurface : c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: selected ? c.gold : c.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 54,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? c.gold : c.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cell = 9.0;
    final light = Paint()..color = ShareStoryColors.checkerLight;
    final dark = Paint()..color = ShareStoryColors.checkerDark;
    for (var y = 0.0; y < size.height; y += cell) {
      for (var x = 0.0; x < size.width; x += cell) {
        final odd = ((x / cell).floor() + (y / cell).floor()).isOdd;
        canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), odd ? dark : light);
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter oldDelegate) => false;
}
