abstract interface class BiometricAuthenticator {
  /// Checks if the device has biometric or PIN authentication hardware and enrollment.
  Future<bool> canAuthenticate();

  /// Prompts the user for biometric or device PIN authentication.
  ///
  /// Returns `true` if authentication succeeded, `false` otherwise.
  Future<bool> authenticate({required String localizedReason});
}

/// In-memory/test implementation of [BiometricAuthenticator] for unit tests and headless environments.
class MockBiometricAuthenticator implements BiometricAuthenticator {
  bool shouldSucceed;
  bool deviceSupported;

  MockBiometricAuthenticator({
    this.shouldSucceed = true,
    this.deviceSupported = true,
  });

  @override
  Future<bool> canAuthenticate() async => deviceSupported;

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    if (!deviceSupported) {
      return false;
    }
    return shouldSucceed;
  }
}
