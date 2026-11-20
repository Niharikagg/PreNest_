import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../profile/profile_provider.dart';
import '../stage/stage_provider.dart';
import 'entry_state.dart';
import 'mode_selection_state.dart';

/// Presentation data for the 2x2 stage grid cards.
class _StageCardInfo {
  final PreNestMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color containerColor;
  final Color borderColor;

  const _StageCardInfo({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.containerColor,
    required this.borderColor,
  });
}

/// Collect-first Onboarding setup flow for her ("For myself"):
/// 1. Her Name (text field)
/// 2. 2x2 Pastel Stage Grid (Period Tracker, Planning, Pregnant, Postpartum)
/// 3. Key Date Screen (Last Period Date / Due Date / Delivery Date) with DatePicker & "Skip for now"
/// 4. Generates a clean 6-character partner code (stored in her profile state) and routes to /timeline.
class ModeSelectScreen extends ConsumerStatefulWidget {
  const ModeSelectScreen({super.key});

  @override
  ConsumerState<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends ConsumerState<ModeSelectScreen> {
  int _currentStep = 0; // 0: Name, 1: Stage Grid, 2: Key Date
  final TextEditingController _nameController = TextEditingController();
  PreNestMode _selectedMode = PreNestMode.pregnant;
  DateTime? _selectedDate;
  String? _nameError;

  static const List<_StageCardInfo> _stageCards = [
    _StageCardInfo(
      mode: PreNestMode.periodTracker,
      title: 'Period Tracker',
      subtitle: 'Cycle, symptoms & PCOD/PCOS',
      icon: Icons.water_drop_rounded,
      accentColor: Color(0xFFE11D48), // Rose
      containerColor: Color(0xFFFFE4E6),
      borderColor: Color(0xFFFECDD3),
    ),
    _StageCardInfo(
      mode: PreNestMode.planningPregnancy,
      title: 'Planning for Pregnancy',
      subtitle: 'Preconception health & habits',
      icon: Icons.spa_rounded,
      accentColor: Color(0xFF0F766E), // Teal
      containerColor: Color(0xFFCCFBF1),
      borderColor: Color(0xFF99F6E4),
    ),
    _StageCardInfo(
      mode: PreNestMode.pregnant,
      title: 'Pregnant',
      subtitle: 'Week-by-week & ANC care',
      icon: Icons.child_care_rounded,
      accentColor: Color(0xFF0284C7), // Sky
      containerColor: Color(0xFFE0F2FE),
      borderColor: Color(0xFFBAE6FD),
    ),
    _StageCardInfo(
      mode: PreNestMode.postpartum,
      title: 'Postpartum',
      subtitle: 'Recovery & newborn milestones',
      icon: Icons.family_restroom_rounded,
      accentColor: Color(0xFFD97706), // Amber
      containerColor: Color(0xFFFEF3C7),
      borderColor: Color(0xFFFDE68A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Default estimated date to 20 weeks ahead for pregnancy, or 2 weeks ago for cycle
    _selectedDate = DateTime.now().add(const Duration(days: 140));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNameSubmitted() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = 'Please enter your name to personalize your care.';
      });
      return;
    }
    setState(() {
      _nameError = null;
      _currentStep = 1;
    });
  }

  void _onStageSelected(PreNestMode mode) {
    setState(() {
      _selectedMode = mode;
      // Adjust default suggested date
      switch (mode) {
        case PreNestMode.periodTracker:
          _selectedDate = DateTime.now().subtract(const Duration(days: 12));
          break;
        case PreNestMode.planningPregnancy:
          _selectedDate = DateTime.now().subtract(const Duration(days: 14));
          break;
        case PreNestMode.pregnant:
          _selectedDate = DateTime.now().add(const Duration(days: 140));
          break;
        case PreNestMode.postpartum:
          _selectedDate = DateTime.now().subtract(const Duration(days: 21));
          break;
      }
      _currentStep = 2;
    });
  }

  Future<void> _pickKeyDate() async {
    final now = DateTime.now();
    DateTime firstDate;
    DateTime lastDate;

    switch (_selectedMode) {
      case PreNestMode.periodTracker:
      case PreNestMode.planningPregnancy:
        firstDate = now.subtract(const Duration(days: 90));
        lastDate = now;
        break;
      case PreNestMode.pregnant:
        firstDate = now.subtract(const Duration(days: 280));
        lastDate = now.add(const Duration(days: 280));
        break;
      case PreNestMode.postpartum:
        firstDate = now.subtract(const Duration(days: 365));
        lastDate = now;
        break;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null &&
              _selectedDate!.isAfter(firstDate) &&
              _selectedDate!.isBefore(lastDate)
          ? _selectedDate!
          : now,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: _getDatePickerHelpText(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getDatePickerHelpText() {
    switch (_selectedMode) {
      case PreNestMode.periodTracker:
        return 'Select Last Period Date (LMP)';
      case PreNestMode.planningPregnancy:
        return 'Select Last Period or Target Date';
      case PreNestMode.pregnant:
        return 'Select Estimated Due Date (EDD)';
      case PreNestMode.postpartum:
        return 'Select Delivery Date';
    }
  }

  String _getKeyDateTitle() {
    switch (_selectedMode) {
      case PreNestMode.periodTracker:
        return 'When did your last period start?';
      case PreNestMode.planningPregnancy:
        return 'When was your last period or target start date?';
      case PreNestMode.pregnant:
        return 'What is your estimated due date (EDD)?';
      case PreNestMode.postpartum:
        return 'When was your baby delivered?';
    }
  }

  String _getKeyDateSubtitle() {
    switch (_selectedMode) {
      case PreNestMode.periodTracker:
        return 'Helps predict cycle rhythm, safe follicular window, and ovulatory timing without late alerts.';
      case PreNestMode.planningPregnancy:
        return 'Helps tailor preconception habit milestones, folic acid streaks, and baseline lab tracking.';
      case PreNestMode.pregnant:
        return 'Calculates week-by-week fetal growth, ANC scan windows, and trimester milestones.';
      case PreNestMode.postpartum:
        return 'Guides newborn immunization (UIP) dates, EPDS mood checkups, and maternal healing.';
    }
  }

  void _finishOnboarding({bool skipDate = false}) {
    final name = _nameController.text.trim();
    final effectiveDate = skipDate ? null : _selectedDate;

    // Generate clean 6-character partner code
    final partnerCode = CoupleNotifier.generate6CharPartnerCode();

    // 1. Save profile state
    ref.read(coupleProvider.notifier).completeOnboardingForSelf(
          name: name.isNotEmpty ? name : 'Friend',
          partnerCode: partnerCode,
          keyDate: effectiveDate,
        );

    // 2. Set mode and synchronized stage
    ref.read(modeSelectionProvider.notifier).selectMode(_selectedMode);
    ref.read(stageProvider.notifier).setStage(_selectedMode.stage);

    if (effectiveDate != null) {
      ref.read(modeSelectionProvider.notifier).setMilestoneNote(
            '${_selectedMode.title} • Date: ${_formatDate(effectiveDate)}',
          );
    }

    // 3. Update entry state invite code
    ref.read(entryProvider.notifier).generateInviteCode();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Welcome to PreNest, ${name.isNotEmpty ? name : "Friend"}! Partner Code: $partnerCode',
        ),
        backgroundColor: const Color(0xFF0F766E),
        duration: const Duration(seconds: 3),
      ),
    );

    // Route to /timeline
    context.go('/timeline');
  }

  String _formatDate(DateTime d) {
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.go('/onboarding');
            }
          },
        ),
        title: Text(
          'Step ${_currentStep + 1} of 3',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildCurrentStepContent(theme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent(ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildNameStep(theme);
      case 1:
        return _buildStageGridStep(theme);
      case 2:
      default:
        return _buildKeyDateStep(theme);
    }
  }

  // STEP 1: Ask for her Name
  Widget _buildNameStep(ThemeData theme) {
    return Column(
      key: const ValueKey('step_name'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFCCFBF1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.badge_rounded,
              color: Color(0xFF0F766E),
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'What should we call you?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your name personalizes your daily health timeline, clinical doctor summary, and care reminders.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 32),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your first name',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.normal,
                ),
                icon: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF0F766E),
                ),
                errorText: _nameError,
              ),
              onSubmitted: (_) => _onNameSubmitted(),
            ),
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: _onNameSubmitted,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 2: 2x2 Pastel Stage Grid
  Widget _buildStageGridStep(ThemeData theme) {
    final herName = _nameController.text.trim();

    return Column(
      key: const ValueKey('step_stage_grid'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'Hi $herName, select your journey',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'PreNest tailors its clinical guidance, vitals trackers, and checklists to your active stage.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 28),

        // 2x2 Pastel Stage Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.98,
          ),
          itemCount: _stageCards.length,
          itemBuilder: (context, index) {
            final card = _stageCards[index];
            final isSelected = _selectedMode == card.mode;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onStageSelected(card.mode),
                borderRadius: BorderRadius.circular(22),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? card.containerColor.withOpacity(0.4)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected ? card.accentColor : card.borderColor,
                      width: isSelected ? 2.2 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? card.accentColor.withOpacity(0.14)
                            : Colors.black.withOpacity(0.02),
                        blurRadius: isSelected ? 12 : 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: card.containerColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: card.borderColor,
                                width: 1.2,
                              ),
                            ),
                            child: Icon(
                              card.icon,
                              color: card.accentColor,
                              size: 24,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: card.accentColor,
                              size: 22,
                            )
                          else
                            Icon(
                              Icons.radio_button_unchecked_rounded,
                              color: Colors.grey.shade300,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? card.accentColor
                                  : const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            card.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isSelected
                                  ? card.accentColor.withOpacity(0.85)
                                  : const Color(0xFF64748B),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => _onStageSelected(_selectedMode),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Next with ${_selectedMode.title}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 3: Key Date Screen with DatePicker & "Skip for now"
  Widget _buildKeyDateStep(ThemeData theme) {
    final title = _getKeyDateTitle();
    final subtitle = _getKeyDateSubtitle();

    return Column(
      key: const ValueKey('step_key_date'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF0284C7),
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF64748B),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 32),

        // Interactive Date Display Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFBAE6FD), width: 1.5),
          ),
          color: const Color(0xFFF0F9FF),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _pickKeyDate,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: Color(0xFF0284C7),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Date',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedDate != null
                              ? _formatDate(_selectedDate!)
                              : 'Tap to select date',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.edit_calendar_rounded,
                    color: Color(0xFF0284C7),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Primary Action: Finish & Enter PreNest
        FilledButton(
          onPressed: () => _finishOnboarding(skipDate: false),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Complete Setup & Enter PreNest',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.check_rounded, size: 18),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Secondary Action: Skip for now
        TextButton(
          onPressed: () => _finishOnboarding(skipDate: true),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF64748B),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            'Skip for now',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
