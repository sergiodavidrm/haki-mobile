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
import '../../auth/data/auth_repository.dart';
import '../../program/data/program_schedule.dart';
import '../../program/providers/program_providers.dart';
import '../providers/today_provider.dart';
import 'today_widgets.dart';

// Pantalla Hoy: qué toca entrenar hoy según el programa en curso.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final name = ref.watch(authRepositoryProvider).displayName;
    final today = ref.watch(todayProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            ref.read(apiCacheProvider).expire(wait: true);
            ref.invalidate(programSectionsProvider);
            ref.invalidate(programDetailProvider);
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
                'Hola, ${name.split(' ').first}',
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
              ...switch (today) {
                AsyncData(:final value) => _content(context, value),
                AsyncError() => [
                  TodayInfoCard(
                    label: 'Sin conexión',
                    title: 'No pudimos cargar tu programa',
                    body: 'Revisá tu conexión y deslizá hacia abajo para reintentar.',
                  ),
                ],
                _ => const [
                  Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: Center(child: LoadingView()),
                  ),
                ],
              },
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, TodayState state) {
    const gap = SizedBox(height: 20);
    switch (state) {
      case NoProgram():
        return const [
          TodayInfoCard(
            label: 'Tu programa',
            title: 'Todavía no tenés un programa',
            body: 'Cuando tu coach te asigne uno, aparece acá.',
          ),
        ];
      case OnlyUpcoming(:final next):
        return [
          TodayInfoCard(
            label: 'Próximo',
            title: next.blockName,
            body: next.startDate == null
                ? null
                : 'Empieza el ${formatShortDate(next.startDate!)}.',
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
              onStart: () =>
                  _openSession(context, program.assignmentId, plan.day.id),
            ),
            RestDay(:final next, :final nextDate) => TodayInfoCard(
              label: 'Hoy · Descanso',
              title: 'Día de descanso',
              body: next != null
                  ? 'Próximo: ${next.title} · ${formatShortDate(nextDate!)}'
                  : 'Tu coach está preparando lo que sigue.',
            ),
            WeekDone(:final week) => TodayInfoCard(
              label: 'Semana ${week.weekNumber} de ${program.totalWeeks}',
              title: 'Semana completa',
              body: 'Hiciste todos los entrenos de esta semana. La que viene sigue el programa.',
            ),
            ProgramFinished() => TodayInfoCard(
              label: 'Programa terminado',
              title: program.blockName,
              body:
                  'Completaste el bloque. Tu coach te va a asignar el próximo.',
            ),
          },
        ];
    }
  }
}

/// La Sesión se abre encima del tab Programa: al volver se ve el programa en
/// la semana actual, no Hoy.
void _openSession(BuildContext context, String assignmentId, String dayId) {
  final router = GoRouter.of(context);
  router.go(Routes.programAtCurrentWeek());
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => router.push(Routes.session(assignmentId, dayId)),
  );
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
          label: 'Tu perfil',
          child: GestureDetector(
            onTap: () => context.go(Routes.profile),
            child: UserAvatar(name: name),
          ),
        ),
      ],
    );
  }
}
