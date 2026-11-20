abstract interface class SecureKeyStorage {
  /// Reads a sensitive string value by key. Returns `null` if not present.
  Future<String?> read({required String key});

  /// Writes a sensitive string value into secure storage.
  Future<void> write({required String key, required String value});

  /// Checks if a key exists in secure storage.
  Future<bool> containsKey({required String key});

  /// Deletes a key from secure storage.
  Future<void> delete({required String key});

  /// Clears all entries from secure storage.
  Future<void> deleteAll();
}

/// In-memory implementation of [SecureKeyStorage] for unit testing and mocked environments.
class MemorySecureKeyStorage implements SecureKeyStorage {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read({required String key}) async => _storage[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }

  @override
  Future<bool> containsKey({required String key}) async =>
      _storage.containsKey(key);

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }
}
