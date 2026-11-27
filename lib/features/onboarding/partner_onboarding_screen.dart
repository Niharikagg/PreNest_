import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  static const _backgroundColor = Color(0xFFB23C59);
  static const _wine = Color(0xFF4B0F1E);
  static const _dark = Color(0xFF6D1D32);
  static const _deep = Color(0xFF8E2B44);
  static const _light = Color(0xFFF7D6DC);

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
      _codeError = rawCode.length != 6
          ? 'Partner code must be 6 characters.'
          : null;
    });

    if (_nameError != null || _codeError != null) {
      return;
    }

    // 1. Link session as the partner in coupleProvider
    ref
        .read(coupleProvider.notifier)
        .completeOnboardingWithPartnerCode(
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
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: _light,
          onPressed: () => context.go('/onboarding'),
        ),
        title: const Text(
          'PRENEST',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _light,
            letterSpacing: 1.8,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_backgroundColor, _deep],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -95,
              right: -85,
              width: 280,
              height: 280,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _light.withValues(alpha: 0.16),
                        _light.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -125,
              left: -100,
              width: 340,
              height: 340,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFF0A5B5).withValues(alpha: 0.15),
                        const Color(0xFFF0A5B5).withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: _wine.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _light.withValues(alpha: 0.35),
                              ),
                            ),
                            child: const Icon(
                              Icons.handshake_rounded,
                              color: _light,
                              size: 34,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Join Her Care Circle',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: _light,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter your name and the 6-character partner code '
                          'displayed on her PreNest home screen to link your '
                          'sessions.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: _light.withValues(alpha: 0.92),
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 27),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xE6F7D6DC),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _wine.withValues(alpha: 0.16),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildInputLabel('Your Name'),
                              TextField(
                                controller: _nameController,
                                autofocus: true,
                                textCapitalization: TextCapitalization.words,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _wine,
                                ),
                                decoration: _inputDecoration(
                                  hintText: 'e.g., Rohan',
                                  errorText: _nameError,
                                  prefixIcon: Icons.person_outline_rounded,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildInputLabel('6-Character Partner Code'),
                              TextField(
                                controller: _codeController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                textInputAction: TextInputAction.done,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(6),
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9]'),
                                  ),
                                ],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                  color: _wine,
                                ),
                                textAlign: TextAlign.center,
                                decoration: _inputDecoration(
                                  hintText: 'PNH8K2',
                                  errorText: _codeError,
                                  prefixIcon: Icons.vpn_key_outlined,
                                ),
                                onSubmitted: (_) => _onConnect(),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Use the six letters or numbers shown in her app.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _dark,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 24),
                              FilledButton(
                                onPressed: _onConnect,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _dark,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Connect & Enter Partner Dashboard',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: _light.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _deep.withValues(alpha: 0.18),
                                  ),
                                ),
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      size: 17,
                                      color: _deep,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Your partner can find her 6-character '
                                        'code at the top of her PreNest home screen.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _dark,
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                  ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: _dark,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required String? errorText,
    required IconData prefixIcon,
  }) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: _dark.withValues(alpha: 0.55),
        letterSpacing: 0,
      ),
      errorText: errorText,
      prefixIcon: Icon(prefixIcon, color: _deep),
      filled: true,
      fillColor: const Color(0xFFFFF9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      enabledBorder: border(const Color(0xFFD99AA8)),
      focusedBorder: border(_deep),
      errorBorder: border(Colors.red.shade700),
      focusedErrorBorder: border(Colors.red.shade700),
    );
  }
}
