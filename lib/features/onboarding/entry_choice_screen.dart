import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'entry_state.dart';

class EntryChoiceScreen extends ConsumerStatefulWidget {
  const EntryChoiceScreen({super.key});

  @override
  ConsumerState<EntryChoiceScreen> createState() => _EntryChoiceScreenState();
}

class _EntryChoiceScreenState extends ConsumerState<EntryChoiceScreen>
    with SingleTickerProviderStateMixin {
  static const _backgroundColor = Color(0xFFB23C59);
  static const _light = Color(0xFFF7D6DC);

  late final AnimationController _swayController;
  late final Animation<double> _sway;

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _sway = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _swayController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _swayController
        ..stop()
        ..value = 0.5;
    } else if (!_swayController.isAnimating) {
      _swayController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final appWidth = constraints.maxWidth.clamp(0.0, 450.0);
            final compact = appWidth <= 380;

            return Center(
              child: SizedBox(
                width: appWidth,
                height: constraints.maxHeight,
                child: ClipRect(
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: ColoredBox(color: _backgroundColor),
                      ),
                      Positioned(
                        right: -85,
                        bottom: -45,
                        width: 310,
                        child: AnimatedBuilder(
                          animation: _sway,
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: 0.62,
                              child: Image.asset(
                                'lib/features/onboarding/'
                                'Kağıt_Mürekkep_Baskı_Toner_Boya__boya__sıçrama__'
                                'Yaprak__Metin_png-removebg-preview.png',
                                fit: BoxFit.contain,
                                color: const Color(0xFF6D1D32),
                                colorBlendMode: BlendMode.srcIn,
                                excludeFromSemantics: true,
                              ),
                            ),
                          ),
                          builder: (context, child) => Transform.rotate(
                            angle: -_sway.value * 0.7,
                            alignment: Alignment.bottomCenter,
                            child: child,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -18,
                        bottom: -12,
                        width: 155,
                        child: AnimatedBuilder(
                          animation: _sway,
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: 0.82,
                              child: Image.asset(
                                'lib/features/onboarding/'
                                'Aesthetic_green_leaf_wallpaper-removebg-preview.png',
                                fit: BoxFit.contain,
                                color: const Color(0xFFE07A94),
                                colorBlendMode: BlendMode.srcIn,
                                excludeFromSemantics: true,
                              ),
                            ),
                          ),
                          builder: (context, child) => Transform.rotate(
                            angle: _sway.value,
                            alignment: Alignment.bottomCenter,
                            child: child,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                compact ? 25 : 31,
                                20,
                                compact ? 25 : 31,
                                24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Center(child: _PrenestLogo()),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Welcome to PreNest',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _light,
                                      fontSize: compact ? 25 : 28,
                                      height: 1.2,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.7,
                                    ),
                                  ),
                                  SizedBox(height: compact ? 14 : 17),
                                  Text(
                                    'Your warm, clinical companion for cycle health, '
                                    'fertility, pregnancy milestones, and postpartum '
                                    'recovery.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _light,
                                      fontSize: compact ? 14 : 15.5,
                                      height: 1.55,
                                    ),
                                  ),
                                  SizedBox(height: compact ? 24 : 29),
                                  _ChoiceCard(
                                    badge: 'Her Setup',
                                    symbolAlignment: Alignment.centerRight,
                                    symbolOffset: 3.5,
                                    symbolColor: const Color(0xFFE07A94),
                                    description:
                                        'Set up your personal journey, select '
                                        'your active health stage, and track '
                                        'key dates.',
                                    onTap: () {
                                      ref
                                          .read(entryProvider.notifier)
                                          .selectForMyself();
                                      context.go('/onboarding/mode');
                                    },
                                  ),
                                  SizedBox(height: compact ? 18 : 22),
                                  _ChoiceCard(
                                    badge: 'His Setup',
                                    symbolAlignment: Alignment.centerLeft,
                                    symbolOffset: -3.5,
                                    symbolColor: _light,
                                    description:
                                        'Connect to your partner’s profile '
                                        'with their 6-character code and join '
                                        'the shared care circle.',
                                    onTap: () {
                                      context.go('/onboarding/partner-intake');
                                    },
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PrenestLogo extends StatelessWidget {
  const _PrenestLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/features/onboarding/SmallSquareLogoJpg-removebg-preview.png',
      width: 160,
      height: 120,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      excludeFromSemantics: true,
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.badge,
    required this.symbolAlignment,
    required this.symbolOffset,
    required this.symbolColor,
    required this.description,
    required this.onTap,
  });

  final String badge;
  final Alignment symbolAlignment;
  final double symbolOffset;
  final Color symbolColor;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xBFF7D6DC),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 136),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(
                  color: Color(0xFF4B0F1E),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  // The source image's two figures are slightly off-center.
                  child: Transform.translate(
                    offset: Offset(symbolOffset, 0),
                    child: Transform.scale(
                      alignment: symbolAlignment,
                      scale: 2,
                      child: Image.asset(
                        'lib/features/onboarding/'
                        'Male_and_female_symbols____AFF___pink_blue_white_isolated__'
                        'Ad-removebg-preview.png',
                        width: 55,
                        height: 55,
                        fit: BoxFit.contain,
                        color: symbolColor,
                        colorBlendMode: BlendMode.srcIn,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE07A94),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Color(0xFF6D1D32),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          height: 1,
                        ),
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF6D1D32),
                        fontSize: 13.5,
                        height: 1.48,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Color(0xFF6D1D32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
