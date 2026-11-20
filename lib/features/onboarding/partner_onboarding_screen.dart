import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../profile/profile_provider.dart';
import 'entry_state.dart';

/// Partner Login & Profile Link screen:
/// 1. Ask for his Name (text field)
/// 2. Ask for the 6-character partner code (text field, no stage selection)
/// 3. Link his session as partner, auto-sync to active stage/mode, and route to /timeline.
class PartnerOnboardingScreen extends ConsumerStatefulWidget {
  const PartnerOnboardingScreen({super.key});

  @override
  ConsumerState<PartnerOnboardingScreen> createState() =>
      _PartnerOnboardingScreenState();
}

class _PartnerOnboardingScreenState
    extends ConsumerState<PartnerOnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _nameError;
  String? _codeError;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onConnect() {
    final name = _nameController.text.trim();
    final rawCode = _codeController.text.trim().toUpperCase();

    setState(() {
      _nameError = name.isEmpty ? 'Please enter your name.' : null;
      _codeError =
          rawCode.length != 6 ? 'Partner code must be 6 characters.' : null;
    });

    if (_nameError != null || _codeError != null) {
      return;
    }

    // 1. Link session as the partner in coupleProvider
    ref.read(coupleProvider.notifier).completeOnboardingWithPartnerCode(
          partnerName: name,
          partnerCode: rawCode,
        );

    // 2. Link pairing status in entryProvider
    ref.read(entryProvider.notifier).pairWithCode(rawCode);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connected as partner ($name)! Syncing shared care...'),
        backgroundColor: const Color(0xFF15803D),
        duration: const Duration(seconds: 2),
      ),
    );

    // 3. Route to /timeline (showing partner-focused dashboard view)
    context.go('/timeline');
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
          onPressed: () => context.go('/onboarding'),
        ),
        title: const Text(
          'Partner Connect',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // Header Badge
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE4E6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.handshake_rounded,
                        color: Color(0xFFE11D48),
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title & Description
                  const Text(
                    'Join Her Care Circle',
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
                    'Enter your name and the 6-character partner code displayed on her PreNest home screen to link your sessions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Input 1: His Name
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      child: TextField(
                        controller: _nameController,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Your Name',
                          hintText: 'e.g., Rohan',
                          errorText: _nameError,
                          icon: const Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Input 2: 6-Character Partner Code
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      child: TextField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(6),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]'),
                          ),
                        ],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: '6-Character Partner Code',
                          hintText: 'e.g., PNH8K2',
                          errorText: _codeError,
                          icon: const Icon(
                            Icons.vpn_key_outlined,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                        onSubmitted: (_) => _onConnect(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Connect Button
                  FilledButton(
                    onPressed: _onConnect,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
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
                          'Connect & Enter Partner Dashboard',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Subtle Helper Tip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your partner can find her 6-character code at the top of her PreNest home screen.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              height: 1.35,
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
      ),
    );
  }
}
