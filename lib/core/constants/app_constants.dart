/// App-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Expense Tracker';
  static const String appVersion = '1.0.0';

  // SharedPreferences keys
  static const String prefsOnboardingComplete = 'onboarding_complete';
  static const String prefsThemeMode = 'theme_mode';
  static const String prefsCurrencyCode = 'currency_code';
  static const String prefsAppLockEnabled = 'app_lock_enabled';
  static const String prefsBiometricEnabled = 'biometric_enabled';
  static const String prefsPinHash = 'pin_hash';
  static const String prefsLastBackup = 'last_backup_iso';

  // Defaults
  static const String defaultCurrencyCode = 'ETB';
  static const String defaultLocale = 'en_US';

  // UI
  static const double pagePadding = 16.0;
  static const double cardRadius = 16.0;
  static const double pillRadius = 999.0;
}

/// Supported currencies for the picker. Codes follow ISO 4217.
const List<({String code, String symbol, String name})> kSupportedCurrencies = [
  (code: 'ETB', symbol: 'Br', name: 'Ethiopian Birr'),
];
