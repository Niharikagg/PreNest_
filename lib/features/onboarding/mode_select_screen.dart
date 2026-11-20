import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../stage/stage_provider.dart';
import 'mode_selection_state.dart';

/// Configuration data for each journey mode card.
class JourneyModeConfig {
  final PreNestMode mode;
  final String title;
  final String badge;
  final String description;
  final List<String> features;
  final IconData icon;
  final Color accentColor;
  final Color containerColor;
  final List<String> sampleNotes;
  final String notePlaceholder;

  const JourneyModeConfig({
    required this.mode,
    required this.title,
    required this.badge,
    required this.description,
    required this.features,
    required this.icon,
    required this.accentColor,
    required this.containerColor,
    required this.sampleNotes,
    required this.notePlaceholder,
  });
}

/// Enhanced Material 3 mode selection screen for PreNest at /onboarding/mode.
/// Displays clear cards for the 4 core modes:
/// 1. Period Tracker (PCOD/PCOS)
/// 2. Planning for Pregnancy
/// 3. Pregnant
/// 4. Postpartum
/// Includes mode-specific quick setup (e.g. irregular-cycle toggle, milestone notes)
/// and a primary action that saves state and navigates to /timeline.
class ModeSelectScreen extends ConsumerStatefulWidget {
  const ModeSelectScreen({super.key});

  @override
  ConsumerState<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends ConsumerState<ModeSelectScreen> {
  late PreNestMode _currentMode;
  late bool _irregularCycleMode;
  late TextEditingController _noteController;

  static const List<JourneyModeConfig> _configs = [
    JourneyModeConfig(
      mode: PreNestMode.periodTracker,
      title: 'Period Tracker (PCOD/PCOS)',
      badge: 'Cycle & Hormones',
      description: 'Cycle, flow, symptoms, irregular-cycle mode (no stressful "late" alerts), and PCOD/PCOS support.',
      features: [
        'Stress-free irregular cycle mode (no "late" alerts)',
        'Flow, ovulation window & basal temperature tracking',
        'PCOD/PCOS hormonal balance & symptom logging',
        'Cramps, mood, acne & lifestyle pattern insights',
      ],
      icon: Icons.water_drop_rounded,
      accentColor: Color(0xFFE11D48), // Rose
      containerColor: Color(0xFFFFE4E6),
      sampleNotes: [
        'Irregular cycle (35-45 days)',
        'PCOD diagnosed • Mild symptoms',
        'LMP: 2 weeks ago',
      ],
      notePlaceholder: 'e.g., Irregular 35-day cycle or last period date',
    ),
    JourneyModeConfig(
      mode: PreNestMode.planningPregnancy,
      title: 'Planning for Pregnancy',
      badge: 'Pre-Conception',
      description: 'Preconception prep & actively trying ("For Her" & "For Him" checklists, fertility & habit tracking).',
      features: [
        'Shared "For Her" & "For Him" preconception checklists',
        'Folic acid, micronutrients & preconception lab baselines',
        'Fertility window & ovulation readiness tracking',
        'Partner habit alignment & stress-reduction routines',
      ],
      icon: Icons.spa_rounded,
      accentColor: Color(0xFF0F766E), // Teal
      containerColor: Color(0xFFCCFBF1),
      sampleNotes: [
        'Actively trying (Month 2)',
        'Preconception prep & lab baselines',
        'Focus on folic acid & nutrition',
      ],
      notePlaceholder: 'e.g., Actively trying or pre-conception nutrition prep',
    ),
    JourneyModeConfig(
      mode: PreNestMode.pregnant,
      title: 'Pregnant',
      badge: 'Trimester Care',
      description: 'Week-by-week journey, ANC planner, Danger-Sign Checker (108), Vitals, Kick Counter & Birth Plan.',
      features: [
        'Week-by-week fetal development & clinical milestones',
        'ANC visit schedule & ultrasound scan tracker',
        'Danger-Sign Checker with immediate 108 emergency triage',
        'Maternal Vitals (BP, Weight), Kick Counter & Birth Plan',
      ],
      icon: Icons.child_care_rounded,
      accentColor: Color(0xFF0284C7), // Sky/Blue
      containerColor: Color(0xFFE0F2FE),
      sampleNotes: [
        'Week 16 (Second Trimester)',
        'Due Date: November 2026',
        'First-time pregnancy',
      ],
      notePlaceholder: 'e.g., Current week (e.g. W14) or Estimated Due Date',
    ),
    JourneyModeConfig(
      mode: PreNestMode.postpartum,
      title: 'Postpartum',
      badge: 'Fourth Trimester',
      description: 'Recovery checklist, EPDS mood check (Tele-MANAS 14416), newborn UIP vaccines & partner support.',
      features: [
        'Maternal healing checklist & postnatal warning signs',
        'EPDS mental wellness check & Tele-MANAS (14416) support',
        'Universal Immunization Programme (UIP) infant vaccines',
        'Partner postpartum care & feeding support logs',
      ],
      icon: Icons.family_restroom_rounded,
      accentColor: Color(0xFFD97706), // Amber
      containerColor: Color(0xFFFEF3C7),
      sampleNotes: [
        '3 weeks postpartum (Normal delivery)',
        'Baby 2 months old • UIP Vaccine due',
        'Focus on healing & emotional health',
      ],
      notePlaceholder:
          'e.g., Baby age (e.g. 4 weeks) or birth type/recovery note',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final modeState = ref.read(modeSelectionProvider);
    final currentStage = ref.read(stageProvider);
    _currentMode =
        modeState.selectedMode ?? PreNestMode.fromStage(currentStage);
    _irregularCycleMode = modeState.irregularCycleMode;
    _noteController = TextEditingController(
      text: modeState.timelineOrMilestoneNote ?? '',
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onSelectModeCard(PreNestMode mode) {
    setState(() {
      _currentMode = mode;
    });
  }

  void _saveAndProceed() {
    final notifier = ref.read(modeSelectionProvider.notifier);
    notifier.selectMode(_currentMode);
    notifier.setIrregularCycleMode(_irregularCycleMode);
    notifier.setMilestoneNote(_noteController.text);

    final selectedConfig = _configs.firstWhere(
      (cfg) => cfg.mode == _currentMode,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${selectedConfig.title}'),
        backgroundColor: selectedConfig.accentColor,
        duration: const Duration(seconds: 2),
      ),
    );

    if (_currentMode == PreNestMode.planningPregnancy) {
      context.go('/onboarding/planning-intake');
    } else {
      context.go('/onboarding/finale');
    }
  }

  Widget _buildModeGridCard(JourneyModeConfig config, BuildContext context) {
    final isSelected = _currentMode == config.mode;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onSelectModeCard(config.mode),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? config.containerColor.withOpacity(0.35)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? config.accentColor : AppTheme.borderLight,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: config.accentColor.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Soft Pastel Circular Icon Badge & Selection Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? config.accentColor
                          : config.containerColor,
                    ),
                    child: Icon(
                      config.icon,
                      size: 22,
                      color: isSelected ? Colors.white : config.accentColor,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? config.accentColor
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? config.accentColor
                            : AppTheme.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Mode Title
              Text(
                config.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  height: 1.25,
                  color: isSelected ? config.accentColor : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),

              // 1-Line Subtitle
              Text(
                config.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMuted,
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 10),

              // Badge Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? config.accentColor.withOpacity(0.15)
                      : config.containerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  config.badge,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: config.accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeConfig = _configs.firstWhere((cfg) => cfg.mode == _currentMode);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to entry options',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/onboarding');
            }
          },
        ),
        title: const Text(
          'Select Journey Mode',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header description
                  Text(
                    'Where are you right now?',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                      fontSize: 22,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose your active mode to personalize clinical checklists, danger sign alerts, and couple milestones.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // STEP 2: 2×2 Pastel Stage Grid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildModeGridCard(_configs[0], context)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildModeGridCard(_configs[1], context)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildModeGridCard(_configs[2], context)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildModeGridCard(_configs[3], context)),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Selected Mode Features Summary Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: activeConfig.containerColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: activeConfig.accentColor.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              activeConfig.icon,
                              size: 16,
                              color: activeConfig.accentColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Includes in ${activeConfig.title}:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: activeConfig.accentColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...activeConfig.features
                            .take(3)
                            .map(
                              (feat) => Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 14,
                                      color: activeConfig.accentColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        feat,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textDark,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick-Setup Options for Active Mode
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: activeConfig.accentColor.withOpacity(0.35),
                        width: 1.2,
                      ),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 20,
                                color: activeConfig.accentColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${activeConfig.title} Setup',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Mode-specific toggle: Irregular Cycle Mode for Period Tracker
                          if (_currentMode == PreNestMode.periodTracker) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFECDD3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Irregular Cycle Mode (PCOD/PCOS)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color(0xFF9F1239),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Suppresses stressful "late" alerts and uses flexible prediction windows.',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: Color(0xFF881337),
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _irregularCycleMode,
                                    activeColor: const Color(0xFFE11D48),
                                    onChanged: (val) {
                                      setState(() {
                                        _irregularCycleMode = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Milestone / Timeline Note Input
                          Text(
                            'Quick Note or Milestone (Optional)',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              hintText: activeConfig.notePlaceholder,
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                              prefixIcon: const Icon(
                                Icons.edit_calendar_rounded,
                                size: 20,
                              ),
                              suffixIcon: _noteController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _noteController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 10),

                          // Quick Sample Chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: activeConfig.sampleNotes.map((sample) {
                              return ActionChip(
                                avatar: const Icon(Icons.add_rounded, size: 14),
                                label: Text(
                                  sample,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                onPressed: () {
                                  _noteController.text = sample;
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Primary Action Button (Pill-shaped CTA)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: activeConfig.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                      elevation: 1,
                    ),
                    onPressed: _saveAndProceed,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text(
                      'Save & Continue to Timeline',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Skip / Continue without saving link
                  Center(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textMuted,
                      ),
                      onPressed: () => context.go('/timeline'),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text(
                        'Continue to Timeline without changing',
                        style: TextStyle(fontSize: 13),
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
