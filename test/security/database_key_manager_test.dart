import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:prenest/core/security/database_key_manager.dart';
import 'package:prenest/core/security/key_generator.dart';
import 'package:prenest/core/security/secure_key_storage.dart';

void main() {
  group('DatabaseKeyManager', () {
    late MemorySecureKeyStorage storage;

    setUp(() {
      storage = MemorySecureKeyStorage();
    });

    test('implements DatabaseKeyProvider interface', () {
      final manager = DatabaseKeyManager(storage: storage);
      expect(manager, isA<DatabaseKeyProvider>());
    });

    test('generates exactly 32-byte key on first run and persists to storage', () async {
      final manager = DatabaseKeyManager(
        storage: storage,
        random: Random(123),
      );

      expect(manager.isKeyCached, isFalse);

      final key = await manager.getDatabaseKey();

      expect(key.length, 32);
      expect(manager.isKeyCached, isTrue);

      final storedHex = await storage.read(key: DatabaseKeyManager.defaultKeyAlias);
      expect(storedHex, isNotNull);
      expect(storedHex!.length, 64);
      expect(KeyGenerator.decodeFromHex(storedHex), equals(key));
    });

    test('subsequent calls return identical cached key', () async {
      final manager = DatabaseKeyManager(storage: storage);

      final key1 = await manager.getDatabaseKey();
      final key2 = await manager.getDatabaseKey();

      expect(identical(key1, key2) || key1.toString() == key2.toString(), isTrue);
      expect(key1, equals(key2));
    });

    test('fresh manager reads and re-uses existing key from storage', () async {
      final initialKey = KeyGenerator.generate32ByteKey(Random(42));
      final hex = KeyGenerator.encodeToHex(initialKey);
      await storage.write(key: DatabaseKeyManager.defaultKeyAlias, value: hex);

      final freshManager = DatabaseKeyManager(storage: storage);
      final key = await freshManager.getDatabaseKey();

      expect(key, equals(initialKey));
      expect(freshManager.isKeyCached, isTrue);
    });

    test('clearMemoryCache resets in-memory cache', () async {
      final manager = DatabaseKeyManager(storage: storage);
      await manager.getDatabaseKey();
      expect(manager.isKeyCached, isTrue);

      manager.clearMemoryCache();
      expect(manager.isKeyCached, isFalse);
    });

    test('throws StateError if stored key data is corrupted', () async {
      await storage.write(
        key: DatabaseKeyManager.defaultKeyAlias,
        value: 'corrupted_invalid_hex_string',
      );

      final manager = DatabaseKeyManager(storage: storage);

      expect(
        () => manager.getDatabaseKey(),
        throwsStateError,
      );
    });

    test('toString never leaks key bytes or hex data', () async {
      final manager = DatabaseKeyManager(storage: storage);
      final key = await manager.getDatabaseKey();
      final hex = KeyGenerator.encodeToHex(key);

      final str = manager.toString();
      expect(str, contains('DatabaseKeyManager'));
      expect(str, isNot(contains(hex)));
    });
  });
}
