import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';

/// Persisted user-facing app settings (separate from low-level prefs).
class AppSettings extends HiveObject {
  AppSettings({
    required this.currencyCode,
    required this.themeMode,
    required this.appLockEnabled,
    required this.biometricEnabled,
    required this.notificationsEnabled,
    required this.dailyReminderHour,
    this.pinHash,
    this.onboardingComplete = false,
  });

  String currencyCode;

  /// 'system' | 'light' | 'dark'
  String themeMode;

  bool appLockEnabled;
  bool biometricEnabled;
  bool notificationsEnabled;
  int dailyReminderHour;
  String? pinHash;
  bool onboardingComplete;

  factory AppSettings.defaults() => AppSettings(
        currencyCode: 'USD',
        themeMode: 'system',
        appLockEnabled: false,
        biometricEnabled: false,
        notificationsEnabled: true,
        dailyReminderHour: 20,
      );

  AppSettings copyWith({
    String? currencyCode,
    String? themeMode,
    bool? appLockEnabled,
    bool? biometricEnabled,
    bool? notificationsEnabled,
    int? dailyReminderHour,
    String? pinHash,
    bool? onboardingComplete,
  }) {
    return AppSettings(
      currencyCode: currencyCode ?? this.currencyCode,
      themeMode: themeMode ?? this.themeMode,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      pinHash: pinHash ?? this.pinHash,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = HiveTypeIds.appSettingsModel;

  @override
  AppSettings read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      currencyCode: (fields[0] as String?) ?? 'USD',
      themeMode: (fields[1] as String?) ?? 'system',
      appLockEnabled: (fields[2] as bool?) ?? false,
      biometricEnabled: (fields[3] as bool?) ?? false,
      notificationsEnabled: (fields[4] as bool?) ?? true,
      dailyReminderHour: (fields[5] as int?) ?? 20,
      pinHash: fields[6] as String?,
      onboardingComplete: (fields[7] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.currencyCode)
      ..writeByte(1)
      ..write(obj.themeMode)
      ..writeByte(2)
      ..write(obj.appLockEnabled)
      ..writeByte(3)
      ..write(obj.biometricEnabled)
      ..writeByte(4)
      ..write(obj.notificationsEnabled)
      ..writeByte(5)
      ..write(obj.dailyReminderHour)
      ..writeByte(6)
      ..write(obj.pinHash)
      ..writeByte(7)
      ..write(obj.onboardingComplete);
  }
}
