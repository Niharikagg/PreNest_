import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import 'entry_state.dart';

/// Clean, spacious Material 3 entry choice screen for PreNest.
/// Provides two guided paths:
/// 1. "For myself" -> leads to her setup flow (/onboarding/mode)
/// 2. "I have a partner code" -> leads to his partner login flow (/onboarding/partner-intake)
class EntryChoiceScreen extends ConsumerWidget {
  const EntryChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFB),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Brand & Welcome Icon Badge
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFFE4E6),
                            const Color(0xFFCCFBF1).withOpacity(0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE11D48).withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 34,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Greeting Title & Calming Tagline
                  Text(
                    'Welcome to PreNest',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.6,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your warm, clinical companion for cycle health, fertility, pregnancy milestones, and postpartum recovery.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 14.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Card 1: "For myself"
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(
                        color: Color(0xFFCCFBF1),
                        width: 1.5,
                      ),
                    ),
                    color: Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        ref.read(entryProvider.notifier).selectForMyself();
                        context.go('/onboarding/mode');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFBF1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF99F6E4),
                                  width: 1.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF0F766E),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'For myself',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          color: Color(0xFF0F172A),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE6FFFA),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Her Setup',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F766E),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Set up your personal journey, select your active health stage, and track key dates.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Color(0xFF0F766E),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Card 2: "I have a partner code"
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(
                        color: Color(0xFFFFE4E6),
                        width: 1.5,
                      ),
                    ),
                    color: Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        context.go('/onboarding/partner-intake');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE4E6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFECDD3),
                                  width: 1.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Color(0xFFE11D48),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'I have a partner code',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          color: Color(0xFF0F172A),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF1F2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Partner Link',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFE11D48),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Connect to her profile with her 6-character code to join the shared care circle.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Color(0xFFE11D48),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Privacy & Security Trust Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 16,
                          color: Color(0xFF0F766E),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '100% On-Device Data Storage • Private & Clinically Safe',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
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
      ),
    );
  }
}
