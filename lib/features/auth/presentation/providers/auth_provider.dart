import 'dart:convert';

import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/providers/settings_provider.dart';

/// Auth state for the local PIN + biometric flow.
enum AuthStatus { unknown, needsSetup, locked, unlocked }

class AuthState {
  const AuthState({required this.status});
  final AuthStatus status;

  AuthState copyWith({AuthStatus? status}) =>
      AuthState(status: status ?? this.status);
}

class AuthController extends Notifier<AuthState> {
  /// True after the user has successfully authenticated in this app session.
  /// Survives settings changes (so toggling theme while unlocked doesn't relock).
  bool _sessionUnlocked = false;

  @override
  AuthState build() {
    final s = ref.watch(settingsProvider);
    if (!s.appLockEnabled) return const AuthState(status: AuthStatus.unlocked);
    if (s.pinHash == null) return const AuthState(status: AuthStatus.needsSetup);
    if (_sessionUnlocked) return const AuthState(status: AuthStatus.unlocked);
    return const AuthState(status: AuthStatus.locked);
  }

  bool unlockWithPin(String pin) {
    final settings = ref.read(settingsProvider);
    final expected = settings.pinHash;
    if (expected == null) return false;
    if (_hash(pin) == expected) {
      _sessionUnlocked = true;
      state = const AuthState(status: AuthStatus.unlocked);
      return true;
    }
    return false;
  }

  Future<void> setPin(String pin) async {
    _sessionUnlocked = true;
    final hash = _hash(pin);
    await ref
        .read(settingsControllerProvider.notifier)
        .setAppLock(enabled: true, pinHash: hash);
    state = const AuthState(status: AuthStatus.unlocked);
  }

  Future<void> disableLock() async {
    _sessionUnlocked = true;
    await ref
        .read(settingsControllerProvider.notifier)
        .setAppLock(enabled: false);
    state = const AuthState(status: AuthStatus.unlocked);
  }

  void unlockFromBiometric() {
    _sessionUnlocked = true;
    state = const AuthState(status: AuthStatus.unlocked);
  }

  void lock() {
    _sessionUnlocked = false;
    if (ref.read(settingsProvider).appLockEnabled) {
      state = const AuthState(status: AuthStatus.locked);
    }
  }

  String _hash(String pin) =>
      sha256.convert(utf8.encode('expense-tracker:$pin')).toString();
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
