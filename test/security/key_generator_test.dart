import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:prenest/core/security/key_generator.dart';

void main() {
  group('KeyGenerator', () {
    test('generates exactly 32 cryptographically secure bytes', () {
      final key = KeyGenerator.generate32ByteKey();
      expect(key.length, 32);
      expect(key.any((b) => b != 0), isTrue);
    });

    test('generates distinct keys across multiple runs', () {
      final key1 = KeyGenerator.generate32ByteKey();
      final key2 = KeyGenerator.generate32ByteKey();
      expect(key1, isNot(equals(key2)));
    });

    test('encodes and decodes 32-byte key via hex losslessly', () {
      final key = KeyGenerator.generate32ByteKey(Random(42));
      final hex = KeyGenerator.encodeToHex(key);

      expect(hex.length, 64);
      final decoded = KeyGenerator.decodeFromHex(hex);
      expect(decoded, equals(key));
    });

    test('rejects encoding keys that are not 32 bytes', () {
      expect(
        () => KeyGenerator.encodeToHex([1, 2, 3]),
        throwsArgumentError,
      );
    });

    test('rejects decoding hex strings of incorrect length', () {
      expect(
        () => KeyGenerator.decodeFromHex('abcd'),
        throwsArgumentError,
      );
    });

    test('rejects decoding invalid hex characters', () {
      final invalidHex = 'zz' * 32;
      expect(
        () => KeyGenerator.decodeFromHex(invalidHex),
        throwsArgumentError,
      );
    });
  });
}
