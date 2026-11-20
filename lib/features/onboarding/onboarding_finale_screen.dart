import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import 'entry_state.dart';
import 'mode_selection_state.dart';

/// Two-phase onboarding finale micro-interaction screen before entering /timeline:
/// Phase 1: Automated 3-step checklist animation (~2.5s) setting up the app.
/// Phase 2: Tactile "Tap and hold to start" interactive progress ring (~1.2s hold).
class OnboardingFinaleScreen extends ConsumerStatefulWidget {
  const OnboardingFinaleScreen({super.key});

  @override
  ConsumerState<OnboardingFinaleScreen> createState() =>
      _OnboardingFinaleScreenState();
}

class _OnboardingFinaleScreenState extends ConsumerState<OnboardingFinaleScreen>
    with TickerProviderStateMixin {
  // Phase 1: 3-step setup progress state
  bool _step1Done = false;
  bool _step2Done = false;
  bool _step3Done = false;
  bool _phase1Complete = false;

  // Phase 2: Tactile hold ring controller
  late AnimationController _holdController;
  bool _navigated = false;

  Timer? _t1;
  Timer? _t2;
  Timer? _t3;
  Timer? _tComplete;

  @override
  void initState() {
    super.initState();

    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_navigated) {
        _navigated = true;
        try {
          HapticFeedback.heavyImpact();
        } catch (_) {}
        if (mounted) {
          context.go('/timeline');
        }
      }
    });

    _startPhase1Animation();
  }

  void _startPhase1Animation() {
    _t1 = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _step1Done = true);
    });

    _t2 = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _step2Done = true);
    });

    _t3 = Timer(const Duration(milliseconds: 2300), () {
      if (mounted) setState(() => _step3Done = true);
    });

    _tComplete = Timer(const Duration(milliseconds: 2700), () {
      if (mounted) {
        setState(() => _phase1Complete = true);
        try {
          HapticFeedback.mediumImpact();
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _t1?.cancel();
    _t2?.cancel();
    _t3?.cancel();
    _tComplete?.cancel();
    _holdController.dispose();
    super.dispose();
  }

  void _startHolding() {
    if (_phase1Complete && !_navigated) {
      _holdController.forward();
      try {
        HapticFeedback.selectionClick();
      } catch (_) {}
    }
  }

  void _cancelHolding() {
    if (!_navigated && _holdController.status != AnimationStatus.completed) {
      _holdController.reverse();
    }
  }

  void _proceedDirectly() {
    if (!_navigated) {
      _navigated = true;
      context.go('/timeline');
    }
  }

  Widget _buildStepItem({
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isActive,
    required IconData icon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone
            ? const Color(0xFFF0FDF4)
            : (isActive ? Colors.white : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? const Color(0xFF86EFAC)
              : (isActive ? AppTheme.primaryTeal : AppTheme.borderLight),
          width: isDone || isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.primaryTeal.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDone
                  ? AppTheme.successGreen
                  : (isActive
                        ? AppTheme.primaryTealLight
                        : const Color(0xFFE2E8F0)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 22,
                    )
                  : (isActive
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryTeal,
                              ),
                            ),
                          )
                        : Icon(icon, color: AppTheme.textMuted, size: 18)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: isDone
                        ? const Color(0xFF14532D)
                        : (isActive ? AppTheme.textDark : AppTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDone
                        ? const Color(0xFF166534)
                        : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldRing() {
    return AnimatedBuilder(
      animation: _holdController,
      builder: (context, child) {
        final progress = _holdController.value;
        final isPressed = progress > 0.05;

        return Column(
          children: [
            GestureDetector(
              onTapDown: (_) => _startHolding(),
              onTapUp: (_) => _cancelHolding(),
              onTapCancel: _cancelHolding,
              onLongPressStart: (_) => _startHolding(),
              onLongPressEnd: (_) => _cancelHolding(),
              child: Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background Track Ring
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.borderLight.withOpacity(0.8),
                          ),
                        ),
                      ),

                      // Animated Filled Progress Ring
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 7,
                          strokeCap: StrokeCap.round,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryTeal,
                          ),
                        ),
                      ),

                      // Interactive Core Circle
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: isPressed ? 116 : 122,
                        height: isPressed ? 116 : 122,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isPressed
                                ? [
                                    AppTheme.primaryTeal,
                                    AppTheme.primaryTealDark,
                                  ]
                                : [
                                    const Color(0xFF0F766E),
                                    const Color(0xFF115E59),
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryTeal.withOpacity(
                                isPressed ? 0.45 : 0.25,
                              ),
                              blurRadius: isPressed ? 20 : 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isPressed
                                  ? Icons.favorite_rounded
                                  : Icons.touch_app_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isPressed
                                  ? '${(progress * 100).toInt()}%'
                                  : 'HOLD',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
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
            const SizedBox(height: 20),
            const Text(
              'Tap and hold to start',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hold for 1 second to step into your personalized PreNest care space.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 18),

            // Accessible Tap Fallback
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryTeal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onPressed: _proceedDirectly,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text(
                'Tap here to continue directly (Accessible)',
                style: TextStyle(
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = ref.watch(entryProvider);
    final mode = ref.watch(modeSelectionProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // Header Badge & Title
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryTealLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 32,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _phase1Complete
                        ? 'Your Space is Ready'
                        : 'Setting up your app...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _phase1Complete
                        ? 'Everything is personalized to your stage, clinical checklists, and couple sync rules.'
                        : 'Preparing evidence-based checklists and privacy safeguards.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 3 Automated Setup Steps
                  _buildStepItem(
                    title: 'Personalizing your stage & reminders',
                    subtitle: mode.selectedMode != null
                        ? '${mode.selectedMode!.title} mode initialized'
                        : 'Clinical schedule & milestones calibrated',
                    isDone: _step1Done,
                    isActive: !_step1Done,
                    icon: Icons.calendar_month_rounded,
                  ),
                  _buildStepItem(
                    title: 'Setting up couple privacy & sharing rules',
                    subtitle: entry.isPaired
                        ? 'Connected with partner code ${entry.partnerCode}'
                        : 'Local-first offline encryption safeguards engaged',
                    isDone: _step2Done,
                    isActive: _step1Done && !_step2Done,
                    icon: Icons.shield_rounded,
                  ),
                  _buildStepItem(
                    title: 'Preparing your daily insights',
                    subtitle: 'Evidence-based doctor checklists & emergency triage ready',
                    isDone: _step3Done,
                    isActive: _step2Done && !_step3Done,
                    icon: Icons.insights_rounded,
                  ),

                  const SizedBox(height: 28),

                  // Phase 2: Tactile Hold Ring
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 400),
                    crossFadeState: _phase1Complete
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryTeal,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Calibrating your timeline...',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    secondChild: _buildHoldRing(),
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
