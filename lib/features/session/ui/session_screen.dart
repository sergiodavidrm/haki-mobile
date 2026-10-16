import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/units/weight_unit.dart';
import '../../../core/widgets/haki_card.dart';
import '../../program/data/assignment_dtos.dart';
import '../data/session_plan.dart';
import '../data/session_store.dart';
import '../providers/rest_timer.dart';
import '../providers/session_providers.dart';
import 'exercise_block.dart';
import 'rest_timer_widgets.dart';

// Sesión de entreno: registrar series. Todo se guarda primero en el teléfono
// (drift) y SessionSync lo sube; funciona sin señal.
class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({
    super.key,
    required this.assignmentId,
    required this.dayId,
  });

  final String assignmentId;
  final String dayId;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  late final Timer _tick;

  /// Grupos que el atleta abrió a mano (id del primer ejercicio).
  final _expanded = <String>{};

  String get _a => widget.assignmentId;
  String get _d => widget.dayId;

  @override
  void initState() {
    super.initState();
    // Refresca "entrenando hace X min"
    _tick = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
    // Entrar a la sesión = empezarla (idempotente si ya estaba empezada)
    ref.read(sessionStoreProvider).start(_a, _d);
  }

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final day = ref.watch(sessionDayProvider(_a, _d));

    return Scaffold(
      body: SafeArea(
        child: switch (day) {
          AsyncData(:final value) => _content(value),
          AsyncError(:final error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No se pudo abrir la sesión.\n$error',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.textMuted),
              ),
            ),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Widget _content(SessionDay s) {
    final local = ref.watch(localSetsProvider(_a, _d)).value ?? const {};
    final session = ref.watch(localSessionProvider(_a, _d)).value;
    final dayUnit = ref.watch(dayWeightUnitProvider(_d));
    final overrides = ref.watch(exerciseUnitOverridesProvider(_d));

    SavedSet? savedFor(DayExerciseDto e, int n) => savedSetFor(e, n, local);
    final groups = groupSupersets(s.day.exercises);
    // La primera serie pendiente de la sesión: se resalta como "Siguiente"
    final next = workOrder(groups)
        .where((r) => savedFor(r.exercise, r.setNumber) == null)
        .firstOrNull;

    // Abiertos: el que tiene la serie que sigue, los que ya tienen series y
    // los que el atleta abrió. El resto queda colapsado (como en el mockup).
    bool expanded(ExerciseGroup g) =>
        _expanded.contains(g.exercises.first.id) ||
        g.exercises.any((e) => e.id == next?.exercise.id) ||
        g.exercises.any(
          (e) => List.generate(
            setCountOf(e),
            (i) => savedFor(e, i + 1),
          ).any((x) => x != null),
        );

    Widget block(DayExerciseDto e, {String? badge, bool showRail = true}) {
      final unit = overrides[e.id] ?? dayUnit;
      return ExerciseBlock(
        exercise: e,
        badge: badge,
        showRail: showRail,
        nextSetNumber: next?.exercise.id == e.id ? next!.setNumber : null,
        onVideo: (n, requested) => _uploadVideo(n, requested),
        unit: unit,
        isUnitOverridden:
            overrides.containsKey(e.id) && overrides[e.id] != dayUnit,
        savedFor: (n) => savedFor(e, n),
        onToggleUnit: () => ref
            .read(exerciseUnitOverridesProvider(_d).notifier)
            .toggle(e.id, unit, dayUnit),
        onSaveSet: (n, w, u, reps, rir) {
          final after = afterSave(
            groups,
            e,
            n,
            wasSaved: savedFor(e, n) != null,
            isSaved: (r) => savedFor(r.exercise, r.setNumber) != null,
          );
          ref
              .read(sessionStoreProvider)
              .saveSet(
                assignmentId: _a,
                dayId: _d,
                dayExerciseId: e.id,
                setNumber: n,
                weight: w,
                unit: u,
                reps: reps,
                rir: rir,
              );
          _prepareRest(groups, e, n, rest: after.rest, next: after.next);
        },
      );
    }

    final doneCount = s.day.exercises.where((e) {
      return List.generate(
        setCountOf(e),
        (i) => savedFor(e, i + 1),
      ).every((x) => x != null);
    }).length;
    final missingSets = s.day.exercises.fold<int>(0, (acc, e) {
      return acc +
          List.generate(
            setCountOf(e),
            (i) => savedFor(e, i + 1),
          ).where((x) => x == null).length;
    });
    final pendingSync = local.values.where((l) => !l.synced).length;
    final completed =
        session?.completedAt != null ||
        s.day.sessionStatus == SessionStatus.completed;

    return Column(
      children: [
        _Header(
          title: s.day.title,
          week: s.week.weekNumber,
          startedAt: session?.startedAt,
          done: doneCount,
          total: s.day.exercises.length,
          pendingSync: pendingSync,
          unit: dayUnit,
          onUnit: (u) {
            ref.read(dayWeightUnitProvider(_d).notifier).set(u);
            ref
                .read(exerciseUnitOverridesProvider(_d).notifier)
                .dropMatching(u);
          },
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              for (final g in groups) ...[
                if (!expanded(g))
                  _CollapsedGroup(
                    group: g,
                    onTap: () =>
                        setState(() => _expanded.add(g.exercises.first.id)),
                  )
                else if (g.letter == null)
                  HakiCard(
                    radius: 22,
                    padding: const EdgeInsets.all(14),
                    child: block(g.exercises.single),
                  )
                else
                  _SupersetCard(
                    group: g,
                    children: [
                      for (final (i, e) in g.exercises.indexed)
                        block(
                          e,
                          badge: g.badgeOf(e),
                          showRail: i < g.exercises.length - 1,
                        ),
                    ],
                  ),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 6),
              if (completed)
                OutlinedButton.icon(
                  onPressed: () => context.push(Routes.sessionDone(_a, _d)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: context.colors.turquoise,
                    side: BorderSide(color: context.colors.turquoiseBorder),
                  ),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Entreno completado · ver resumen'),
                )
              else
                OutlinedButton(
                  onPressed: () => _finish(missingSets),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: context.colors.text,
                    side: BorderSide(color: context.colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Finalizar entreno'),
                ),
            ],
          ),
        ),
        const RestTimerBar(),
      ],
    );
  }

  /// Serie sin video pedido: se confirma antes de subir.
  Future<void> _uploadVideo(int setNumber, bool requested) async {
    if (!requested) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Subir video?'),
          content: const Text(
            'Tu entrenador no solicitó video para esta serie. ¿Deseás subirlo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Subir video'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    _videoNotReady();
  }

  // TODO: grabar/elegir video y subirlo con la cola (Cloudinary sin integrar).
  void _videoNotReady() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Subir videos va a estar disponible pronto'),
        ),
      );
  }

  /// El timer es manual: solo se le pasa qué se terminó y qué viene, para
  /// mostrarlo cuando el atleta lo arranque.
  void _prepareRest(
    List<ExerciseGroup> groups,
    DayExerciseDto e,
    int setNumber, {
    required bool rest,
    required SetRef? next,
  }) {
    if (next == null) return;
    final g = groups.firstWhere((g) => g.exercises.contains(e));
    final String title;
    final String subtitle;
    if (g.letter == null) {
      title = e.exerciseName;
      subtitle = 'Serie $setNumber hecha';
    } else if (!rest) {
      // A mitad de ronda: lo que sigue va sin pausa
      title = 'Superserie ${g.letter}';
      subtitle = '${g.badgeOf(e)} hecha · seguí sin pausa';
    } else {
      final badges = [
        for (final x in g.exercises)
          if (setCountOf(x) >= setNumber) g.badgeOf(x)!,
      ];
      final done = badges.length == 1
          ? '${badges.single} hecha'
          : '${badges.sublist(0, badges.length - 1).join(', ')} y ${badges.last} hechas';
      title = 'Superserie ${g.letter}';
      subtitle = '$done · descansá antes de repetir';
    }
    ref
        .read(restTimerProvider.notifier)
        .prepare(
          RestInfo(title: title, subtitle: subtitle, next: _nextInfo(next)),
        );
  }

  NextSetInfo? _nextInfo(SetRef? r) {
    if (r == null) return null;
    final overrides = ref.read(exerciseUnitOverridesProvider(_d));
    final WeightUnit unit =
        overrides[r.exercise.id] ?? ref.read(dayWeightUnitProvider(_d));
    final t = r.exercise.targetSets
        .where((s) => s.setNumber == r.setNumber)
        .firstOrNull;
    final load = [
      if (t?.weightKg != null)
        '${formatWeight(unit.fromKg(t!.weightKg!))} ${unit.label}',
      if (t?.reps != null) '${t!.reps}',
    ].join(' × ');
    final target = [
      if (load.isNotEmpty) load,
      if (t?.rir != null) 'RIR ${t!.rir}',
    ].join(' · ');
    return NextSetInfo(
      exerciseName: r.exercise.exerciseName,
      setNumber: r.setNumber,
      badge: r.badge,
      target: target.isEmpty ? null : target,
    );
  }

  Future<void> _finish(int missingSets) async {
    if (missingSets > 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Finalizar el entreno?'),
          content: Text(
            missingSets == 1
                ? 'Te falta registrar 1 serie.'
                : 'Te faltan registrar $missingSets series.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Seguir entrenando'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Finalizar'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await ref.read(sessionStoreProvider).complete(_a, _d);
    ref.read(restTimerProvider.notifier).reset();
    if (!mounted) return;
    context.pushReplacement(Routes.sessionDone(_a, _d));
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.week,
    required this.startedAt,
    required this.done,
    required this.total,
    required this.pendingSync,
    required this.unit,
    required this.onUnit,
  });

  final String title;
  final int week;
  final DateTime? startedAt;
  final int done;
  final int total;
  final int pendingSync;
  final WeightUnit unit;
  final ValueChanged<WeightUnit> onUnit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final minutes = startedAt == null
        ? null
        : DateTime.now().difference(startedAt!).inMinutes;
    final subtitle = [
      'Semana $week',
      if (minutes != null)
        minutes < 1 ? 'recién empezado' : 'entrenando hace $minutes min',
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.surfaceHigh)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Volver',
                onPressed: () => context.pop(),
                icon: const Icon(Icons.chevron_left, size: 28),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: c.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const RestTimerButton(),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : done / total,
                      minHeight: 6,
                      color: c.turquoise,
                      backgroundColor: c.surfaceHigh,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$done de $total',
                  style: TextStyle(
                    fontSize: 12,
                    color: c.textMuted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 10),
                _UnitSegment(unit: unit, onChanged: onUnit),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Text(
              pendingSync > 0
                  ? '$pendingSync ${pendingSync == 1 ? 'serie guardada' : 'series guardadas'} en el teléfono · se suben al tener señal'
                  : 'Tocá la unidad de un ejercicio para cambiarla solo en ese.',
              style: TextStyle(
                fontSize: 11,
                color: pendingSync > 0 ? c.goldBright : c.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Switch KG/LB del día (pastilla segmentada del mockup).
class _UnitSegment extends StatelessWidget {
  const _UnitSegment({required this.unit, required this.onChanged});

  final WeightUnit unit;
  final ValueChanged<WeightUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      container: true,
      label: 'Unidad de peso del día',
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final u in WeightUnit.values)
              Semantics(
                button: true,
                selected: u == unit,
                child: Material(
                  color: u == unit ? c.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(9),
                    onTap: () => onChanged(u),
                    child: SizedBox(
                      width: 44,
                      height: 32,
                      child: Center(
                        child: Text(
                          u.api,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .7,
                            color: u == unit ? c.background : c.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SupersetCard extends StatelessWidget {
  const _SupersetCard({required this.group, required this.children});

  final ExerciseGroup group;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final letter = group.letter!;
    final badges = [for (final e in group.exercises) group.badgeOf(e)!];
    final chip = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: c.turquoiseMuted,
    );
    Widget badgeChip(String b) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.turquoiseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(b, style: chip.copyWith(color: c.turquoise)),
    );
    final arrow = Icon(Icons.arrow_forward, size: 14, color: c.turquoiseMuted);

    return Semantics(
      container: true,
      label: 'Superserie $letter',
      child: HakiCard(
        tone: HakiCardTone.turquoise,
        radius: 22,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _LetterTile(letter),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Superserie $letter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: c.text,
                        ),
                      ),
                      Text(
                        'Sin pausa entre ${_joinAnd(badges)}',
                        style: TextStyle(fontSize: 12, color: c.turquoiseMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Flujo: A1 → A2 → descanso ↻ repetir
            ExcludeSemantics(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final b in badges) ...[badgeChip(b), arrow],
                  Text('descanso', style: chip),
                  Icon(Icons.replay, size: 14, color: c.turquoiseMuted),
                  Text('repetir', style: chip),
                ],
              ),
            ),
            for (final child in children) ...[
              const SizedBox(height: 12),
              child,
            ],
          ],
        ),
      ),
    );
  }
}

/// Ejercicio o superserie que todavía no empezó: una fila tocable.
class _CollapsedGroup extends StatelessWidget {
  const _CollapsedGroup({required this.group, required this.onTap});

  final ExerciseGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final g = group;
    final single = g.letter == null;
    final title = single
        ? g.exercises.single.exerciseName
        : 'Superserie ${g.letter}';
    final subtitle = single
        ? exerciseSummary(g.exercises.single)
        : g.exercises
              .map((e) => '${g.badgeOf(e)} ${e.exerciseName}')
              .join(' · ');

    return Semantics(
      button: true,
      label: '$title. $subtitle. Tocá para abrir',
      excludeSemantics: true,
      child: HakiCard(
        tone: single ? HakiCardTone.neutral : HakiCardTone.turquoise,
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        child: Row(
          children: [
            single ? const ExerciseIconTile() : _LetterTile(g.letter!),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: single ? 16 : 15,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: single ? c.textMuted : c.turquoiseMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.expand_more, size: 20, color: c.textMuted),
          ],
        ),
      ),
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile(this.letter);

  final String letter;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.turquoise,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: c.background,
        ),
      ),
    );
  }
}

String _joinAnd(List<String> items) => items.length == 1
    ? items.single
    : '${items.sublist(0, items.length - 1).join(', ')} y ${items.last}';
