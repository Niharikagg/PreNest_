import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prenest/core/security/app_security_service.dart';
import 'package:prenest/core/security/biometric_authenticator.dart';
import 'package:prenest/core/security/secure_key_storage.dart';
import 'package:prenest/features/lock/auto_lock_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutoLockController', () {
    late MockBiometricAuthenticator authenticator;
    late MemorySecureKeyStorage secureStorage;
    late AppSecurityService securityService;
    late AutoLockController controller;

    setUp(() async {
      authenticator = MockBiometricAuthenticator();
      secureStorage = MemorySecureKeyStorage();
      securityService = AppSecurityService(
        authenticator: authenticator,
        secureStorage: secureStorage,
      );
      await securityService.authenticate();
      expect(securityService.isUnlocked, isTrue);

      controller = AutoLockController(
        securityService: securityService,
        checkInterval: const Duration(seconds: 1),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('locks when app transitions to paused state (backgrounded)', () {
      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(securityService.isUnlocked, isFalse);
    });

    test('locks when app transitions to inactive state', () {
      controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
      expect(securityService.isUnlocked, isFalse);
    });

    test('locks when app transitions to hidden state', () {
      controller.didChangeAppLifecycleState(AppLifecycleState.hidden);
      expect(securityService.isUnlocked, isFalse);
    });
  });
}
