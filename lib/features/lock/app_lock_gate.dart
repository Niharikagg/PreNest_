import 'package:flutter/material.dart';
import '../../core/security/app_security_service.dart';
import 'auto_lock_controller.dart';
import 'lock_screen.dart';
import 'privacy_shield.dart';

/// Top-level application gate that controls access based on [AppSecurityService.isUnlocked].
///
/// Wraps the child in:
/// 1. [PrivacyShield] to blank the screen in the task switcher.
/// 2. [Listener] to reset inactivity timeout on touch.
/// 3. [AnimatedSwitcher] between [LockScreen] and [child].
class AppLockGate extends StatefulWidget {
  final Widget child;
  final AppSecurityService securityService;
  final bool enablePrivacyShield;

  const AppLockGate({
    super.key,
    required this.child,
    required this.securityService,
    this.enablePrivacyShield = true,
  });

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> {
  late final AutoLockController _autoLockController;

  @override
  void initState() {
    super.initState();
    _autoLockController = AutoLockController(
      securityService: widget.securityService,
    );
    widget.securityService.addListener(_onSecurityStateChanged);
  }

  @override
  void dispose() {
    widget.securityService.removeListener(_onSecurityStateChanged);
    _autoLockController.dispose();
    super.dispose();
  }

  void _onSecurityStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrivacyShield(
      enableRecentsShield: widget.enablePrivacyShield,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => widget.securityService.recordActivity(),
        onPointerMove: (_) => widget.securityService.recordActivity(),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: widget.securityService.isUnlocked
              ? KeyedSubtree(
                  key: const ValueKey('unlocked_content'),
                  child: widget.child,
                )
              : KeyedSubtree(
                  key: const ValueKey('locked_screen'),
                  child: LockScreen(
                    securityService: widget.securityService,
                  ),
                ),
        ),
      ),
    );
  }
}
