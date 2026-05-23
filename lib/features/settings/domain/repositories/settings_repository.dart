import '../../data/models/app_settings.dart';

abstract class SettingsRepository {
  AppSettings get();
  Future<void> save(AppSettings settings);
  Stream<AppSettings> watch();
}
