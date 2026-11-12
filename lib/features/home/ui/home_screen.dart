import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/cache/api_cache.dart';
import '../../../core/format/dates.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/haki_loader.dart';
import '../../../core/widgets/haki_logo.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../agenda/data/agenda_dtos.dart';
import '../../agenda/providers/agenda_providers.dart';
import '../../agenda/ui/agenda_event_card.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../../inbox/providers/inbox_providers.dart';
import '../../program/data/program_schedule.dart';
import '../../program/providers/program_providers.dart';
import '../../questionnaire/providers/questionnaire_providers.dart';
import '../../session/data/session_store.dart';
import '../../questionnaire/ui/pending_questionnaire_card.dart';
import '../../questionnaire/data/questionnaire_dtos.dart';
import '../providers/selected_day_provider.dart';
import '../providers/today_provider.dart';
import 'today_widgets.dart';
import '../../../l10n/l10n.dart';

// Pantalla Hoy: qué toca entrenar hoy según el programa en curso.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final name = ref.watch(displayNameProvider);
    final today = ref.watch(todayProvider);
    // Día elegido en la tira (null = hoy)
    final selected = ref.watch(selectedDayProvider);
    // Pendientes sin responder: quedan hasta que los envía (no vencen); en otro
    // día solo los enviados ese día o antes
    final pending = pendingOn(
      ref.watch(myQuestionnairesProvider).value?.pending ?? const [],
      selected ?? DateTime.now(),
    );
    // El coach lo archivó o eliminó: aviso hasta que se cierra el acceso
    final accessEndsAt = ref.watch(authMeProvider).value?.accessEndsAt;
    // Sesiones con el coach del día elegido (debajo del entreno)
    final events = eventsOn(
      ref.watch(myAgendaProvider).value ?? const [],
      selected ?? DateTime.now(),
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            ref.read(apiCacheProvider).expire(wait: true);
            ref.invalidate(programSectionsProvider);
            ref.invalidate(programDetailProvider);
            ref.invalidate(myQuestionnairesProvider);
            ref.invalidate(myAgendaProvider);
            return ref.read(todayProvider.future);
          },
          child: ListView(
            // Pull-to-refresh aunque el contenido no llene la pantalla
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _Header(name: name),
              const SizedBox(height: 20),
              Text(
                l.homeGreeting(name.split(' ').first),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatLongDate(DateTime.now()),
                style: TextStyle(fontSize: 14, color: c.textMuted),
              ),
              const SizedBox(height: 20),
              if (accessEndsAt != null) ...[
                _AccessEndingCard(endsAt: accessEndsAt),
                const SizedBox(height: 14),
              ],
              ...switch (today) {
                AsyncData(:final value) => _content(
                  context,
                  ref,
                  value,
                  selected,
                ),
                AsyncError() => [
                  TodayInfoCard(
                    label: l.commonOffline,
                    title: l.homeLoadErrorTitle,
                    body: l.homeLoadErrorBody,
                  ),
                ],
                _ => const [
                  Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: Center(child: LoadingView()),
                  ),
                ],
              },
              for (final e in events) ...[
                const SizedBox(height: 12),
                AgendaEventCard(event: e),
              ],
              // Debajo de la tarjeta del entreno, el más viejo primero
              for (final q in pending) ...[
                const SizedBox(height: 12),
                PendingQuestionnaireCard(questionnaire: q),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    WidgetRef ref,
    TodayState state,
    DateTime? selected,
  ) {
    const gap = SizedBox(height: 20);
    final l = context.l10n;
    switch (state) {
      case NoProgram():
        return [
          TodayInfoCard(
            label: l.homeYourProgram,
            title: l.homeNoProgramTitle,
            body: l.homeNoProgramBody,
          ),
        ];
      case OnlyUpcoming(:final next):
        return [
          TodayInfoCard(
            label: l.homeUpcoming,
            title: next.blockName,
            body: next.startDate == null
                ? null
                : l.homeStartsOn(formatShortDate(next.startDate!)),
          ),
        ];
      case WithProgram(:final program, plan: final todayPlan, :final others, :final all):
        final now = DateTime.now();
        final day = selected ?? dateOnly(now);
        // Otro día de la tira: lo que toca ese día
        final plan = selected == null
            ? todayPlan
            : resolveToday(program, selected);
        final picker = ref.read(selectedDayProvider.notifier);
        // Programas en paralelo: una sola tira con los entrenos de todos
        final strip = combineStrips([
          for (final p in all) weekStrip(p, now, selected: selected),
        ]);
        bool canMove(int delta) => all.any((p) => canMoveStrip(p, day, delta));
        // Descanso en el primero pero otro programa tiene entreno: no se muestra el descanso
        final otherTraining = others.any((o) => resolveToday(o, selected ?? now) is TrainingDay);
        final hideFirst = otherTraining && plan is! TrainingDay;
        final weekForProgress = switch (plan) {
          TrainingDay(:final week) => week,
          WeekDone(:final week) => week,
          _ => null,
        };
        return [
          if (strip != null)
            WeekStrip(
              days: strip,
              onSelect: picker.select,
              onPrevWeek: canMove(-1)
                  ? () => picker.select(day.subtract(const Duration(days: 7)))
                  : null,
              onNextWeek: canMove(1)
                  ? () => picker.select(day.add(const Duration(days: 7)))
                  : null,
              onToday: selected == null ? null : picker.reset,
            )
          else if (weekForProgress != null)
            WeekProgressCard(week: weekForProgress),
          gap,
          if (!hideFirst) switch (plan) {
            TrainingDay() => TrainingDayCard(
              program: program,
              plan: plan,
              date: selected,
              onStart: () => _openOverProgram(
                context,
                Routes.session(program.assignmentId, plan.day.id),
              ),
              onOpenDone: () => _openOverProgram(
                context,
                Routes.pastSession(program.assignmentId, plan.day.id),
              ),
              onUnskip: () => ref
                  .read(sessionStoreProvider)
                  .unskip(program.assignmentId, plan.day.id, force: true),
            ),
            RestDay(:final next, :final nextDate) => TodayInfoCard(
              label: selected == null
                  ? l.homeRestLabel
                  : l.homeRestLabelOn(capitalize(formatShortDate(selected))),
              title: l.homeRestTitle,
              body: next != null
                  ? l.homeRestNext(next.title, formatShortDate(nextDate!))
                  : l.homeRestPreparing,
            ),
            WeekDone(:final week) => TodayInfoCard(
              label: l.weekOfTotal(week.weekNumber, program.totalWeeks),
              title: l.homeWeekDoneTitle,
              body: l.homeWeekDoneBody,
            ),
            ProgramFinished() => TodayInfoCard(
              label: l.homeProgramDoneLabel,
              title: program.blockName,
              body: l.homeProgramDoneBody,
            ),
          },
          // Programas en paralelo: una tarjeta más por cada programa con entreno ese día
          for (final other in others)
            if (resolveToday(other, selected ?? now) case final TrainingDay p) ...[
              const SizedBox(height: 12),
              TrainingDayCard(
                program: other,
                plan: p,
                date: selected,
                onStart: () => _openOverProgram(
                  context,
                  Routes.session(other.assignmentId, p.day.id),
                ),
                onOpenDone: () => _openOverProgram(
                  context,
                  Routes.pastSession(other.assignmentId, p.day.id),
                ),
                onUnskip: () => ref
                    .read(sessionStoreProvider)
                    .unskip(other.assignmentId, p.day.id, force: true),
              ),
            ],
        ];
    }
  }
}

/// La Sesión (y la Sesión pasada) se abre encima del tab Programa: al volver
/// se ve el programa en la semana actual, no Hoy.
void _openOverProgram(BuildContext context, String route) {
  final router = GoRouter.of(context);
  router.go(Routes.programAtCurrentWeek());
  WidgetsBinding.instance.addPostFrameCallback((_) => router.push(route));
}

/// Aviso de la semana de gracia: el coach terminó el plan.
class _AccessEndingCard extends StatelessWidget {
  const _AccessEndingCard({required this.endsAt});

  final DateTime endsAt;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.goldSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.goldBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: c.goldBright),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.homeAccessEnds(formatShortDate(endsAt)),
              style: TextStyle(fontSize: 13, height: 1.4, color: c.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final unread = ref.watch(myInboxProvider).value?.unread ?? 0;
    return Row(
      children: [
        const HakiLogoMark(size: 30, pulse: false),
        const SizedBox(width: 8),
        Text(
          'haki',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: .6,
            color: c.text,
          ),
        ),
        const Spacer(),
        _InboxButton(unread: unread),
        const SizedBox(width: 10),
        Semantics(
          button: true,
          label: context.l10n.homeYourProfile,
          child: GestureDetector(
            onTap: () => context.go(Routes.profile),
            child: UserAvatar(name: name),
          ),
        ),
      ],
    );
  }
}

/// Campana de avisos con el número de no leídos.
class _InboxButton extends StatelessWidget {
  const _InboxButton({required this.unread});

  final int unread;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: context.l10n.inboxButton(unread),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => context.push(Routes.inbox),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: c.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.border),
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    size: 21,
                    color: c.textSecondary,
                  ),
                ),
              ),
              if (unread > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: c.gold,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: c.onAccent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
