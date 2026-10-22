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
import '../../auth/providers/auth_me_provider.dart';
import '../../program/data/program_schedule.dart';
import '../../program/providers/program_providers.dart';
import '../../questionnaire/providers/questionnaire_providers.dart';
import '../../questionnaire/ui/pending_questionnaire_card.dart';
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
    // Pendientes sin responder: quedan en Hoy hasta que los envía (no vencen)
    final pending =
        ref.watch(myQuestionnairesProvider).value?.pending ?? const [];
    // El coach lo archivó o eliminó: aviso hasta que se cierra el acceso
    final accessEndsAt = ref.watch(authMeProvider).value?.accessEndsAt;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            ref.read(apiCacheProvider).expire(wait: true);
            ref.invalidate(programSectionsProvider);
            ref.invalidate(programDetailProvider);
            ref.invalidate(myQuestionnairesProvider);
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
                AsyncData(:final value) => _content(context, value),
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

  List<Widget> _content(BuildContext context, TodayState state) {
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
      case WithProgram(:final program, :final plan):
        final strip = weekStrip(program, DateTime.now());
        final weekForProgress = switch (plan) {
          TrainingDay(:final week) => week,
          WeekDone(:final week) => week,
          _ => null,
        };
        return [
          if (strip != null)
            WeekStrip(days: strip)
          else if (weekForProgress != null)
            WeekProgressCard(week: weekForProgress),
          gap,
          switch (plan) {
            TrainingDay() => TrainingDayCard(
              program: program,
              plan: plan,
              onStart: () => _openOverProgram(
                context,
                Routes.session(program.assignmentId, plan.day.id),
              ),
              onOpenDone: () => _openOverProgram(
                context,
                Routes.pastSession(program.assignmentId, plan.day.id),
              ),
            ),
            RestDay(:final next, :final nextDate) => TodayInfoCard(
              label: l.homeRestLabel,
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

class _Header extends StatelessWidget {
  const _Header({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
