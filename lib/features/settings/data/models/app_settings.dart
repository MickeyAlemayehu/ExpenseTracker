import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';

/// Persisted user-facing app settings (separate from low-level prefs).
class AppSettings extends HiveObject {
  AppSettings({
    required this.currencyCode,
    required this.themeMode,
    required this.appLockEnabled,
    this.pinHash,
    this.onboardingComplete = false,
  });

  String currencyCode;

  /// 'system' | 'light' | 'dark'
  String themeMode;

  bool appLockEnabled;
  String? pinHash;
  bool onboardingComplete;

  factory AppSettings.defaults() => AppSettings(
        currencyCode: 'ETB',
        themeMode: 'system',
        appLockEnabled: false,
      );

  AppSettings copyWith({
    String? currencyCode,
    String? themeMode,
    bool? appLockEnabled,
    String? pinHash,
    bool? onboardingComplete,
  }) {
    return AppSettings(
      currencyCode: currencyCode ?? this.currencyCode,
      themeMode: themeMode ?? this.themeMode,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
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
      currencyCode: (fields[0] as String?) ?? 'ETB',
      themeMode: (fields[1] as String?) ?? 'system',
      appLockEnabled: (fields[2] as bool?) ?? false,
      pinHash: fields[3] as String?,
      onboardingComplete: (fields[4] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.currencyCode)
      ..writeByte(1)
      ..write(obj.themeMode)
      ..writeByte(2)
      ..write(obj.appLockEnabled)
      ..writeByte(3)
      ..write(obj.pinHash)
      ..writeByte(4)
      ..write(obj.onboardingComplete);
  }
}
