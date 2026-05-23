import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../models/app_settings.dart';

/// Settings live in a Hive box keyed by a single constant. We always read/write
/// at the same key — there is one settings object per install.
class SettingsLocalDataSource {
  SettingsLocalDataSource(this._box);
  final Box<AppSettings> _box;

  static const String _key = 'app_settings';

  static Future<SettingsLocalDataSource> open() async {
    final box = await Hive.openBox<AppSettings>(HiveBoxes.settings);
    if (!box.containsKey(_key)) {
      await box.put(_key, AppSettings.defaults());
    }
    return SettingsLocalDataSource(box);
  }

  AppSettings get() => _box.get(_key) ?? AppSettings.defaults();

  Future<void> save(AppSettings s) => _box.put(_key, s);

  Stream<BoxEvent> watchEvents() => _box.watch(key: _key);
}
