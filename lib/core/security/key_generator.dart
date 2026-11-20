import 'dart:math';
import 'dart:typed_data';

/// Cryptographically secure key generator and codec for database encryption keys.
class KeyGenerator {
  static const int requiredKeyLength = 32;

  /// Generates exactly 32 cryptographically secure random bytes using [Random.secure].
  static Uint8List generate32ByteKey([Random? random]) {
    final rng = random ?? Random.secure();
    final bytes = Uint8List(requiredKeyLength);
    for (var i = 0; i < requiredKeyLength; i++) {
      bytes[i] = rng.nextInt(256);
    }
    return bytes;
  }

  /// Encodes raw key bytes to a hex string for safe storage in secure key-value stores.
  static String encodeToHex(List<int> bytes) {
    if (bytes.length != requiredKeyLength) {
      throw ArgumentError.value(
        bytes.length,
        'bytes.length',
        'Key must be exactly $requiredKeyLength bytes.',
      );
    }
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  /// Decodes a hex string back into a 32-byte key list.
  static Uint8List decodeFromHex(String hex) {
    if (hex.length != requiredKeyLength * 2) {
      throw ArgumentError(
        'Invalid key representation: must be ${requiredKeyLength * 2} hex characters.',
      );
    }
    final result = Uint8List(requiredKeyLength);
    for (var i = 0; i < requiredKeyLength; i++) {
      final byteString = hex.substring(i * 2, i * 2 + 2);
      final byteValue = int.tryParse(byteString, radix: 16);
      if (byteValue == null) {
        throw ArgumentError('Invalid hex characters in encoded key string.');
      }
      result[i] = byteValue;
    }
    return result;
  }
}
