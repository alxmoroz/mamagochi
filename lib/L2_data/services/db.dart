// Copyright (c) 2022. Alexandr Moroz

import 'package:hive/hive.dart';
import 'package:mamagochi/L2_data/models/sleep.dart';
import 'package:path_provider/path_provider.dart';

import '../models/app_local_settings.dart';
import '../models/feed.dart';
import '../services/platform.dart';

class HType {
  static const APP_LOCAL_SETTINGS = 1;
  static const SLEEP = 2;
  static const FEED = 3;
}

class HiveStorage {
  Future<HiveStorage> init() async {
    if (!isWeb) {
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
    } else {
      // TODO: убрать после фикса Hive 2.2
      Hive.init('');
    }

    Hive.registerAdapter(AppLocalSettingsHOAdapter());
    Hive.registerAdapter(SleepHOAdapter());
    Hive.registerAdapter(FeedHOAdapter());

    return this;
  }
}
