import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../advisor/ai_provider.dart';
import '../profile/profile_provider.dart';
import '../security/vault_lock_provider.dart';
import '../stage/stage.dart';
import '../stage/stage_provider.dart';
import 'couple_hints_provider.dart';

/// Data representation for an individual role-badged story card.
class _StoryCardData {
  final String badgeText;
  final Color badgeBg;
  final Color badgeTextCol;
  final Color badgeBorder;
  final Color accentColor;
  final Color iconBg;
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  const _StoryCardData({
    required this.badgeText,
    required this.badgeBg,
    required this.badgeTextCol,
    required this.badgeBorder,
    required this.accentColor,
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });
}

/// A clean, reusable horizontal story card carousel for the PreNest partner dashboard.
///
/// Renders ~165×190px rounded story cards with role badge pills (`You`, `Both`, `Her`)
/// in distinct soft pastel containers, dynamically adapting to the active [PregnancyStage].
class PartnerStoryCards extends ConsumerWidget {
  final PregnancyStage? stage;
  final bool showHeader;
  final String? headerTitle;
  final EdgeInsetsGeometry padding;

  const PartnerStoryCards({
    super.key,
    this.stage,
    this.showHeader = true,
    this.headerTitle,
    this.padding = EdgeInsets.zero,
  });

  static IconData _getStageIcon(PregnancyStage stage) {
    switch (stage) {
      case PregnancyStage.trying:
        return Icons.water_drop_rounded;
      case PregnancyStage.plan:
        return Icons.spa_rounded;
      case PregnancyStage.pregnancy:
        return Icons.child_care_rounded;
      case PregnancyStage.postpartum:
        return Icons.family_restroom_rounded;
    }
  }

  static String _getStagePhaseTitle(PregnancyStage stage) {
    switch (stage) {
      case PregnancyStage.trying:
        return 'Period & Cycle Tracking (Follicular)';
      case PregnancyStage.plan:
        return 'Preconception Readiness';
      case PregnancyStage.pregnancy:
        return 'Second Trimester (Week 17)';
      case PregnancyStage.postpartum:
        return 'Fourth Trimester (Postnatal Recovery)';
    }
  }

  static String _getStagePhaseDescription(PregnancyStage stage) {
    switch (stage) {
      case PregnancyStage.trying:
        return 'Her cycle is currently in the follicular window. Energy levels are gentle; mutual comfort and nourishing meals help.';
      case PregnancyStage.plan:
        return 'Focusing on maternal and paternal nutritional baselines, daily folic acid/zinc habits, and lifestyle harmony.';
      case PregnancyStage.pregnancy:
        return 'Baby is growing actively. Focus on maternal hydration, restful sleep, and preparing together for clinical ANC milestones.';
      case PregnancyStage.postpartum:
        return 'Healing from delivery while caring for newborn. Sleep blocks, meal nutrition, and shared diaper/soothing shifts are essential.';
    }
  }

  static List<Widget> _buildSupportCues(PregnancyStage stage) {
    final List<
      ({IconData icon, Color color, Color bg, String title, String desc})
    >
    cues;

    switch (stage) {
      case PregnancyStage.trying:
        cues = const [
          (
            icon: Icons.coffee_rounded,
            color: Color(0xFFE11D48),
            bg: Color(0xFFFFE4E6),
            title: 'Comfort & Hydration',
            desc: 'Offer a warm caffeine-free herbal tea or soothing warm pack if she feels lower abdominal pressure.',
          ),
          (
            icon: Icons.restaurant_rounded,
            color: Color(0xFF0F766E),
            bg: Color(0xFFCCFBF1),
            title: 'Take Initiative on Meals',
            desc: 'Handle evening dinner prep and kitchen cleanup without waiting for her to ask.',
          ),
          (
            icon: Icons.nightlight_round,
            color: Color(0xFF0284C7),
            bg: Color(0xFFE0F2FE),
            title: 'Protect Calm Evening Time',
            desc: 'Keep evening plans relaxed and distraction-free so she can unwind and recharge.',
          ),
        ];
        break;

      case PregnancyStage.plan:
        cues = const [
          (
            icon: Icons.fitness_center_rounded,
            color: Color(0xFF0F766E),
            bg: Color(0xFFCCFBF1),
            title: 'Consistent Paternal Habits',
            desc: 'Stay true to your own sleep, hydration, and nutrition habits—paternal sperm health is 50% of the fertility journey.',
          ),
          (
            icon: Icons.directions_walk_rounded,
            color: Color(0xFF0284C7),
            bg: Color(0xFFE0F2FE),
            title: 'Screen-Free Decompression',
            desc: 'Invite her for a gentle 15–20 minute stroll after dinner to decompress and talk through shared hopes.',
          ),
          (
            icon: Icons.checklist_rounded,
            color: Color(0xFFE11D48),
            bg: Color(0xFFFFE4E6),
            title: 'Preconception Question Check',
            desc: 'Review doctor questions and shared preconception checklists together ahead of your next consultation.',
          ),
        ];
        break;

      case PregnancyStage.pregnancy:
        cues = const [
          (
            icon: Icons.spa_rounded,
            color: Color(0xFF0284C7),
            bg: Color(0xFFE0F2FE),
            title: 'Physical Relief & Gentle Rest',
            desc: 'Offer a gentle 10-minute foot or lower-back massage to ease postural strain and support circulation.',
          ),
          (
            icon: Icons.local_drink_rounded,
            color: Color(0xFF0F766E),
            bg: Color(0xFFCCFBF1),
            title: 'Hydration & Nutrient Refill',
            desc: 'Keep her water bottle filled and offer a protein-rich or iron-nourishing snack without being asked.',
          ),
          (
            icon: Icons.event_available_rounded,
            color: Color(0xFF7C3AED),
            bg: Color(0xFFF3E8FF),
            title: 'ANC & Clinic Logistics',
            desc: 'Review upcoming ANC milestone dates, hospital transport options, and have the scan folder organized.',
          ),
        ];
        break;

      case PregnancyStage.postpartum:
        cues = const [
          (
            icon: Icons.bedtime_rounded,
            color: Color(0xFFD97706),
            bg: Color(0xFFFEF3C7),
            title: 'Night Shift Ownership',
            desc: 'Take the next burping, soothing, or diaper change shift so she gets an unbroken 2–3 hour sleep block.',
          ),
          (
            icon: Icons.set_meal_rounded,
            color: Color(0xFF0F766E),
            bg: Color(0xFFCCFBF1),
            title: 'Hydration & Warm Meals',
            desc: 'Bring her tall glasses of water and nourishing warm meals while she nurses or rests in bed.',
          ),
          (
            icon: Icons.shield_outlined,
            color: Color(0xFFE11D48),
            bg: Color(0xFFFFE4E6),
            title: 'Gatekeep Visitor Energy',
            desc: 'Manage family phone calls and visitor boundaries kindly so her postnatal recovery space stays restful.',
          ),
        ];
        break;
    }

    return cues.map((cue) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cue.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(cue.icon, size: 18, color: cue.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cue.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    cue.desc,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  static void _showHerSupportModal({
    required BuildContext context,
    required WidgetRef ref,
    required PregnancyStage stage,
    required String herName,
    required SmartPartnerHint? activeHint,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(modalContext).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag handle pill
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Modal content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE4E6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Color(0xFFE11D48),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Support $herName Today',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.shield_outlined,
                                      size: 13,
                                      color: Color(0xFF0F766E),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Privacy-Safe • General Support Cues Only',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.of(modalContext).pop(),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Privacy-Safe Stage Snapshot Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getStageIcon(stage),
                                  size: 16,
                                  color: const Color(0xFF0F766E),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Stage: ${_getStagePhaseTitle(stage)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _getStagePhaseDescription(stage),
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.textMuted,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Opted-in Smart Hint (if active & non-raw)
                      if (activeHint != null &&
                          activeHint.hintText.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFDA4AF)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lightbulb_rounded,
                                size: 18,
                                color: Color(0xFFE11D48),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Gentle Care Hint from ${activeHint.fromPartnerName}:',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFBE123C),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      activeHint.hintText,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF881337),
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      // 2-3 Practical Empathetic Support Cues
                      const Text(
                        '3 Practical Ways to Support Her Today',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._buildSupportCues(stage),

                      const SizedBox(height: 16),

                      // Shortcut Button to PreNest AI Advisor
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(modalContext).pop();
                            context.push('/advisor');
                            ref
                                .read(chatProvider.notifier)
                                .sendMessage(
                                  'How can I support my partner today?',
                                );
                          },
                          icon: const Icon(
                            Icons.support_agent_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            'Ask AI Advisor: "How can I support my partner today?"',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static _StoryCardData _buildYouCard(
    BuildContext context,
    PregnancyStage stage,
  ) {
    const badgeBg = Color(0xFFCCFBF1);
    const badgeTextCol = Color(0xFF0F766E);
    const badgeBorder = Color(0xFF99F6E4);
    const accentColor = Color(0xFF0F766E);
    const iconBg = Color(0xFFCCFBF1);

    switch (stage) {
      case PregnancyStage.trying:
        return _StoryCardData(
          badgeText: 'You',
          badgeBg: badgeBg,
          badgeTextCol: badgeTextCol,
          badgeBorder: badgeBorder,
          accentColor: accentColor,
          iconBg: iconBg,
          icon: Icons.spa_rounded,
          title: 'Your Support Habit',
          subtitle: 'Quick daily check-in & learning about cycle comfort',
          actionLabel: 'Open Guides',
          onTap: () => context.push('/guides'),
        );
      case PregnancyStage.plan:
        return _StoryCardData(
          badgeText: 'You',
          badgeBg: badgeBg,
          badgeTextCol: badgeTextCol,
          badgeBorder: badgeBorder,
          accentColor: accentColor,
          iconBg: iconBg,
          icon: Icons.fitness_center_rounded,
          title: 'For Him: Daily Habits',
          subtitle:
              'Sleep, movement, cutting tobacco/alcohol & male fertility tips',
          actionLabel: 'View Habits',
          onTap: () => context.push('/planning'),
        );
      case PregnancyStage.pregnancy:
        return _StoryCardData(
          badgeText: 'You',
          badgeBg: badgeBg,
          badgeTextCol: badgeTextCol,
          badgeBorder: badgeBorder,
          accentColor: accentColor,
          iconBg: iconBg,
          icon: Icons.directions_car_filled_rounded,
          title: 'Your Partner Prep',
          subtitle: 'Transport, blood donor & ANC visit prep checklist',
          actionLabel: 'View Checklist',
          onTap: () => context.push('/birth-plan'),
        );
      case PregnancyStage.postpartum:
        return _StoryCardData(
          badgeText: 'You',
          badgeBg: badgeBg,
          badgeTextCol: badgeTextCol,
          badgeBorder: badgeBorder,
          accentColor: accentColor,
          iconBg: iconBg,
          icon: Icons.bedtime_rounded,
          title: 'Your Rest & Shifts',
          subtitle:
              'Taking a night/diaper shift & checking in on your own energy',
          actionLabel: 'Take Check-In',
          onTap: () => context.push('/couple-quizzes'),
        );
    }
  }

  static _StoryCardData _buildBothCard(
    BuildContext context,
    PregnancyStage stage,
  ) {
    const badgeBg = Color(0xFFE0F2FE);
    const badgeTextCol = Color(0xFF0369A1);
    const badgeBorder = Color(0xFFBAE6FD);
    const accentColor = Color(0xFF0284C7);
    const iconBg = Color(0xFFE0F2FE);

    switch (stage) {
      case PregnancyStage.trying:
        return _StoryCardData(
          badgeText: 'Both',
          badgeBg: badgeBg,
          badgeTextCol: badgeTextCol,
          badgeBorder: badgeBorder,
          accentColor: accentColor,
          iconBg: iconBg,
          icon: Icons.quiz_rounded,
          title: 'Couple Check-In Quiz',
          subtitle: 'Take a 2-tap check-in or myth-buster together',
          actionLabel: 'Start Quiz',
          onTap: () => context.push('/couple-quizzes'),
        );
      case PregnancyStage.plan:
        return _StoryCardData(
          badgeText: 'Both',
          badgeBg: badgeBg,
          badgeTextCol: badgeTextCol,
          badgeBorder: badgeBorder,
          accentColor: accentColor,
          iconBg: iconBg,
          icon: Icons.handshake_rounded,
          title: 'Shared Preconception Prep',
          subtitle: 'Review doctor questions & shared checklists together',
          actionLabel: 'Review Prep',
          onTap: () => context.push('/planning'),
        );
      case PregnancyStage.pregnancy:
        return _StoryCardData(
          badgeText: 'Both',
          badgeBg: badgeBg,
          badgeTextCol: badgeTextCol,
          badgeBorder: badgeBorder,
          accentColor: accentColor,
          iconBg: iconBg,
          icon: Icons.event_available_rounded,
          title: 'Next ANC & Questions',
          subtitle: 'Review upcoming visit milestones & birth plan together',
          actionLabel: 'ANC Planner',
          onTap: () => context.push('/anc-planner'),
        );
      case PregnancyStage.postpartum:
        return _StoryCardData(
          badgeText: 'Both',
          badgeBg: badgeBg,
          badgeTextCol: badgeTextCol,
          badgeBorder: badgeBorder,
          accentColor: accentColor,
          iconBg: iconBg,
          icon: Icons.vaccines_rounded,
          title: 'Newborn Vaccines & Care',
          subtitle: 'Track UIP vaccine dates & postnatal tasks together',
          actionLabel: 'Postpartum Hub',
          onTap: () => context.push('/postpartum'),
        );
    }
  }

  static _StoryCardData _buildHerCard({
    required BuildContext context,
    required WidgetRef ref,
    required PregnancyStage stage,
    required String herName,
    required SmartPartnerHint? activeHint,
  }) {
    const badgeBg = Color(0xFFFFE4E6);
    const badgeTextCol = Color(0xFFBE123C);
    const badgeBorder = Color(0xFFFECDD3);
    const accentColor = Color(0xFFE11D48);
    const iconBg = Color(0xFFFFE4E6);

    final String title = "$herName's Snapshot";
    final String subtitle;

    if (activeHint != null && activeHint.hintText.isNotEmpty) {
      subtitle = activeHint.hintText;
    } else {
      switch (stage) {
        case PregnancyStage.trying:
          subtitle = 'Cycle Day 12 • Follicular Phase: Gentle energy & comfort';
          break;
        case PregnancyStage.plan:
          subtitle =
              'Preconception Baselines: Mutual wellness & folic acid habits';
          break;
        case PregnancyStage.pregnancy:
          subtitle =
              'Week 17 • Second Trimester: Baby active; hydration & rest';
          break;
        case PregnancyStage.postpartum:
          subtitle =
              'Fourth Trimester Recovery: Healing, rest blocks & soothing';
          break;
      }
    }

    return _StoryCardData(
      badgeText: 'Her',
      badgeBg: badgeBg,
      badgeTextCol: badgeTextCol,
      badgeBorder: badgeBorder,
      accentColor: accentColor,
      iconBg: iconBg,
      icon: Icons.favorite_rounded,
      title: title,
      subtitle: subtitle,
      actionLabel: 'How to Support',
      onTap: () => _showHerSupportModal(
        context: context,
        ref: ref,
        stage: stage,
        herName: herName,
        activeHint: activeHint,
      ),
    );
  }

  Widget _buildCard(_StoryCardData card) {
    return InkWell(
      onTap: card.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 165,
        height: 190,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: card.accentColor.withOpacity(0.22),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: card.accentColor.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Corner Badge Pill on top-left, matching icon on top-right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: card.badgeBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: card.badgeBorder, width: 0.8),
                  ),
                  child: Text(
                    card.badgeText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: card.badgeTextCol,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: card.iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(card.icon, size: 16, color: card.accentColor),
                ),
              ],
            ),

            // Middle: Bold Title & 2-Line Subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  card.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    height: 1.25,
                  ),
                ),
              ],
            ),

            // Bottom: Action Cue with Right Chevron
            Row(
              children: [
                Text(
                  card.actionLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: card.accentColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: card.accentColor,
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
    final activeStage = stage ?? ref.watch(stageProvider);
    final couple = ref.watch(coupleProvider);
    final hintsState = ref.watch(coupleHintsProvider);
    final lockState = ref.watch(vaultLockProvider);

    // Her name from primary partner
    final herName = couple.primaryPartner.name;

    // Check privacy-safe smart hint: Opted-in smart hint if active & shared
    final activeHint =
        (lockState.shareQuizPartnerHints ||
            hintsState.activeSmartHint?.fromPartnerId ==
                couple.primaryPartner.id)
        ? hintsState.activeSmartHint
        : null;

    final cards = [
      _buildYouCard(context, activeStage),
      _buildBothCard(context, activeStage),
      _buildHerCard(
        context: context,
        ref: ref,
        stage: activeStage,
        herName: herName,
        activeHint: activeHint,
      ),
    ];

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFBF1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.people_alt_rounded,
                          size: 15,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        headerTitle ?? 'For You, Both & Her',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Swipe cards',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: cards.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _buildCard(cards[index]),
            ),
          ),
        ],
      ),
    );
  }
}
