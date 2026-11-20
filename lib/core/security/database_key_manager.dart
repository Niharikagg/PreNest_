import 'dart:math';
import 'key_generator.dart';
import 'secure_key_storage.dart';

/// Contract for providing the 32-byte database encryption key to Person C's database service.
abstract interface class DatabaseKeyProvider {
  /// Returns the 32-byte database encryption key.
  ///
  /// Guarantees that the key is generated once on the first run, stored in
  /// secure storage, and returned unchanged on all subsequent calls.
  Future<List<int>> getDatabaseKey();
}

/// Manages the lifecycle, persistence, and secure provisioning of the 32-byte
/// SQLCipher database encryption key.
///
/// Ensures the key is:
/// - Generated once with 256 bits of cryptographic entropy.
/// - Persisted in hardware-backed secure storage.
/// - Cached in memory for low-latency database access.
/// - Never logged, printed, or exposed in error messages.
class DatabaseKeyManager implements DatabaseKeyProvider {
  static const String defaultKeyAlias = 'prenest_db_key_v1';
  static const int requiredKeyLength = 32;

  final SecureKeyStorage _storage;
  final String _storageAlias;
  final Random? _random;

  List<int>? _cachedKey;

  DatabaseKeyManager({
    required this._storage,
    this._storageAlias = defaultKeyAlias,
    this._random,
  });

  /// Whether the key is currently cached in volatile memory.
  bool get isKeyCached => _cachedKey != null;

  @override
  Future<List<int>> getDatabaseKey() async {
    if (_cachedKey != null) {
      return List<int>.unmodifiable(_cachedKey!);
    }

    final storedHex = await _storage.read(key: _storageAlias);
    if (storedHex != null && storedHex.isNotEmpty) {
      try {
        final decoded = KeyGenerator.decodeFromHex(storedHex);
        _validateKey(decoded);
        _cachedKey = decoded;
        return List<int>.unmodifiable(decoded);
      } catch (e) {
        throw StateError(
          'Failed to load database encryption key from secure storage: corrupted key data.',
        );
      }
    }

    // First run: generate 32 cryptographically secure random bytes
    final newKey = KeyGenerator.generate32ByteKey(_random);
    _validateKey(newKey);

    final encodedHex = KeyGenerator.encodeToHex(newKey);
    await _storage.write(key: _storageAlias, value: encodedHex);

    _cachedKey = newKey;
    return List<int>.unmodifiable(newKey);
  }

  /// Clears the cached key from volatile memory when the app locks or terminates.
  void clearMemoryCache() {
    _cachedKey = null;
  }

  void _validateKey(List<int> key) {
    if (key.length != requiredKeyLength) {
      throw StateError(
        'Database encryption key must be exactly $requiredKeyLength bytes.',
      );
    }
    // Verify key has non-zero entropy (not all zeroes)
    if (key.every((byte) => byte == 0)) {
      throw StateError(
        'Generated database key contains zero entropy.',
      );
    }
  }

  @override
  String toString() {
    // Contract requirement: Never log or expose the database key in string representations
    return 'DatabaseKeyManager(alias: $_storageAlias, isCached: $isKeyCached)';
  }
}
