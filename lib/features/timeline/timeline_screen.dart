import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/l10n/tts_service.dart';
import '../couple/couple_hints_provider.dart';
import '../couple/partner_story_cards.dart';
import '../insights/mood_state_insight_card.dart';
import '../onboarding/entry_state.dart';
import '../onboarding/mode_selection_state.dart';
import '../postpartum/postpartum_provider.dart';
import '../profile/profile_provider.dart';
import '../reminders/medicine_reminders_provider.dart';
import '../security/vault_lock_provider.dart';
import '../stage/checklist_provider.dart';
import '../stage/stage.dart';
import '../stage/stage_provider.dart';

/// Presentation model for mode-specific quick access shortcut cards.
class ModeShortcutItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color containerColor;
  final String route;

  const ModeShortcutItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.containerColor,
    required this.route,
  });
}

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  static IconData _getStageIcon(PregnancyStage stage) {
    switch (stage) {
      case PregnancyStage.plan:
        return Icons.spa_rounded;
      case PregnancyStage.trying:
        return Icons.water_drop_rounded;
      case PregnancyStage.pregnancy:
        return Icons.child_care_rounded;
      case PregnancyStage.postpartum:
        return Icons.family_restroom_rounded;
    }
  }

  static Color _getStageAccentColor(PregnancyStage stage) {
    switch (stage) {
      case PregnancyStage.plan:
        return const Color(0xFF6D1D32);
      case PregnancyStage.trying:
        return const Color(0xFFB23C59);
      case PregnancyStage.pregnancy:
        return const Color(0xFF8E2B44);
      case PregnancyStage.postpartum:
        return const Color(0xFF4B0F1E);
    }
  }

  static List<ModeShortcutItem> _getShortcutsForMode(
    PreNestMode mode,
    AppLanguage lang,
  ) {
    switch (mode) {
      case PreNestMode.periodTracker:
        return [
          ModeShortcutItem(
            title: AppStrings.t('Cycle & PCOS Hub', lang),
            subtitle: 'Irregular mode & symptoms',
            icon: Icons.water_drop_rounded,
            accentColor: const Color(0xFFE11D48),
            containerColor: const Color(0xFFFFE4E6),
            route: '/cycle',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Symptom Checker', lang),
            subtitle: 'Discomforts & red flags',
            icon: Icons.health_and_safety_rounded,
            accentColor: const Color(0xFF0F766E),
            containerColor: const Color(0xFFCCFBF1),
            route: '/symptom-checker',
          ),
          ModeShortcutItem(
            title: AppStrings.t('PCOS Self-Check', lang),
            subtitle: 'Rule-based check',
            icon: Icons.checklist_rtl_rounded,
            accentColor: const Color(0xFFE11D48),
            containerColor: const Color(0xFFFFE4E6),
            route: '/pcos-self-check',
          ),
          ModeShortcutItem(
            title: AppStrings.t('PCOS Lab Panel', lang),
            subtitle: '10 clinical markers',
            icon: Icons.biotech_rounded,
            accentColor: const Color(0xFF0F766E),
            containerColor: const Color(0xFFCCFBF1),
            route: '/pcos-lab-panel',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Vitals Log', lang),
            subtitle: 'Flow, BBT & vitals',
            icon: Icons.monitor_heart,
            accentColor: const Color(0xFF0F766E),
            containerColor: const Color(0xFFCCFBF1),
            route: '/vitals',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Trends', lang),
            subtitle: 'Cycle & hormone trends',
            icon: Icons.insights_rounded,
            accentColor: const Color(0xFF0284C7),
            containerColor: const Color(0xFFE0F2FE),
            route: '/trends',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Doctor Summary', lang),
            subtitle: 'One-page PDF & talking points',
            icon: Icons.picture_as_pdf_rounded,
            accentColor: const Color(0xFF0F766E),
            containerColor: const Color(0xFFCCFBF1),
            route: '/doctor-summary',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Danger Signs', lang),
            subtitle: AppStrings.t('Critical triage & 108 dispatch', lang),
            icon: Icons.warning_amber_rounded,
            accentColor: const Color(0xFFDC2626),
            containerColor: const Color(0xFFFEE2E2),
            route: '/danger-signs',
          ),
        ];

      case PreNestMode.planningPregnancy:
        return [
          ModeShortcutItem(
            title: AppStrings.t('Planning Hub', lang),
            subtitle: 'Readiness, habits & tests',
            icon: Icons.spa_rounded,
            accentColor: const Color(0xFF0F766E),
            containerColor: const Color(0xFFCCFBF1),
            route: '/planning',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Symptom Checker', lang),
            subtitle: 'Preconception comfort & signs',
            icon: Icons.health_and_safety_rounded,
            accentColor: const Color(0xFF0F766E),
            containerColor: const Color(0xFFCCFBF1),
            route: '/symptom-checker',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Vitals Log', lang),
            subtitle: 'Preconception health',
            icon: Icons.monitor_heart,
            accentColor: const Color(0xFFE11D48),
            containerColor: const Color(0xFFFFE4E6),
            route: '/vitals',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Records', lang),
            subtitle: 'Preconception labs & tests',
            icon: Icons.folder_shared_rounded,
            accentColor: const Color(0xFF0284C7),
            containerColor: const Color(0xFFE0F2FE),
            route: '/records',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Doctor Summary', lang),
            subtitle: 'One-page PDF & talking points',
            icon: Icons.picture_as_pdf_rounded,
            accentColor: const Color(0xFF0F766E),
            containerColor: const Color(0xFFCCFBF1),
            route: '/doctor-summary',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Danger Signs', lang),
            subtitle: AppStrings.t('Critical triage & 108 dispatch', lang),
            icon: Icons.warning_amber_rounded,
            accentColor: const Color(0xFFDC2626),
            containerColor: const Color(0xFFFEE2E2),
            route: '/danger-signs',
          ),
        ];

      case PreNestMode.pregnant:
        return [
          ModeShortcutItem(
            title: AppStrings.t('ANC Planner', lang),
            subtitle: '4+ visits & IFA/calcium',
            icon: Icons.event_note_rounded,
            accentColor: const Color(0xFF0F766E),
            containerColor: const Color(0xFFCCFBF1),
            route: '/anc-planner',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Symptom Checker', lang),
            subtitle: 'Trimester comfort & red flags',
            icon: Icons.health_and_safety_rounded,
            accentColor: const Color(0xFF0284C7),
            containerColor: const Color(0xFFE0F2FE),
            route: '/symptom-checker',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Contraction Timer', lang),
            subtitle: '5-1-1 labor tracking',
            icon: Icons.timer_outlined,
            accentColor: const Color(0xFFE11D48),
            containerColor: const Color(0xFFFFE4E6),
            route: '/contraction-timer',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Kick Counter', lang),
            subtitle: '10 kicks in 2h timer',
            icon: Icons.touch_app_rounded,
            accentColor: const Color(0xFF0284C7),
            containerColor: const Color(0xFFE0F2FE),
            route: '/kick-counter',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Birth Plan', lang),
            subtitle: 'Facility, bag & JSY/PMMVY',
            icon: Icons.assignment_turned_in_rounded,
            accentColor: const Color(0xFF7C3AED),
            containerColor: const Color(0xFFF3E8FF),
            route: '/birth-plan',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Doctor Summary', lang),
            subtitle: 'One-page PDF & talking points',
            icon: Icons.picture_as_pdf_rounded,
            accentColor: const Color(0xFF0F766E),
            containerColor: const Color(0xFFCCFBF1),
            route: '/doctor-summary',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Danger Signs', lang),
            subtitle: AppStrings.t('Critical triage & 108 dispatch', lang),
            icon: Icons.warning_amber_rounded,
            accentColor: const Color(0xFFDC2626),
            containerColor: const Color(0xFFFEE2E2),
            route: '/danger-signs',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Vitals Log', lang),
            subtitle: AppStrings.t('Track BP & weight metrics', lang),
            icon: Icons.monitor_heart,
            accentColor: const Color(0xFF0D9488),
            containerColor: const Color(0xFFCCFBF1),
            route: '/vitals',
          ),
        ];

      case PreNestMode.postpartum:
        return [
          ModeShortcutItem(
            title: AppStrings.t('Postpartum Care', lang),
            subtitle: 'EPDS, Recovery & UIP',
            icon: Icons.favorite_rounded,
            accentColor: const Color(0xFFD97706),
            containerColor: const Color(0xFFFEF3C7),
            route: '/postpartum',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Symptom Checker', lang),
            subtitle: 'Recovery discomforts & red flags',
            icon: Icons.health_and_safety_rounded,
            accentColor: const Color(0xFFD97706),
            containerColor: const Color(0xFFFEF3C7),
            route: '/symptom-checker',
          ),
          const ModeShortcutItem(
            title: 'Articles & Guides',
            subtitle: 'Evidence-based library',
            icon: Icons.menu_book_rounded,
            accentColor: Color(0xFF0F766E),
            containerColor: Color(0xFFCCFBF1),
            route: '/guides',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Doctor Summary', lang),
            subtitle: 'One-page PDF & talking points',
            icon: Icons.picture_as_pdf_rounded,
            accentColor: const Color(0xFF0F766E),
            containerColor: const Color(0xFFCCFBF1),
            route: '/doctor-summary',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Danger Signs', lang),
            subtitle: 'Postnatal red-flag signs',
            icon: Icons.warning_amber_rounded,
            accentColor: const Color(0xFFDC2626),
            containerColor: const Color(0xFFFEE2E2),
            route: '/danger-signs',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Vitals Log', lang),
            subtitle: 'Maternal recovery vitals',
            icon: Icons.monitor_heart,
            accentColor: const Color(0xFF0F766E),
            containerColor: const Color(0xFFCCFBF1),
            route: '/vitals',
          ),
          ModeShortcutItem(
            title: AppStrings.t('Records', lang),
            subtitle: 'Newborn UIP vaccines & card',
            icon: Icons.vaccines_rounded,
            accentColor: const Color(0xFF0284C7),
            containerColor: const Color(0xFFE0F2FE),
            route: '/records',
          ),
        ];
    }
  }

  static String _getPartnerSupportCue(PreNestMode mode) {
    switch (mode) {
      case PreNestMode.periodTracker:
        return 'Daily Partner Cue: Offer a warm soothing tea and extra emotional space today.';
      case PreNestMode.planningPregnancy:
        return 'Daily Partner Cue: Check in on shared hydration and folic acid habit streaks tonight.';
      case PreNestMode.pregnant:
        return 'Daily Partner Cue: Offer a gentle foot massage; baby is hearing outside voices now!';
      case PreNestMode.postpartum:
        return 'Daily Partner Cue: Take the next burping & soothing shift so she gets restful uninterrupted sleep.';
    }
  }

  static String _getGestationalMilestoneTitle(
    PreNestMode mode, [
    PostpartumState? postpartumState,
  ]) {
    switch (mode) {
      case PreNestMode.periodTracker:
        return 'Cycle Day 12';
      case PreNestMode.planningPregnancy:
        return 'Preconception Prep';
      case PreNestMode.pregnant:
        return '17 weeks, 1 day';
      case PreNestMode.postpartum:
        return postpartumState != null
            ? 'Postpartum Week ${postpartumState.postpartumWeek}'
            : 'Postpartum Week 3';
    }
  }

  static String _getGestationalMilestoneSubtitle(
    PreNestMode mode,
    ModeSelectionState modeState, [
    PostpartumState? postpartumState,
  ]) {
    switch (mode) {
      case PreNestMode.periodTracker:
        return modeState.irregularCycleMode
            ? 'Cycle Day 12 • Irregular Mode On'
            : 'Cycle Day 12 • Follicular Phase (~16 days left)';
      case PreNestMode.planningPregnancy:
        return 'Fertility Readiness & Micronutrient Baselines';
      case PreNestMode.pregnant:
        return 'Pregnancy Day 120 • Second Trimester';
      case PreNestMode.postpartum:
        return postpartumState != null
            ? 'Baby is ${postpartumState.babyAgeInDays} days old • ${postpartumState.birthType}'
            : 'Mother & Baby • Fourth Trimester Recovery';
    }
  }

  static Widget _getGestationalBadge(
    PreNestMode mode,
    Color stageColor, [
    PostpartumState? postpartumState,
  ]) {
    String emoji;
    String text;
    switch (mode) {
      case PreNestMode.periodTracker:
        emoji = '🌸';
        text = 'Cycle Day 12 • Follicular Window';
        break;
      case PreNestMode.planningPregnancy:
        emoji = '🌱';
        text = 'Preconception Baseline • Week 6';
        break;
      case PreNestMode.pregnant:
        emoji = '🍏';
        text = 'Baby is the size of an Apple (~13 cm)';
        break;
      case PreNestMode.postpartum:
        emoji = '👶';
        text = postpartumState != null
            ? postpartumState.babyAgeLabel
            : 'Postpartum Week 3 • Mother & Baby';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: stageColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stageColor.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: stageColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCalendarStrip(BuildContext context, Color stageColor) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 3 - i)));
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => context.push('/calendar'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 15,
                        color: stageColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${months[now.month - 1]} ${now.year}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: stageColor,
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () => context.push('/calendar'),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: stageColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: stageColor.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.expand_more_rounded,
                        size: 16,
                        color: stageColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Expand',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: stageColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isToday =
                  day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;
              final weekdayName = weekdays[day.weekday - 1];

              return InkWell(
                onTap: () => context.push('/calendar'),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isToday ? stageColor : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isToday ? stageColor : AppTheme.borderLight,
                      width: isToday ? 1.5 : 1,
                    ),
                    boxShadow: isToday
                        ? [
                            BoxShadow(
                              color: stageColor.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        weekdayName,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? Colors.white.withOpacity(0.9)
                              : AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(height: 3),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE7A8B6)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  size: 18,
                  color: Color(0xFF6D1D32),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Checkup today',
                    style: TextStyle(
                      color: Color(0xFF4B0F1E),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7D6DC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'DEMO',
                    style: TextStyle(
                      color: Color(0xFF6D1D32),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildJourneyStageTile({
    required WidgetRef ref,
    required PregnancyStage stage,
    required PregnancyStage selectedStage,
    required String label,
    required IconData icon,
  }) {
    final isSelected = stage == selectedStage;
    final accentColor = _getStageAccentColor(stage);
    final foregroundColor = isSelected ? Colors.white : const Color(0xFF6D1D32);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ref.read(stageProvider.notifier).setStage(stage);
          ref
              .read(modeSelectionProvider.notifier)
              .selectMode(PreNestMode.fromStage(stage));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : const Color(0xFFFFF1F4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? accentColor : const Color(0xFFE7A8B6),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: foregroundColor),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildCurrentJourneyCard({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeData theme,
    required PregnancyStage currentStage,
    required AppLanguage currentLang,
    required Color stageColor,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.route_rounded, size: 18, color: stageColor),
                const SizedBox(width: 8),
                Text(
                  'Current Journey',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4B0F1E),
                  ),
                ),
                const Spacer(),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => context.push('/onboarding/mode'),
                  child: const Text(
                    'Change Mode',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
              children: [
                _buildJourneyStageTile(
                  ref: ref,
                  stage: PregnancyStage.trying,
                  selectedStage: currentStage,
                  label: AppStrings.t('Trying', currentLang),
                  icon: Icons.water_drop_rounded,
                ),
                _buildJourneyStageTile(
                  ref: ref,
                  stage: PregnancyStage.plan,
                  selectedStage: currentStage,
                  label: AppStrings.t('Planning Pregnancy', currentLang),
                  icon: Icons.spa_rounded,
                ),
                _buildJourneyStageTile(
                  ref: ref,
                  stage: PregnancyStage.pregnancy,
                  selectedStage: currentStage,
                  label: AppStrings.t('Pregnancy', currentLang),
                  icon: Icons.child_care_rounded,
                ),
                _buildJourneyStageTile(
                  ref: ref,
                  stage: PregnancyStage.postpartum,
                  selectedStage: currentStage,
                  label: AppStrings.t('Postpartum', currentLang),
                  icon: Icons.family_restroom_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(coupleProvider);
    final currentStage = ref.watch(stageProvider);
    final currentLang = ref.watch(languageProvider);
    final lockState = ref.watch(privacySyncProvider);
    final entryState = ref.watch(entryProvider);
    final modeState = ref.watch(modeSelectionProvider);
    final activePartner = couple.activePartner;
    final otherPartner = couple.otherPartner;
    final checklistAsync = ref.watch(filteredChecklistProvider);
    final completedIds = ref.watch(completedChecklistProvider);
    final reminders = ref.watch(medicineRemindersProvider);
    final hintsState = ref.watch(coupleHintsProvider);
    final postpartumState = ref.watch(postpartumProvider);
    final baseTheme = Theme.of(context);
    final theme = baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: const Color(0xFF6D1D32),
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFF7D6DC),
        onPrimaryContainer: const Color(0xFF6D1D32),
        secondary: const Color(0xFFB23C59),
        secondaryContainer: const Color(0xFFF7D6DC),
        onSecondaryContainer: const Color(0xFF4B0F1E),
      ),
    );

    final activeMode = modeState.activeMode(currentStage);
    final stageColor = _getStageAccentColor(currentStage);
    final isPartner =
        activePartner.id == couple.secondaryPartner.id ||
        activePartner.role.toLowerCase() == 'him';
    final otherName = otherPartner.name.trim();
    final dashboardPairName = isPartner
        ? '${activePartner.name.trim()} & ${otherName.isNotEmpty ? otherName : 'Her'}'
        : (otherName.isNotEmpty
              ? '${activePartner.name.trim()} & $otherName'
              : activePartner.name.trim());

    // Checklist stats
    final checklistItems = checklistAsync.asData?.value ?? [];
    final totalChecklistCount = checklistItems.length;
    final completedChecklistCount = checklistItems
        .where((it) => completedIds.contains(it.id))
        .length;
    final checklistProgress = totalChecklistCount == 0
        ? 0.0
        : (completedChecklistCount / totalChecklistCount);

    // Medicine stats (respects partner data-sharing defaults and toggles)
    final partnerVisibleReminders = reminders.where((r) {
      if (!lockState.shareMedicineReminders &&
          r.partnerOwnerId != activePartner.id &&
          r.partnerOwnerId != 'all') {
        return false;
      }
      if (r.isSharedWithPartner) return true;
      if (r.partnerOwnerId == 'all') return true;
      return r.partnerOwnerId == activePartner.id;
    }).toList();

    final stageReminders = partnerVisibleReminders.where((r) {
      return r.stageScope == null || r.stageScope == currentStage;
    }).toList();

    final takenMedsCount = stageReminders.where((r) => r.takenToday).length;
    final totalMedsCount = stageReminders.length;
    final medProgress = totalMedsCount > 0
        ? (takenMedsCount / totalMedsCount)
        : 0.0;

    // Couple hints: cross-partner hints only appear when opted in
    final activeHint =
        (lockState.shareQuizPartnerHints ||
            hintsState.activeSmartHint?.fromPartnerId == activePartner.id)
        ? hintsState.activeSmartHint
        : null;
    final pendingCheckupsCount = hintsState.checkupReminders
        .where(
          (c) => !c.isCompleted && (c.stage == null || c.stage == currentStage),
        )
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA),
      body: Theme(
        data: theme,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // STEP 3: Compact Horizontal 7-Day Calendar Strip
                  _buildCalendarStrip(context, stageColor),
                  const SizedBox(height: 14),
                  _buildCurrentJourneyCard(
                    context: context,
                    ref: ref,
                    theme: theme,
                    currentStage: currentStage,
                    currentLang: currentLang,
                    stageColor: stageColor,
                  ),
                  const SizedBox(height: 14),

                  // STEP 3: Flo-Style Warm Gradient Hero Header
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: stageColor.withOpacity(0.3),
                        width: 1.2,
                      ),
                    ),
                    color: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            stageColor.withOpacity(0.18),
                            stageColor.withOpacity(0.04),
                            Colors.white,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Partner Profile & Partner Pairing Status Pill
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: stageColor,
                                foregroundColor: Colors.white,
                                child: Text(
                                  activePartner.initials,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          activePartner.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: stageColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            activePartner.role,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: stageColor,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        // Switch active partner button
                                        TextButton.icon(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                          onPressed: () {
                                            ref
                                                .read(coupleProvider.notifier)
                                                .togglePartner();
                                          },
                                          icon: const Icon(
                                            Icons.switch_account_outlined,
                                            size: 14,
                                          ),
                                          label: Text(
                                            couple.otherPartner.name,
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          _getStageIcon(currentStage),
                                          size: 14,
                                          color: stageColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            dashboardPairName,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: stageColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Gestational / Cycle Milestone Header
                          Text(
                            _getGestationalMilestoneTitle(
                              activeMode,
                              postpartumState,
                            ),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: stageColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _getGestationalMilestoneSubtitle(
                              activeMode,
                              modeState,
                              postpartumState,
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textDark.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Warm Milestone Visual Badge
                          _getGestationalBadge(
                            activeMode,
                            stageColor,
                            postpartumState,
                          ),

                          // Actionable Daily Partner Support Cue
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: stageColor.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline_rounded,
                                  size: 16,
                                  color: stageColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getPartnerSupportCue(activeMode),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark.withOpacity(
                                        0.85,
                                      ),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Partner Pairing Status Banner
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: entryState.isPaired
                                  ? const Color(0xFFF0FDF4)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: entryState.isPaired
                                    ? const Color(0xFFBBF7D0)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  entryState.isPaired
                                      ? Icons.favorite_rounded
                                      : Icons.person_outline_rounded,
                                  size: 16,
                                  color: entryState.isPaired
                                      ? const Color(0xFF16A34A)
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entryState.isPaired
                                        ? 'Paired with ${couple.otherPartner.name} (Code: ${entryState.partnerCode ?? "PN2026"}) • Sync Active'
                                        : 'Individual Mode • Tap to connect partner anytime',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: entryState.isPaired
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: entryState.isPaired
                                          ? const Color(0xFF15803D)
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                if (!entryState.isPaired)
                                  InkWell(
                                    onTap: () => context.push('/onboarding'),
                                    child: const Text(
                                      'Pair',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F766E),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Mode metadata / Milestone note / Irregular cycle indicator
                          if (modeState.timelineOrMilestoneNote != null &&
                              modeState
                                  .timelineOrMilestoneNote!
                                  .isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.bookmark_added_rounded,
                                  size: 14,
                                  color: stageColor,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    modeState.timelineOrMilestoneNote!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => context.push('/onboarding/mode'),
                                  child: const Text(
                                    'Edit Mode',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Irregular cycle mode indicator for Period Tracker
                          if (activeMode == PreNestMode.periodTracker &&
                              modeState.irregularCycleMode) ...[
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () => context.push('/cycle'),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE4E6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'PCOD/PCOS Irregular Cycle Mode Active • Tap for Cycle & PCOS Hub',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFBE123C),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 10,
                                      color: Color(0xFFBE123C),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 14),

                          // Checklist completion progress bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.t(
                                  'Stage Checklist Progress',
                                  currentLang,
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '$completedChecklistCount / $totalChecklistCount',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      completedChecklistCount ==
                                              totalChecklistCount &&
                                          totalChecklistCount > 0
                                      ? Colors.green.shade700
                                      : stageColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: checklistProgress,
                              minHeight: 8,
                              backgroundColor: theme.colorScheme.outlineVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                checklistProgress == 1.0
                                    ? Colors.green.shade600
                                    : stageColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Role-Badged Story Cards (You / Both / Her) for Partner Dashboard
                  if (isPartner) ...[
                    PartnerStoryCards(stage: currentStage, showHeader: true),
                    const SizedBox(height: 14),
                  ],

                  // Mood & State Professional Insights (Her & Partner views)
                  const MoodStateInsightCard(),
                  const SizedBox(height: 14),

                  // Articles & Guides Shortcut Tile
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.borderLight),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push('/guides'),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7D6DC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                color: Color(0xFF6D1D32),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Articles & Guides Library',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Text(
                                          'WHO • ICMR • MoHFW',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF15803D),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Indian nutrition, recovery, danger signs, PCOS & partner guides',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: AppTheme.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 13,
                              color: Color(0xFF6D1D32),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Cross-Mode Core Hub: Symptom Checker
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: const Color(0xFFE7A8B6),
                              width: 1.1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => context.push('/symptom-checker'),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7D6DC),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.health_and_safety_rounded,
                                      size: 18,
                                      color: Color(0xFF6D1D32),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Symptom Checker',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Discomforts vs red flags',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: AppTheme.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Mode 3 (Pregnancy) Dedicated Clinical Tools Quick-Access Cards
                  if (activeMode == PreNestMode.pregnant) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: const Color(0xFF0F766E).withOpacity(0.3),
                                width: 1.1,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.push('/anc-planner'),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFCCFBF1),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.event_note_rounded,
                                            size: 20,
                                            color: Color(0xFF0F766E),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFCCFBF1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Text(
                                            '4+ Visits',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F766E),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      AppStrings.t(
                                        'ANC Visit Planner',
                                        currentLang,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      '4 visits, scans & IFA/Calcium',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: const Color(0xFFE11D48).withOpacity(0.3),
                                width: 1.1,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.push('/contraction-timer'),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFE4E6),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.timer_outlined,
                                            size: 20,
                                            color: Color(0xFFE11D48),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFE4E6),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Text(
                                            '5-1-1 Rule',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFE11D48),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      AppStrings.t(
                                        'Contraction Timer',
                                        currentLang,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Labor timer & frequency cue',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 4. Medicine Reminders Dashboard Card
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: const Color(0xFF0F766E).withOpacity(0.3),
                        width: 1.2,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push('/reminders'),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCFBF1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.medication_rounded,
                                    size: 20,
                                    color: Color(0xFF0F766E),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.t(
                                          'Medicine Reminders',
                                          currentLang,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        'Shared doctor-advised schedule adherence',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        takenMedsCount == totalMedsCount &&
                                            totalMedsCount > 0
                                        ? const Color(0xFFDCFCE7)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$takenMedsCount of $totalMedsCount Taken',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          takenMedsCount == totalMedsCount &&
                                              totalMedsCount > 0
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFF0F766E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: medProgress,
                                minHeight: 6,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  medProgress == 1.0
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF0F766E),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'View full list & timings for ${activePartner.name} & ${otherPartner.name}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: Color(0xFF0F766E),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5. Couple Check-In & Smart Hints Dashboard Card
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: const Color(0xFFE11D48).withOpacity(0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE4E6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.volunteer_activism_rounded,
                                  size: 20,
                                  color: Color(0xFFE11D48),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.t(
                                        'Couple Quizzes',
                                        currentLang,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      pendingCheckupsCount > 0
                                          ? '$pendingCheckupsCount checkup & helping reminders pending'
                                          : 'All partner tasks up to date',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Active Smart Hint banner if present
                          if (activeHint != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFDA4AF),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.favorite_rounded,
                                    size: 16,
                                    color: Color(0xFFE11D48),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activeHint.fromPartnerId ==
                                                  activePartner.id
                                              ? 'Your Active Hint for ${otherPartner.name}:'
                                              : 'Gentle Hint from ${activeHint.fromPartnerName}:',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFBE123C),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          activeHint.hintText,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            height: 1.35,
                                            color: Color(0xFF881337),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline_rounded,
                                    size: 16,
                                    color: Color(0xFFE11D48),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Take a 1-min check-in to send ${otherPartner.name} an effortless care hint.',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Quick action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFBE123C),
                                    side: const BorderSide(
                                      color: Color(0xFFFDA4AF),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 8,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () =>
                                      context.push('/couple-quizzes'),
                                  icon: const Icon(
                                    Icons.quiz_outlined,
                                    size: 15,
                                  ),
                                  label: Text(
                                    AppStrings.t('Couple Quizzes', currentLang),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F766E),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 8,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () => context.push('/advisor'),
                                  icon: const Icon(
                                    Icons.support_agent_rounded,
                                    size: 15,
                                  ),
                                  label: Text(
                                    AppStrings.t('AI Advisor', currentLang),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 6. Media Vault & Security Hub Quick Access
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: const Color(0xFF0F766E).withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => context.push('/vault'),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFCCFBF1),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.photo_library_rounded,
                                          size: 20,
                                          color: Color(0xFF0F766E),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 12,
                                        color: Color(0xFF0F766E),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    AppStrings.t('Media Vault', currentLang),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Scans & Keepsakes',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: const Color(0xFF0284C7).withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => context.push('/privacy-sync'),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0F2FE),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.shield_outlined,
                                          size: 20,
                                          color: Color(0xFF0284C7),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 12,
                                        color: Color(0xFF0284C7),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    AppStrings.t('Privacy & Lock', currentLang),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'PIN & Offline Sync',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 7. Filtered Stage Checklist Section
                  checklistAsync.when(
                    data: (items) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${AppStrings.t(currentStage.displayName, currentLang)} ${AppStrings.t('Checklist', currentLang)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      completedChecklistCount ==
                                              totalChecklistCount &&
                                          totalChecklistCount > 0
                                      ? Colors.green.shade50
                                      : theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        completedChecklistCount ==
                                                totalChecklistCount &&
                                            totalChecklistCount > 0
                                        ? Colors.green.shade200
                                        : theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Text(
                                  '$completedChecklistCount / $totalChecklistCount',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        completedChecklistCount ==
                                                totalChecklistCount &&
                                            totalChecklistCount > 0
                                        ? Colors.green.shade700
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (items.isEmpty)
                            Card(
                              elevation: 0,
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(28.0),
                                child: Center(
                                  child: Text(
                                    'No checklist items configured for this stage and profile.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            )
                          else
                            ...items.map((item) {
                              final isDone = completedIds.contains(item.id);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isDone
                                        ? const Color(0xFFBBF7D0)
                                        : theme.colorScheme.outlineVariant,
                                    width: 1,
                                  ),
                                ),
                                color: isDone
                                    ? const Color(0xFFF0FDF4)
                                    : Colors.white,
                                child: CheckboxListTile(
                                  value: isDone,
                                  onChanged: (_) {
                                    ref
                                        .read(
                                          completedChecklistProvider.notifier,
                                        )
                                        .toggle(item.id);
                                  },
                                  activeColor: const Color(0xFF059669),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 4,
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            decoration: isDone
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: isDone
                                                ? const Color(0xFF64748B)
                                                : const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.volume_up_outlined,
                                          size: 20,
                                        ),
                                        tooltip: AppStrings.t(
                                          'Read aloud',
                                          currentLang,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () {
                                          ref
                                              .read(ttsServiceProvider)
                                              .speak(
                                                '${item.title}. ${item.description}',
                                                currentLang,
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      item.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDone
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                  secondary: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isDone
                                        ? const Color(0xFFDCFCE7)
                                        : theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                    child: Icon(
                                      isDone
                                          ? Icons.check
                                          : Icons.assignment_outlined,
                                      size: 18,
                                      color: isDone
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                ),
                              );
                            }),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Failed to load checklist: $err'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/advisor'),
        icon: const Icon(Icons.support_agent),
        label: Text(AppStrings.t('AI Advisor', currentLang)),
      ),
    );
  }
}
