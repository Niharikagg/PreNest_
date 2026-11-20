import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prenest/core/security/app_security_service.dart';
import 'package:prenest/core/security/biometric_authenticator.dart';
import 'package:prenest/core/security/secure_key_storage.dart';
import 'package:prenest/features/lock/lock_screen.dart';

void main() {
  group('LockScreen Widget', () {
    late MockBiometricAuthenticator authenticator;
    late MemorySecureKeyStorage secureStorage;
    late AppSecurityService securityService;

    setUp(() {
      authenticator = MockBiometricAuthenticator(shouldSucceed: true);
      secureStorage = MemorySecureKeyStorage();
      securityService = AppSecurityService(
        authenticator: authenticator,
        secureStorage: secureStorage,
      );
    });

    testWidgets('renders lock screen branding and unlock button', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: LockScreen(securityService: securityService)),
      );
      await tester.pumpAndSettle();

      expect(find.text('PreNest'), findsOneWidget);
      expect(
        find.text('App is locked to protect your personal health records.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.fingerprint), findsOneWidget);
    });

    testWidgets('triggers authentication and invokes callback on success', (
      tester,
    ) async {
      var unlockedCalled = false;
      authenticator.shouldSucceed = true;

      await tester.pumpWidget(
        MaterialApp(
          home: LockScreen(
            securityService: securityService,
            onUnlocked: () => unlockedCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(unlockedCalled, isTrue);
      expect(securityService.isUnlocked, isTrue);
    });

    testWidgets('displays error message when authentication fails', (
      tester,
    ) async {
      authenticator.shouldSucceed = false;

      await tester.pumpWidget(
        MaterialApp(home: LockScreen(securityService: securityService)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Authentication cancelled or failed. Tap below to try again.',
        ),
        findsOneWidget,
      );
      expect(securityService.isUnlocked, isFalse);
    });

    testWidgets('retries authentication when the app resumes', (tester) async {
      authenticator.shouldSucceed = false;
      await tester.pumpWidget(
        MaterialApp(home: LockScreen(securityService: securityService)),
      );
      await tester.pumpAndSettle();
      expect(securityService.isUnlocked, isFalse);

      authenticator.shouldSucceed = true;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(securityService.isUnlocked, isTrue);
    });
  });
}
