import 'dart:async';

import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/app_settings.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._local);
  final SettingsLocalDataSource _local;

  @override
  AppSettings get() => _local.get();

  @override
  Future<void> save(AppSettings settings) => _local.save(settings);

  @override
  Stream<AppSettings> watch() async* {
    yield get();
    await for (final _ in _local.watchEvents()) {
      yield get();
    }
  }
}
