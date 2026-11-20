import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/l10n/tts_service.dart';
import '../couple/couple_hints_provider.dart';
import '../onboarding/entry_state.dart';
import '../onboarding/mode_selection_state.dart';
import '../profile/profile_provider.dart';
import '../reminders/medicine_reminders_provider.dart';
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
        return const Color(0xFF0F766E); // Teal
      case PregnancyStage.trying:
        return const Color(0xFFE11D48); // Rose
      case PregnancyStage.pregnancy:
        return const Color(0xFF0284C7); // Sky
      case PregnancyStage.postpartum:
        return const Color(0xFFD97706); // Amber
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
            accentColor: const Color(0xFF0F766E),
            containerColor: const Color(0xFFCCFBF1),
            route: '/vitals',
          ),
        ];

      case PreNestMode.postpartum:
        return [
          ModeShortcutItem(
            title: AppStrings.t('Postpartum Care', lang),
            subtitle: 'EPDS (Tele-MANAS) & UIP',
            icon: Icons.favorite_rounded,
            accentColor: const Color(0xFFD97706),
            containerColor: const Color(0xFFFEF3C7),
            route: '/postpartum',
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(coupleProvider);
    final currentStage = ref.watch(stageProvider);
    final currentLang = ref.watch(languageProvider);
    final entryState = ref.watch(entryProvider);
    final modeState = ref.watch(modeSelectionProvider);
    final activePartner = couple.activePartner;
    final otherPartner = couple.otherPartner;
    final checklistAsync = ref.watch(filteredChecklistProvider);
    final completedIds = ref.watch(completedChecklistProvider);
    final reminders = ref.watch(medicineRemindersProvider);
    final hintsState = ref.watch(coupleHintsProvider);
    final theme = Theme.of(context);

    final activeMode = modeState.activeMode(currentStage);
    final stageColor = _getStageAccentColor(currentStage);

    // Checklist stats
    final checklistItems = checklistAsync.asData?.value ?? [];
    final totalChecklistCount = checklistItems.length;
    final completedChecklistCount = checklistItems
        .where((it) => completedIds.contains(it.id))
        .length;
    final checklistProgress = totalChecklistCount == 0
        ? 0.0
        : (completedChecklistCount / totalChecklistCount);

    // Medicine stats
    final partnerVisibleReminders = reminders.where((r) {
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

    // Couple hints & checkup stats
    final activeHint = hintsState.activeSmartHint;
    final pendingCheckupsCount = hintsState.checkupReminders
        .where(
          (c) => !c.isCompleted && (c.stage == null || c.stage == currentStage),
        )
        .length;

    final shortcuts = _getShortcutsForMode(activeMode, currentLang);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Welcoming Hero & Active Mode Summary Card
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
                        colors: [stageColor.withOpacity(0.08), Colors.white],
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
                                          visualDensity: VisualDensity.compact,
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
                                          style: const TextStyle(fontSize: 11),
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
                                          '${activeMode.title} • ${couple.coupleName}',
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
                            modeState.timelineOrMilestoneNote!.isNotEmpty) ...[
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

                // 2. Stage Switcher Segmented Button
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.swap_horiz, size: 18, color: stageColor),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.t('Active Journey Stage', currentLang),
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
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
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<PregnancyStage>(
                            segments: [
                              ButtonSegment(
                                value: PregnancyStage.trying,
                                label: Text(
                                  AppStrings.t('Trying', currentLang),
                                ),
                                icon: const Icon(
                                  Icons.water_drop_outlined,
                                  size: 16,
                                ),
                              ),
                              ButtonSegment(
                                value: PregnancyStage.plan,
                                label: Text(AppStrings.t('Plan', currentLang)),
                                icon: const Icon(Icons.spa_outlined, size: 16),
                              ),
                              ButtonSegment(
                                value: PregnancyStage.pregnancy,
                                label: Text(
                                  AppStrings.t('Pregnancy', currentLang),
                                ),
                                icon: const Icon(
                                  Icons.child_care_outlined,
                                  size: 16,
                                ),
                              ),
                              ButtonSegment(
                                value: PregnancyStage.postpartum,
                                label: Text(
                                  AppStrings.t('Postpartum', currentLang),
                                ),
                                icon: const Icon(
                                  Icons.family_restroom_outlined,
                                  size: 16,
                                ),
                              ),
                            ],
                            selected: {currentStage},
                            onSelectionChanged: (newSelection) {
                              final selected = newSelection.first;
                              ref
                                  .read(stageProvider.notifier)
                                  .setStage(selected);
                              ref
                                  .read(modeSelectionProvider.notifier)
                                  .selectMode(PreNestMode.fromStage(selected));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Mode-Specific Quick Access Shortcuts (2x2 Grid)
                Row(
                  children: [
                    Expanded(
                      child: _buildShortcutCard(
                        context: context,
                        item: shortcuts[0],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildShortcutCard(
                        context: context,
                        item: shortcuts[1],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildShortcutCard(
                        context: context,
                        item: shortcuts[2],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildShortcutCard(
                        context: context,
                        item: shortcuts[3],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Medicine & Supplement Reminders',
                                      style: TextStyle(
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
                                  const Text(
                                    'Couple Check-In & Smart Hints',
                                    style: TextStyle(
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
                                icon: const Icon(Icons.quiz_outlined, size: 15),
                                label: const Text(
                                  'Quizzes & Hints',
                                  style: TextStyle(
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
                                label: const Text(
                                  'Ask AI Advisor',
                                  style: TextStyle(
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
                const SizedBox(height: 20),

                // 6. Filtered Stage Checklist Section
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
                                    : theme.colorScheme.surfaceContainerHighest,
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
                                      .read(completedChecklistProvider.notifier)
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/advisor'),
        icon: const Icon(Icons.support_agent),
        label: Text(AppStrings.t('AI Advisor', currentLang)),
      ),
    );
  }

  Widget _buildShortcutCard({
    required BuildContext context,
    required ModeShortcutItem item,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(item.route),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.containerColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.accentColor.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.containerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: item.accentColor, size: 22),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 13,
                    color: item.accentColor,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: item.accentColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
