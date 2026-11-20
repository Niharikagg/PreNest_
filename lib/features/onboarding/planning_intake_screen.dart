import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import 'mode_selection_state.dart';

/// Preconception intake screen triggered when selecting "Planning for Pregnancy"
/// on the journey mode selection screen.
/// Features warm, non-judgmental guidance and expandable "Why we're asking" disclosures.
class PlanningIntakeScreen extends ConsumerStatefulWidget {
  const PlanningIntakeScreen({super.key});

  @override
  ConsumerState<PlanningIntakeScreen> createState() =>
      _PlanningIntakeScreenState();
}

class _PlanningIntakeScreenState extends ConsumerState<PlanningIntakeScreen> {
  // Card 1: Timeline
  String _timelineChoice = 'Actively trying now';

  // Card 2: Folic Acid
  String _folicAcidChoice = 'Not yet';

  // Card 3: Doctor Checkup
  String _checkupChoice = 'Not yet';

  // Card 4: Cycle Regularity
  String _cycleChoice = 'Regular cycles (26–32 days)';

  // Expandable "Why we're asking" tracking
  final Set<int> _expandedWhyCards = {};

  void _toggleWhyAsking(int cardIndex) {
    setState(() {
      if (_expandedWhyCards.contains(cardIndex)) {
        _expandedWhyCards.remove(cardIndex);
      } else {
        _expandedWhyCards.add(cardIndex);
      }
    });
  }

  void _saveAndProceed() {
    // If cycle is irregular or PCOD, sync with mode selection provider
    if (_cycleChoice.contains('Irregular') || _cycleChoice.contains('PCOD')) {
      ref.read(modeSelectionProvider.notifier).setIrregularCycleMode(true);
    }

    final note = '$_timelineChoice • Folic acid: $_folicAcidChoice';
    ref.read(modeSelectionProvider.notifier).setMilestoneNote(note);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Planning preferences saved!'),
        backgroundColor: AppTheme.primaryTeal,
        duration: Duration(seconds: 2),
      ),
    );

    context.go('/onboarding/finale');
  }

  void _skipIntake() {
    context.go('/onboarding/finale');
  }

  Widget _buildWhyAskingWidget({
    required int cardIndex,
    required String explanation,
  }) {
    final isExpanded = _expandedWhyCards.contains(cardIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _toggleWhyAsking(cardIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: isExpanded ? AppTheme.primaryTeal : AppTheme.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  "Why we're asking",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isExpanded
                        ? AppTheme.primaryTeal
                        : AppTheme.textMuted,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dotted,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isExpanded
                        ? AppTheme.primaryTeal
                        : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: AppTheme.primaryTeal,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    explanation,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF334155),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/onboarding/mode');
            }
          },
        ),
        title: const Text(
          'Preconception Readiness',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _skipIntake,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Friendly Introduction Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryTeal.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryTealLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.spa_rounded,
                            color: AppTheme.primaryTeal,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Planning for Pregnancy',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTealDark,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Help us personalize your pre-pregnancy checklists, nutrition baselines, and doctor questions.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF0F766E),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CARD 1: Timeline & readiness
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: AppTheme.borderLight),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 20,
                                color: AppTheme.primaryTeal,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'What is your current timeline?',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ...[
                            'Actively trying now',
                            'Preparing 3–6 months ahead',
                          ].map((option) {
                            final isSelected = _timelineChoice == option;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () =>
                                    setState(() => _timelineChoice = option),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFF0FDFA)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryTeal
                                          : AppTheme.borderLight,
                                      width: isSelected ? 1.8 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        size: 18,
                                        color: isSelected
                                            ? AppTheme.primaryTeal
                                            : AppTheme.textMuted,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? AppTheme.primaryTealDark
                                                : AppTheme.textDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          _buildWhyAskingWidget(
                            cardIndex: 1,
                            explanation: "We're asking so we can adjust ovulation reminders, fertile window predictions, and nutrition timelines—never to rush you.",
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CARD 2: Folic acid check
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: AppTheme.borderLight),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.medication_rounded,
                                size: 20,
                                color: Color(0xFF0F766E),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Have you started daily Folic Acid (400 mcg)?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                [
                                  'Yes, taking daily',
                                  'Not yet',
                                  'Not sure',
                                ].map((option) {
                                  final isSelected = _folicAcidChoice == option;
                                  return ChoiceChip(
                                    label: Text(option),
                                    selected: isSelected,
                                    selectedColor: AppTheme.primaryTealLight,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? AppTheme.primaryTealDark
                                          : AppTheme.textDark,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: isSelected
                                            ? AppTheme.primaryTeal
                                            : AppTheme.borderLight,
                                      ),
                                    ),
                                    onSelected: (val) {
                                      if (val) {
                                        setState(
                                          () => _folicAcidChoice = option,
                                        );
                                      }
                                    },
                                  );
                                }).toList(),
                          ),

                          // Empathetic Inline Expansion for "No" or "Not yet"
                          if (_folicAcidChoice == 'Not yet' ||
                              _folicAcidChoice == 'Not sure') ...[
                            const SizedBox(height: 12),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFA7F3D0),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Icon(
                                    Icons.favorite_rounded,
                                    size: 18,
                                    color: Color(0xFF059669),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "That's completely okay! Starting now gives you a great head start—ask your doctor at your next visit about 400 mcg daily to support early neural tube development.",
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF065F46),
                                        height: 1.4,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 10),
                          _buildWhyAskingWidget(
                            cardIndex: 2,
                            explanation: "Folic acid is clinically recommended 1–3 months before conception. This helps us suggest gentle reminders and questions for your doctor.",
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CARD 3: Pre-pregnancy checkup
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: AppTheme.borderLight),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.health_and_safety_rounded,
                                size: 20,
                                color: Color(0xFF0284C7),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Pre-pregnancy checkup scheduled or done?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: ['Completed', 'Scheduled soon', 'Not yet']
                                .map((option) {
                                  final isSelected = _checkupChoice == option;
                                  return ChoiceChip(
                                    label: Text(option),
                                    selected: isSelected,
                                    selectedColor: const Color(0xFFE0F2FE),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF0369A1)
                                          : AppTheme.textDark,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: isSelected
                                            ? const Color(0xFF0284C7)
                                            : AppTheme.borderLight,
                                      ),
                                    ),
                                    onSelected: (val) {
                                      if (val) {
                                        setState(() => _checkupChoice = option);
                                      }
                                    },
                                  );
                                })
                                .toList(),
                          ),

                          // Empathetic Inline Expansion for "Not yet"
                          if (_checkupChoice == 'Not yet') ...[
                            const SizedBox(height: 12),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F9FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFBAE6FD),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Icon(
                                    Icons.thumb_up_alt_rounded,
                                    size: 18,
                                    color: Color(0xFF0284C7),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "That's completely okay! No need to rush. We've added a doctor-visit checklist with essential baseline tests (CBC, thyroid, rubella) you can review whenever you're ready.",
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF075985),
                                        height: 1.4,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 10),
                          _buildWhyAskingWidget(
                            cardIndex: 3,
                            explanation: "We're asking so we can tailor your checklists and doctor-visit questions—never to diagnose.",
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CARD 4: Cycle & health context
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: AppTheme.borderLight),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.water_drop_rounded,
                                size: 20,
                                color: AppTheme.warmRose,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Cycle Regularity & Health Context',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ...[
                            'Regular cycles (26–32 days)',
                            'Irregular or long cycles',
                            'PCOD/PCOS diagnosed',
                            'Unsure / Recently stopped birth control',
                          ].map((option) {
                            final isSelected = _cycleChoice == option;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () =>
                                    setState(() => _cycleChoice = option),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFFF1F2)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.warmRose
                                          : AppTheme.borderLight,
                                      width: isSelected ? 1.8 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        size: 18,
                                        color: isSelected
                                            ? AppTheme.warmRose
                                            : AppTheme.textMuted,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? AppTheme.warmRoseDark
                                                : AppTheme.textDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          _buildWhyAskingWidget(
                            cardIndex: 4,
                            explanation: "We use this to disable stressful 'late' alerts if your cycle varies and provide gentle hormonal health guidance.",
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bottom Action CTA
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: _saveAndProceed,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text(
                      'Complete Planning Setup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: _skipIntake,
                      child: const Text(
                        'Skip for now & continue',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
