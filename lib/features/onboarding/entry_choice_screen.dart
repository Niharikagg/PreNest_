import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import 'entry_state.dart';

/// Calm, accessible Material 3 entry choice screen for PreNest.
/// Provides two guided paths:
/// 1. "For myself" -> navigates to /onboarding/mode
/// 2. "I have a partner code" -> expands 6-character input and connects to /timeline
class EntryChoiceScreen extends ConsumerStatefulWidget {
  const EntryChoiceScreen({super.key});

  @override
  ConsumerState<EntryChoiceScreen> createState() => _EntryChoiceScreenState();
}

class _EntryChoiceScreenState extends ConsumerState<EntryChoiceScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isPartnerCodeExpanded = false;
  String? _localError;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onSelectForMyself() {
    ref.read(entryProvider.notifier).selectForMyself();
    context.go('/onboarding/mode');
  }

  void _togglePartnerCode() {
    setState(() {
      _isPartnerCodeExpanded = !_isPartnerCodeExpanded;
      _localError = null;
    });
  }

  void _onConnectPartner() {
    final rawInput = _codeController.text.trim();
    if (rawInput.isEmpty) {
      setState(() {
        _localError = 'Please enter your 6-character partner code.';
      });
      return;
    }

    final success = ref.read(entryProvider.notifier).pairWithCode(rawInput);
    if (success) {
      setState(() {
        _localError = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connected to partner profile successfully!'),
          backgroundColor: AppTheme.successGreen,
          duration: Duration(seconds: 2),
        ),
      );
      context.go('/onboarding/partner-intake');
    } else {
      final notifierError = ref.read(entryProvider).errorMessage;
      setState(() {
        _localError = notifierError ?? 'Code must be exactly 6 characters.';
      });
    }
  }

  void _fillSampleCode() {
    final activeCode = ref.read(entryProvider).generatedInviteCode ?? 'PN2026';
    _codeController.text = activeCode;
    setState(() {
      _localError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = ref.watch(entryProvider);
    final displayError = _localError ?? entry.errorMessage;

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

                  // Brand & Welcome Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 36,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to PreNest',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Empowering maternal & family health through each milestone. How would you like to begin your setup today?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMuted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Choice 1: "For myself"
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: entry.choice == SetupChoice.forMyself
                            ? theme.colorScheme.primary
                            : AppTheme.borderLight,
                        width: entry.choice == SetupChoice.forMyself ? 2 : 1,
                      ),
                    ),
                    color: Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _onSelectForMyself,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer
                                    .withOpacity(0.7),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                color: theme.colorScheme.primary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'For myself',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17,
                                            ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Choose your stage and set up your personal and couple journey.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textMuted,
                                      height: 1.35,
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
                  const SizedBox(height: 16),

                  // Choice 2: "I have a partner code"
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color:
                            (_isPartnerCodeExpanded ||
                                entry.choice == SetupChoice.partnerCode)
                            ? theme.colorScheme.secondary
                            : AppTheme.borderLight,
                        width:
                            (_isPartnerCodeExpanded ||
                                entry.choice == SetupChoice.partnerCode)
                            ? 2
                            : 1,
                      ),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _togglePartnerCode,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondaryContainer
                                        .withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.group_add_rounded,
                                    color: theme.colorScheme.secondary,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'I have a partner code',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 17,
                                                ),
                                          ),
                                          const Spacer(),
                                          AnimatedRotation(
                                            turns: _isPartnerCodeExpanded
                                                ? 0.5
                                                : 0.0,
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child: Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              size: 22,
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Link to your partner's profile with a 6-character code and automatically sync to her current stage.",
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: AppTheme.textMuted,
                                              height: 1.35,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Expandable 6-character code entry section
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 250),
                            crossFadeState: _isPartnerCodeExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            firstChild: const SizedBox.shrink(),
                            secondChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 20),
                                const Divider(color: AppTheme.borderLight),
                                const SizedBox(height: 16),
                                Text(
                                  'Enter 6-character partner code',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _codeController,
                                  maxLength: 6,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 6,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'e.g. PN2026',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 16,
                                      letterSpacing: 2,
                                    ),
                                    counterText: '',
                                    prefixIcon: const Icon(Icons.key_rounded),
                                    suffixIcon: _codeController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.clear,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              _codeController.clear();
                                              setState(() {
                                                _localError = null;
                                              });
                                            },
                                          )
                                        : null,
                                  ),
                                  onChanged: (_) {
                                    if (displayError != null) {
                                      setState(() {
                                        _localError = null;
                                      });
                                    }
                                  },
                                ),
                                if (displayError != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        size: 16,
                                        color: AppTheme.errorRed,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          displayError,
                                          style: const TextStyle(
                                            color: AppTheme.errorRed,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    ActionChip(
                                      avatar: const Icon(
                                        Icons.lightbulb_outline,
                                        size: 14,
                                      ),
                                      label: const Text(
                                        'Fill demo code: PN2026',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                      onPressed: _fillSampleCode,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        theme.colorScheme.secondary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _onConnectPartner,
                                  icon: const Icon(Icons.link_rounded),
                                  label: const Text(
                                    'Connect to Partner',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 28),

                  // Subtle Share/Manage Pairing Code Action
                  Center(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryTeal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () => _showManageCodeBottomSheet(context),
                      icon: const Icon(Icons.share_outlined, size: 16),
                      label: const Text(
                        'Want to share your own code? Manage / Share Code',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtle Quick Testing Option
                  Center(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textMuted,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () => context.go('/timeline'),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text(
                        'Skip directly to Timeline (Quick Test)',
                        style: TextStyle(
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showManageCodeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final entry = ref.watch(entryProvider);
            final hasActiveCode =
                entry.inviteActive && entry.generatedInviteCode != null;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.borderLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTealLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            color: AppTheme.primaryTeal,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Your Partner Pairing Code',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Give this code to your partner to link up',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (hasActiveCode) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF99F6E4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Text(
                              entry.generatedInviteCode!,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 8,
                                color: AppTheme.primaryTealDark,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded),
                              color: AppTheme.primaryTeal,
                              tooltip: 'Copy Code',
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: entry.generatedInviteCode!,
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Code ${entry.generatedInviteCode} copied!',
                                    ),
                                    backgroundColor: AppTheme.primaryTeal,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Regenerate'),
                              onPressed: () {
                                ref
                                    .read(entryProvider.notifier)
                                    .generateInviteCode();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.errorRed,
                                side: const BorderSide(
                                  color: Color(0xFFFECDD3),
                                ),
                              ),
                              icon: const Icon(
                                Icons.link_off_rounded,
                                size: 16,
                              ),
                              label: const Text('Revoke'),
                              onPressed: () {
                                ref
                                    .read(entryProvider.notifier)
                                    .revokePairingCode();
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pairing code revoked.'),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const Text(
                        'No invite code is currently active. Generate one now to share with your partner.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.add_link_rounded),
                        label: const Text('Generate Code'),
                        onPressed: () {
                          ref.read(entryProvider.notifier).generateInviteCode();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
