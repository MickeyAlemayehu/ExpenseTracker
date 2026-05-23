import 'package:flutter/foundation.dart';

/// Biometric / device-credential authentication wrapper around `local_auth`.
/// Returns `true` if the user successfully authenticates.
///
/// Stubbed for the MVP — implementation steps:
///   1. Instantiate `LocalAuthentication()`.
///   2. Call `canCheckBiometrics` and `isDeviceSupported`.
///   3. Call `authenticate(localizedReason: ..., options: ...)` with
///      `AuthenticationOptions(biometricOnly: false, stickyAuth: true)`.
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  Future<bool> isAvailable() async {
    // TODO(prod): LocalAuthentication().canCheckBiometrics + isDeviceSupported
    return false;
  }

  Future<bool> authenticate({
    String reason = 'Unlock Expense Tracker',
  }) async {
    // TODO(prod): plug `local_auth`.
    if (kDebugMode) debugPrint('[biometric] authenticate (stub): $reason');
    return false;
  }
}
