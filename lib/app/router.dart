import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  ],
);
