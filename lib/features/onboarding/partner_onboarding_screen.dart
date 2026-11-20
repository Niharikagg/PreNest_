import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import 'entry_state.dart';

/// Clean 4-step partner-specific private intake flow shown when connecting
/// with a 6-character partner invite code.
class PartnerOnboardingScreen extends ConsumerStatefulWidget {
  const PartnerOnboardingScreen({super.key});

  @override
  ConsumerState<PartnerOnboardingScreen> createState() =>
      _PartnerOnboardingScreenState();
}

class _PartnerOnboardingScreenState
    extends ConsumerState<PartnerOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Age
  bool _ageConfirmed = true;
  String _selectedAgeRange = '25–29';

  // Step 2: Goals
  final Set<String> _selectedGoals = {
    'Share the responsibility',
    'Understand what she may be feeling',
  };

  // Step 3: Habits
  bool _sleep7Plus = true;
  bool _exerciseRegular = false;
  bool _caffeineModerate = true;
  bool _substanceAvoidance = true;

  // Step 4: Feelings
  final Set<String> _selectedFeelings = {'Excited', 'Ready to help'};

  final List<String> _ageRanges = const [
    '18–24',
    '25–29',
    '30–34',
    '35–39',
    '40+',
  ];

  final List<Map<String, dynamic>> _goalsList = const [
    {
      'label': 'Share the responsibility',
      'icon': Icons.handshake_rounded,
      'description': 'Active support with appointments, meals, and tasks',
    },
    {
      'label': 'Understand what she may be feeling',
      'icon': Icons.favorite_border_rounded,
      'description': 'Empathy for physical and hormonal changes',
    },
    {
      'label': 'Improve my own health',
      'icon': Icons.fitness_center_rounded,
      'description': 'Nutrition, fitness, and stress management',
    },
    {
      'label': 'Stay on top of checkups',
      'icon': Icons.calendar_today_rounded,
      'description': 'Never miss ANC visits, scans, and doctor dates',
    },
  ];

  final List<Map<String, dynamic>> _feelingsList = const [
    {
      'label': 'Excited',
      'icon': Icons.sentiment_very_satisfied_rounded,
      'color': AppTheme.successGreen,
    },
    {
      'label': 'A bit nervous',
      'icon': Icons.sentiment_neutral_rounded,
      'color': AppTheme.warningAmber,
    },
    {
      'label': 'Want to learn more',
      'icon': Icons.menu_book_rounded,
      'color': AppTheme.primaryTeal,
    },
    {
      'label': 'Ready to help',
      'icon': Icons.volunteer_activism_rounded,
      'color': AppTheme.warmRose,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _saveAndProceed() {
    final intake = PartnerIntakeData(
      ageConfirmed: _ageConfirmed,
      ageRange: _selectedAgeRange,
      goals: _selectedGoals.toList(),
      lifestyleHabits: {
        'regularSleep': _sleep7Plus,
        'regularExercise': _exerciseRegular,
        'moderateCaffeine': _caffeineModerate,
        'substanceAvoidance': _substanceAvoidance,
      },
      feelings: _selectedFeelings.toList(),
    );

    ref.read(entryProvider.notifier).savePartnerIntake(intake);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Partner preferences saved securely!'),
        backgroundColor: AppTheme.primaryTeal,
        duration: Duration(seconds: 2),
      ),
    );

    context.go('/onboarding/finale');
  }

  void _skipOnboarding() {
    final intake = PartnerIntakeData(
      ageConfirmed: true,
      ageRange: _selectedAgeRange,
      goals: _selectedGoals.toList(),
      lifestyleHabits: {
        'regularSleep': _sleep7Plus,
        'regularExercise': _exerciseRegular,
        'moderateCaffeine': _caffeineModerate,
        'substanceAvoidance': _substanceAvoidance,
      },
      feelings: _selectedFeelings.toList(),
    );

    ref.read(entryProvider.notifier).savePartnerIntake(intake);
    context.go('/onboarding/finale');
  }

  void _goToStep(int step) {
    if (step >= 0 && step < 4) {
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildPrivacyBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF99F6E4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppTheme.primaryTealLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              size: 18,
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "We won't share your private answers with your partner.",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTealDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your responses personalize only your private insights and guidance.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF0F766E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Age(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPrivacyBanner(),
          Text(
            'Age Confirmation',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Confirming your eligibility ensures tailored partner health guidance.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppTheme.borderLight),
            ),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _ageConfirmed
                      ? AppTheme.primaryTealLight
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: _ageConfirmed
                      ? AppTheme.primaryTeal
                      : AppTheme.textMuted,
                  size: 20,
                ),
              ),
              title: const Text(
                'I confirm I am 18 years or older',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              subtitle: const Text(
                'PreNest is designed for adult partners & couples.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              value: _ageConfirmed,
              activeColor: AppTheme.primaryTeal,
              onChanged: (val) => setState(() => _ageConfirmed = val),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select your age range:',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _ageRanges.map((range) {
              final isSelected = _selectedAgeRange == range;
              return ChoiceChip(
                label: Text(range),
                selected: isSelected,
                selectedColor: AppTheme.primaryTealLight,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppTheme.primaryTealDark
                      : AppTheme.textDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
                    setState(() => _selectedAgeRange = range);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Goals(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPrivacyBanner(),
          Text(
            'Your Partner Goals',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'What do you hope to focus on together? Select all that apply.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          ..._goalsList.map((goal) {
            final label = goal['label'] as String;
            final icon = goal['icon'] as IconData;
            final desc = goal['description'] as String;
            final isSelected = _selectedGoals.contains(label);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedGoals.remove(label);
                    } else {
                      _selectedGoals.add(label);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF0FDFA) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryTeal
                          : AppTheme.borderLight,
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryTealLight
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? AppTheme.primaryTeal
                              : AppTheme.textMuted,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppTheme.primaryTealDark
                                    : AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              desc,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: isSelected,
                        activeColor: AppTheme.primaryTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedGoals.add(label);
                            } else {
                              _selectedGoals.remove(label);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStep3Habits(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPrivacyBanner(),
          Text(
            'Private Lifestyle Habits',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your routine directly impacts energy, stress, and fertility.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppTheme.borderLight),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  secondary: const Icon(
                    Icons.bedtime_rounded,
                    color: Color(0xFF6366F1),
                  ),
                  title: const Text(
                    'Regular 7+ Hours Sleep',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Consistent sleep supports cortisol & stamina',
                    style: TextStyle(fontSize: 11.5),
                  ),
                  value: _sleep7Plus,
                  activeColor: AppTheme.primaryTeal,
                  onChanged: (val) => setState(() => _sleep7Plus = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  secondary: const Icon(
                    Icons.directions_run_rounded,
                    color: Color(0xFF059669),
                  ),
                  title: const Text(
                    'Active Exercise Routine',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Physical workouts or brisk walking 3+ days a week',
                    style: TextStyle(fontSize: 11.5),
                  ),
                  value: _exerciseRegular,
                  activeColor: AppTheme.primaryTeal,
                  onChanged: (val) => setState(() => _exerciseRegular = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  secondary: const Icon(
                    Icons.coffee_rounded,
                    color: Color(0xFFD97706),
                  ),
                  title: const Text(
                    'Moderate/High Caffeine Intake',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    '2 or more cups of coffee or caffeinated drinks daily',
                    style: TextStyle(fontSize: 11.5),
                  ),
                  value: _caffeineModerate,
                  activeColor: AppTheme.primaryTeal,
                  onChanged: (val) => setState(() => _caffeineModerate = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  secondary: const Icon(
                    Icons.smoke_free_rounded,
                    color: Color(0xFFE11D48),
                  ),
                  title: const Text(
                    'Alcohol & Smoking Avoidance',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Limiting or avoiding substances during family planning',
                    style: TextStyle(fontSize: 11.5),
                  ),
                  value: _substanceAvoidance,
                  activeColor: AppTheme.primaryTeal,
                  onChanged: (val) => setState(() => _substanceAvoidance = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Feelings(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPrivacyBanner(),
          Text(
            'How are you feeling?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your emotional baseline helps us pace hints and reminders warmly.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _feelingsList.map((item) {
              final label = item['label'] as String;
              final icon = item['icon'] as IconData;
              final color = item['color'] as Color;
              final isSelected = _selectedFeelings.contains(label);

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedFeelings.remove(label);
                    } else {
                      _selectedFeelings.add(label);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.12) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : AppTheme.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: color, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected ? color : AppTheme.textDark,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.check_rounded, color: color, size: 16),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: AppTheme.warmRose,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Remember: You are doing great. Being involved makes a tremendous clinical and emotional difference.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                      height: 1.4,
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
            if (_currentStep > 0) {
              _goToStep(_currentStep - 1);
            } else {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/onboarding');
              }
            }
          },
        ),
        title: Text(
          'Step ${_currentStep + 1} of 4',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _skipOnboarding,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            backgroundColor: AppTheme.borderLight,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryTeal,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (step) =>
                        setState(() => _currentStep = step),
                    children: [
                      _buildStep1Age(theme),
                      _buildStep2Goals(theme),
                      _buildStep3Habits(theme),
                      _buildStep4Feelings(theme),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: AppTheme.borderLight),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_currentStep > 0) ...[
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.borderLight),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _goToStep(_currentStep - 1),
                          child: const Text(
                            'Back',
                            style: TextStyle(color: AppTheme.textDark),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (_currentStep < 3) {
                              _goToStep(_currentStep + 1);
                            } else {
                              _saveAndProceed();
                            }
                          },
                          child: Text(
                            _currentStep < 3 ? 'Continue' : 'Finish Setup',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
