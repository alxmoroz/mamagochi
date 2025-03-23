// Copyright (c) 2022. Alexandr Moroz

import 'package:hive/hive.dart';

import '../../L1_domain/entities/app_local_settings.dart';
import '../services/db.dart';
import 'base.dart';

part 'app_local_settings.g.dart';

@HiveType(typeId: HType.APP_LOCAL_SETTINGS)
class AppLocalSettingsHO extends BaseModel<AppLocalSettings> {
  @HiveField(3, defaultValue: '')
  String version = '';

  @HiveField(4, defaultValue: 0)
  int launchCount = 0;

  @HiveField(5)
  Map<String, bool>? flags = {};

  @HiveField(6)
  Map<String, DateTime>? dates = {};

  @HiveField(7)
  Map<String, String>? strings = {};

  @override
  AppLocalSettings toEntity() => AppLocalSettings(
        version: version,
        launchCount: launchCount,
        flags: flags,
        dates: dates,
        strings: strings,
      );

  @override
  Future<AppLocalSettingsHO> update(AppLocalSettings entity) async {
    version = entity.version;
    launchCount = entity.launchCount;
    flags = entity.flags;
    dates = entity.dates;
    strings = entity.strings;
    await save();
    return this;
  }
}
