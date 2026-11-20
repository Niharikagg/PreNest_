import 'secure_key_storage.dart';

/// Factory and driver configuration for platform-backed secure storage.
///
/// In production, this wraps the hardware-backed keystore (Android Keystore / iOS Keychain).
class PlatformSecureKeyStorage implements SecureKeyStorage {
  final Future<String?> Function(String key) _readFn;
  final Future<void> Function(String key, String value) _writeFn;
  final Future<bool> Function(String key) _containsKeyFn;
  final Future<void> Function(String key) _deleteFn;
  final Future<void> Function() _deleteAllFn;

  const PlatformSecureKeyStorage({
    required Future<String?> Function(String key) read,
    required Future<void> Function(String key, String value) write,
    required Future<bool> Function(String key) containsKey,
    required Future<void> Function(String key) delete,
    required Future<void> Function() deleteAll,
  })  : _readFn = read,
        _writeFn = write,
        _containsKeyFn = containsKey,
        _deleteFn = delete,
        _deleteAllFn = deleteAll;

  @override
  Future<String?> read({required String key}) => _readFn(key);

  @override
  Future<void> write({required String key, required String value}) =>
      _writeFn(key, value);

  @override
  Future<bool> containsKey({required String key}) => _containsKeyFn(key);

  @override
  Future<void> delete({required String key}) => _deleteFn(key);

  @override
  Future<void> deleteAll() => _deleteAllFn();
}
