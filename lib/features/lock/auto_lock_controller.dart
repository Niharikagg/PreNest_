import 'dart:async';
import 'package:flutter/widgets.dart';
import '../../core/security/app_security_service.dart';

/// Manages lifecycle state observing and periodic inactivity checking for auto-locking.
class AutoLockController with WidgetsBindingObserver {
  final AppSecurityService securityService;
  final Duration checkInterval;

  Timer? _inactivityCheckTimer;
  bool _isDisposed = false;

  AutoLockController({
    required this.securityService,
    this.checkInterval = const Duration(seconds: 15),
  }) {
    WidgetsBinding.instance.addObserver(this);
    _startInactivityTimer();
  }

  void _startInactivityTimer() {
    _inactivityCheckTimer?.cancel();
    _inactivityCheckTimer = Timer.periodic(checkInterval, (_) {
      if (!_isDisposed) {
        securityService.checkInactivityTimeout();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Automatically lock when transitioning to background or inactive
        securityService.lock();
        break;
      case AppLifecycleState.resumed:
        // When resumed, verify lock state or check timeout
        securityService.checkInactivityTimeout();
        break;
      case AppLifecycleState.detached:
        securityService.lock();
        break;
    }
  }

  void dispose() {
    _isDisposed = true;
    _inactivityCheckTimer?.cancel();
    _inactivityCheckTimer = null;
    WidgetsBinding.instance.removeObserver(this);
  }
}
