import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError(
    'settingsRepositoryProvider must be overridden in main.dart',
  );
});

final settingsStreamProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watch();
});

final settingsProvider = Provider<AppSettings>((ref) {
  return ref.watch(settingsStreamProvider).maybeWhen(
        data: (s) => s,
        orElse: () => AppSettings.defaults(),
      );
});

/// Derived: current ThemeMode from settings.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final s = ref.watch(settingsProvider);
  return switch (s.themeMode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
});

final currencyCodeProvider =
    Provider<String>((ref) => ref.watch(settingsProvider).currencyCode);

class SettingsController extends Notifier<void> {
  late final SettingsRepository _repo;

  @override
  void build() {
    _repo = ref.watch(settingsRepositoryProvider);
  }

  AppSettings _current() => _repo.get();

  Future<void> setThemeMode(ThemeMode mode) {
    final name = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    return _repo.save(_current().copyWith(themeMode: name));
  }

  Future<void> setCurrency(String code) =>
      _repo.save(_current().copyWith(currencyCode: code));

  Future<void> setAppLock({required bool enabled, String? pinHash}) =>
      _repo.save(_current().copyWith(
        appLockEnabled: enabled,
        pinHash: enabled ? pinHash : null,
      ));

  Future<void> setBiometric(bool enabled) =>
      _repo.save(_current().copyWith(biometricEnabled: enabled));

  Future<void> setNotifications(bool enabled) =>
      _repo.save(_current().copyWith(notificationsEnabled: enabled));

  Future<void> setDailyReminderHour(int hour) =>
      _repo.save(_current().copyWith(dailyReminderHour: hour));

  Future<void> markOnboardingComplete() =>
      _repo.save(_current().copyWith(onboardingComplete: true));
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, void>(SettingsController.new);
