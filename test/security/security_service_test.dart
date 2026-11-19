import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:prenest/core/contracts/security_service.dart';
import 'package:prenest/core/security/app_security_service.dart';
import 'package:prenest/core/security/biometric_authenticator.dart';
import 'package:prenest/core/security/secure_key_storage.dart';

void main() {
  group('AppSecurityService', () {
    late MockBiometricAuthenticator authenticator;
    late MemorySecureKeyStorage secureStorage;
    late DateTime currentTime;

    DateTime testClock() => currentTime;

    setUp(() {
      authenticator = MockBiometricAuthenticator();
      secureStorage = MemorySecureKeyStorage();
      currentTime = DateTime(2026, 11, 19, 10, 0, 0);
    });

    AppSecurityService createService({
      Duration inactivityTimeout = const Duration(minutes: 5),
      Random? random,
    }) {
      return AppSecurityService(
        authenticator: authenticator,
        secureStorage: secureStorage,
        inactivityTimeout: inactivityTimeout,
        clock: testClock,
        random: random,
      );
    }

    test('implements the shared SecurityService contract', () {
      final service = createService();
      expect(service, isA<SecurityService>());
    });

    test('is locked by default upon cold start', () {
      final service = createService();
      expect(service.isUnlocked, isFalse);
      expect(service.lastActivityTime, isNull);
    });

    test('unlocks when authentication succeeds', () async {
      final service = createService();
      authenticator.shouldSucceed = true;

      var notified = false;
      service.addListener(() => notified = true);

      final result = await service.authenticate();

      expect(result, isTrue);
      expect(service.isUnlocked, isTrue);
      expect(service.lastActivityTime, equals(currentTime));
      expect(notified, isTrue);
    });

    test('remains locked when authentication fails', () async {
      final service = createService();
      authenticator.shouldSucceed = false;

      final result = await service.authenticate();

      expect(result, isFalse);
      expect(service.isUnlocked, isFalse);
      expect(service.lastActivityTime, isNull);
    });

    test('lock() resets unlocked state and activity timestamp', () async {
      final service = createService();
      await service.authenticate();
      expect(service.isUnlocked, isTrue);

      var notified = false;
      service.addListener(() => notified = true);

      service.lock();

      expect(service.isUnlocked, isFalse);
      expect(service.lastActivityTime, isNull);
      expect(notified, isTrue);
    });

    test('recordActivity updates the activity timestamp when unlocked', () async {
      final service = createService();
      await service.authenticate();
      expect(service.lastActivityTime, equals(currentTime));

      currentTime = currentTime.add(const Duration(minutes: 2));
      service.recordActivity();

      expect(service.lastActivityTime, equals(currentTime));
    });

    test('auto-locks when inactivity timeout is exceeded', () async {
      final service = createService(inactivityTimeout: const Duration(minutes: 5));
      await service.authenticate();

      // Within timeout: 4 minutes
      currentTime = currentTime.add(const Duration(minutes: 4));
      expect(service.checkInactivityTimeout(), isFalse);
      expect(service.isUnlocked, isTrue);

      // Exceeded timeout: 5 minutes and 1 second
      currentTime = currentTime.add(const Duration(minutes: 1, seconds: 1));
      expect(service.checkInactivityTimeout(), isTrue);
      expect(service.isUnlocked, isFalse);
    });

    test('database key is generated once, stored, and returned unchanged', () async {
      final service = createService(random: Random(99));

      final key1 = await service.getDatabaseKey();
      expect(key1.length, 32);

      // Subsequent call from the same instance returns identical bytes
      final key2 = await service.getDatabaseKey();
      expect(key2, equals(key1));

      // Key must be in secure storage
      final storedKey = await secureStorage.read(
        key: AppSecurityService.databaseKeyStorageAlias,
      );
      expect(storedKey, isNotNull);

      // Fresh service instance with the same storage returns the same key
      final freshService = createService();
      final keyFromFresh = await freshService.getDatabaseKey();
      expect(keyFromFresh, equals(key1));
    });

    test('toString never leaks the database key or secrets', () async {
      final service = createService();
      await service.getDatabaseKey();

      final stringRep = service.toString();
      expect(stringRep, isNot(contains('prenest_db_key')));
      expect(stringRep, contains('AppSecurityService(isUnlocked: false'));
    });
  });
}
