import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/advisor/chat_screen.dart';
import '../features/couple/couple_quizzes_screen.dart';
import '../features/cycle/cycle_tracker_screen.dart';
import '../features/cycle/pcos_lab_panel_screen.dart';
import '../features/cycle/pcos_self_check_screen.dart';
import '../features/guides/guides_screen.dart';
import '../features/onboarding/entry_choice_screen.dart';
import '../features/onboarding/mode_select_screen.dart';
import '../features/onboarding/onboarding_finale_screen.dart';
import '../features/onboarding/partner_onboarding_screen.dart';
import '../features/onboarding/planning_intake_screen.dart';
import '../features/planning/planning_hub_screen.dart';
import '../features/postpartum/postpartum_screen.dart';
import '../features/pregnancy/anc_planner_screen.dart';
import '../features/pregnancy/birth_plan_screen.dart';
import '../features/pregnancy/contraction_timer_screen.dart';
import '../features/pregnancy/kick_counter_screen.dart';
import '../features/records/records_screen.dart';
import '../features/records/test_detail_screen.dart';
import '../features/records/vitals_log_screen.dart';
import '../features/reminders/medicine_reminders_screen.dart';
import '../features/security/privacy_sync_screen.dart';
import '../features/timeline/timeline_screen.dart';
import '../features/trends/trends_screen.dart';
import '../features/validity/danger_sign_checker_screen.dart';
import '../features/vault/media_vault_screen.dart';
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
      path: '/reminders',
      name: 'reminders',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MedicineRemindersScreen(),
    ),
    GoRoute(
      path: '/couple-quizzes',
      name: 'coupleQuizzes',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CoupleQuizzesScreen(),
    ),
    GoRoute(
      path: '/cycle',
      name: 'cycle',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CycleTrackerScreen(),
    ),
    GoRoute(
      path: '/pcos-self-check',
      name: 'pcosSelfCheck',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PcosSelfCheckScreen(),
    ),
    GoRoute(
      path: '/pcos-lab-panel',
      name: 'pcosLabPanel',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PcosLabPanelScreen(),
    ),
    GoRoute(
      path: '/planning',
      name: 'planning',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PlanningHubScreen(),
    ),
    GoRoute(
      path: '/kick-counter',
      name: 'kickCounter',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const KickCounterScreen(),
    ),
    GoRoute(
      path: '/contraction-timer',
      name: 'contractionTimer',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ContractionTimerScreen(),
    ),
    GoRoute(
      path: '/anc-planner',
      name: 'ancPlanner',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AncPlannerScreen(),
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
      path: '/guides',
      name: 'guides',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const GuidesScreen(),
    ),
    GoRoute(
      path: '/vault',
      name: 'mediaVault',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MediaVaultScreen(),
    ),
    GoRoute(
      path: '/privacy-sync',
      name: 'privacySync',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PrivacySyncScreen(),
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
        GoRoute(
          path: 'partner-intake',
          name: 'partnerIntake',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const PartnerOnboardingScreen(),
        ),
        GoRoute(
          path: 'planning-intake',
          name: 'planningIntake',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const PlanningIntakeScreen(),
        ),
        GoRoute(
          path: 'finale',
          name: 'onboardingFinale',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const OnboardingFinaleScreen(),
        ),
      ],
    ),
  ],
);
