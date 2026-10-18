import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/ui/athlete_gate.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/profile/ui/profile_screen.dart';
import '../../features/program/ui/assign_dates_screen.dart';
import '../../features/program/ui/past_session_screen.dart';
import '../../features/program/ui/program_screen.dart';
import '../../features/program/ui/programs_list_screen.dart';
import '../../features/session/ui/rest_timer_screen.dart';
import '../../features/session/ui/session_screen.dart';
import '../../features/session/ui/workout_complete_screen.dart';
import '../widgets/app_shell.dart';
import '../widgets/coming_soon.dart';

part 'app_router.g.dart';

abstract final class Routes {
  static const home = '/';
  static const login = '/login';
  static const program = '/programa';
  static const chat = '/chat';
  static const profile = '/perfil';
  static const rest = '/descanso';
  static String session(String assignmentId, String dayId) =>
      '/sesion/$assignmentId/$dayId';
  static String sessionDone(String assignmentId, String dayId) =>
      '/completado/$assignmentId/$dayId';

  // Dentro del tab Programa (con la barra de tabs)
  static const programs = '/programa/todos';

  /// Tab Programa forzando la semana actual en el selector (aunque el
  /// atleta hubiera elegido otra antes).
  static String programAtCurrentWeek() =>
      '$program?semana=${DateTime.now().microsecondsSinceEpoch}';
  static String programView(String assignmentId) => '/programa/p/$assignmentId';
  static String pastSession(String assignmentId, String dayId) =>
      '/programa/sesion/$assignmentId/$dayId';

  /// Pantalla completa, sin tabs.
  static String assignDates(String assignmentId) => '/fechas/$assignmentId';
}

// Rutas + guard de auth (equivalente a app.routes.ts + authGuard del web).
// Se reevalúa el redirect cada vez que cambia la sesión de Supabase.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final auth = ref.watch(authRepositoryProvider);
  final refresh = _StreamListenable(auth.authChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final atLogin = state.matchedLocation == Routes.login;
      if (!auth.isLoggedIn) return atLogin ? null : Routes.login;
      if (atLogin) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      // Pantalla completa, sin la barra de tabs
      GoRoute(
        path: '/sesion/:assignmentId/:dayId',
        builder: (_, state) => SessionScreen(
          assignmentId: state.pathParameters['assignmentId']!,
          dayId: state.pathParameters['dayId']!,
        ),
      ),
      GoRoute(path: Routes.rest, builder: (_, _) => const RestTimerScreen()),
      GoRoute(
        path: '/fechas/:assignmentId',
        builder: (_, state) => AssignDatesScreen(
          assignmentId: state.pathParameters['assignmentId']!,
        ),
      ),
      GoRoute(
        path: '/completado/:assignmentId/:dayId',
        builder: (_, state) => WorkoutCompleteScreen(
          assignmentId: state.pathParameters['assignmentId']!,
          dayId: state.pathParameters['dayId']!,
        ),
      ),
      // Los 4 tabs; AthleteGate envuelve el shell entero
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AthleteGate(child: AppShell(shell: shell)),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.program,
                builder: (_, state) => ProgramScreen(
                  resetWeek: state.uri.queryParameters['semana'],
                ),
                routes: [
                  GoRoute(
                    path: 'todos',
                    builder: (_, _) => const ProgramsListScreen(),
                  ),
                  GoRoute(
                    path: 'p/:assignmentId',
                    builder: (_, state) => ProgramScreen(
                      assignmentId: state.pathParameters['assignmentId'],
                    ),
                  ),
                  GoRoute(
                    path: 'sesion/:assignmentId/:dayId',
                    builder: (_, state) => PastSessionScreen(
                      assignmentId: state.pathParameters['assignmentId']!,
                      dayId: state.pathParameters['dayId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.chat,
                builder: (_, _) => const ComingSoon(
                  title: 'Chat',
                  message: 'Acá vas a hablar con tu coach.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
