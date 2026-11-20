import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/advisor/chat_screen.dart';
import '../features/onboarding/entry_choice_screen.dart';
import '../features/onboarding/mode_select_screen.dart';
import '../features/postpartum/postpartum_screen.dart';
import '../features/pregnancy/birth_plan_screen.dart';
import '../features/pregnancy/kick_counter_screen.dart';
import '../features/records/records_screen.dart';
import '../features/records/test_detail_screen.dart';
import '../features/records/vitals_log_screen.dart';
import '../features/timeline/timeline_screen.dart';
import '../features/trends/trends_screen.dart';
import '../features/validity/danger_sign_checker_screen.dart';
import '../features/verify/verify_screen.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/timeline',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/timeline',
              name: 'timeline',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: TimelineScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/records',
              name: 'records',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: RecordsScreen()),
              routes: [
                GoRoute(
                  path: 'detail/:testName',
                  name: 'testDetail',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final rawName = state.pathParameters['testName'] ?? '';
                    final testName = Uri.decodeComponent(rawName);
                    return TestDetailScreen(testName: testName);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/verify',
              name: 'verify',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: VerifyScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/trends',
              name: 'trends',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: TrendsScreen()),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/danger-signs',
      name: 'dangerSigns',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DangerSignCheckerScreen(),
    ),
    GoRoute(
      path: '/vitals',
      name: 'vitals',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const VitalsLogScreen(),
    ),
    GoRoute(
      path: '/advisor',
      name: 'advisor',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: '/kick-counter',
      name: 'kickCounter',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const KickCounterScreen(),
    ),
    GoRoute(
      path: '/birth-plan',
      name: 'birthPlan',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BirthPlanScreen(),
    ),
    GoRoute(
      path: '/postpartum',
      name: 'postpartum',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PostpartumScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EntryChoiceScreen(),
      routes: [
        GoRoute(
          path: 'mode',
          name: 'onboardingMode',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ModeSelectScreen(),
        ),
      ],
    ),
  ],
);
