import 'dart:math';
import 'package:flutter/foundation.dart';
import '../contracts/security_service.dart';
import 'biometric_authenticator.dart';
import 'key_generator.dart';
import 'secure_key_storage.dart';

/// Concrete implementation of [SecurityService] for PreNest.
///
/// Manages biometric/PIN authentication, inactivity timeout, lifecycle locking,
/// and secure database key generation and persistence.
class AppSecurityService with ChangeNotifier implements SecurityService {
  static const String databaseKeyStorageAlias = 'prenest_db_key_v1';
  static const Duration defaultInactivityTimeout = Duration(minutes: 5);

  final BiometricAuthenticator _authenticator;
  final SecureKeyStorage _secureStorage;
  final Duration inactivityTimeout;
  final DateTime Function() _clock;
  final Random? _random;

  bool _isUnlocked = false;
  DateTime? _lastActivityTime;
  List<int>? _cachedDatabaseKey;

  AppSecurityService({
    required this._authenticator,
    required this._secureStorage,
    Duration? inactivityTimeout,
    DateTime Function()? clock,
    this._random,
  })  : inactivityTimeout = inactivityTimeout ?? defaultInactivityTimeout,
        _clock = clock ?? DateTime.now;

  @override
  bool get isUnlocked => _isUnlocked;

  DateTime? get lastActivityTime => _lastActivityTime;

  @override
  Future<bool> authenticate({
    String reason = 'Authenticate to access your sensitive health records',
  }) async {
    final success = await _authenticator.authenticate(localizedReason: reason);
    if (success) {
      _isUnlocked = true;
      _lastActivityTime = _clock();
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  void lock() {
    if (_isUnlocked) {
      _isUnlocked = false;
      _lastActivityTime = null;
      notifyListeners();
    }
  }

  /// Manually registers user activity to prevent premature inactivity timeouts.
  void recordActivity() {
    if (_isUnlocked) {
      _lastActivityTime = _clock();
    }
  }

  /// Evaluates whether the user has been inactive for longer than [inactivityTimeout].
  ///
  /// If expired, locks the app immediately and returns `true`. Otherwise returns `false`.
  bool checkInactivityTimeout() {
    if (!_isUnlocked) {
      return false;
    }
    final last = _lastActivityTime;
    if (last == null) {
      lock();
      return true;
    }
    final elapsed = _clock().difference(last);
    if (elapsed >= inactivityTimeout) {
      lock();
      return true;
    }
    return false;
  }

  @override
  Future<List<int>> getDatabaseKey() async {
    if (_cachedDatabaseKey != null) {
      return List<int>.unmodifiable(_cachedDatabaseKey!);
    }

    final storedHex = await _secureStorage.read(key: databaseKeyStorageAlias);
    if (storedHex != null && storedHex.isNotEmpty) {
      final decodedKey = KeyGenerator.decodeFromHex(storedHex);
      _cachedDatabaseKey = decodedKey;
      return List<int>.unmodifiable(decodedKey);
    }

    // First run: generate 32 cryptographically secure random bytes
    final newKey = KeyGenerator.generate32ByteKey(_random);
    final encodedHex = KeyGenerator.encodeToHex(newKey);
    await _secureStorage.write(
      key: databaseKeyStorageAlias,
      value: encodedHex,
    );
    _cachedDatabaseKey = newKey;
    return List<int>.unmodifiable(newKey);
  }

  @override
  String toString() {
    // Contract requirement: Never log or print the database key or internal secrets
    return 'AppSecurityService(isUnlocked: $_isUnlocked, lastActivity: $_lastActivityTime)';
  }
}
