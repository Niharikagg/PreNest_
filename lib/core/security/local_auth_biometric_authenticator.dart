import 'package:local_auth/local_auth.dart';

import 'biometric_authenticator.dart';

class LocalAuthBiometricAuthenticator implements BiometricAuthenticator {
  LocalAuthBiometricAuthenticator({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  @override
  Future<bool> canAuthenticate() async {
    if (!await _localAuthentication.canCheckBiometrics) return false;
    return (await _localAuthentication.getAvailableBiometrics()).isNotEmpty;
  }

  @override
  Future<bool> authenticate({required String localizedReason}) {
    return _localAuthentication.authenticate(
      localizedReason: localizedReason,
      biometricOnly: false,
      persistAcrossBackgrounding: true,
    );
  }
}
