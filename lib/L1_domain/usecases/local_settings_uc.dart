// Copyright (c) 2022. Alexandr Moroz

import '../entities/app_local_settings.dart';
import '../repositories/abs_db_repo.dart';

class LocalSettingsUC {
  LocalSettingsUC(this.repo);

  final AbstractLocalStorageRepo<AbstractDBModel, AppLocalSettings> repo;

  Future<AppLocalSettings> settings() async => await repo.getOne() ?? AppLocalSettings();

  Future<AppLocalSettings> updateSettingsFromLaunch(String version) async {
    final settings = await repo.getOne() ?? AppLocalSettings();
    settings.version = version;
    settings.launchCount++;
    await repo.update((_) => true, settings);
    return settings;
  }

  Future<AppLocalSettings> setDate(String code, DateTime? date) async {
    final settings = await repo.getOne() ?? AppLocalSettings();
    if (date != null) {
      settings.setDate(code, date);
    } else {
      settings.removeDate(code);
    }

    await repo.update((_) => true, settings);
    return settings;
  }

  Future<AppLocalSettings> setString(String code, String? string) async {
    final settings = await repo.getOne() ?? AppLocalSettings();
    if (string != null) {
      settings.setString(code, string);
    } else {
      settings.removeString(code);
    }

    await repo.update((_) => true, settings);
    return settings;
  }
}
