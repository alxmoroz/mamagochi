// Copyright (c) 2024. Alexandr Moroz

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:mamagochi/L1_domain/usecases/sleep_uc.dart';
import 'package:mamagochi/L3_app/views/baby/baby_controller.dart';
import 'package:mamagochi/L3_app/views/history/history_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../L1_domain/usecases/baby_uc.dart';
import '../../../L1_domain/usecases/feed_uc.dart';
import '../../../L1_domain/usecases/local_settings_uc.dart';
import '../../../L2_data/repositories/db_repo.dart';
import '../../../L2_data/services/db.dart';
import '../../l10n/generated/l10n.dart';
import '../main/controllers/main_controller.dart';
import 'app_controller.dart';
import 'local_settings_controller.dart';

S get loc => S.current;

final getIt = GetIt.I;

LocalSettingsController get localSettingsController => getIt<LocalSettingsController>();

AppController get appController => getIt<AppController>();
MainController get mainController => getIt<MainController>();
BabyController get babyController => getIt<BabyController>();
HistoryController get historyController => getIt<HistoryController>();

LocalSettingsUC get localSettingsUC => getIt<LocalSettingsUC>();
SleepUC get sleepUC => getIt<SleepUC>();
FeedUC get feedUC => getIt<FeedUC>();
BabyUC get babyUC => getIt<BabyUC>();

void setup() {
  /// device
  getIt.registerSingletonAsync<BaseDeviceInfo>(() async => await DeviceInfoPlugin().deviceInfo);
  getIt.registerSingletonAsync<PackageInfo>(() async => await PackageInfo.fromPlatform());

  /// repo / adapters
  getIt.registerSingletonAsync<HiveStorage>(() async => await HiveStorage().init());

  /// use cases

  getIt.registerSingleton<LocalSettingsUC>(LocalSettingsUC(LocalSettingsRepo()));
  getIt.registerSingleton<SleepUC>(SleepUC(SleepRepo()));
  getIt.registerSingleton<FeedUC>(FeedUC(FeedRepo()));
  getIt.registerSingleton<BabyUC>(BabyUC(BabyRepo()));

  /// global state controllers
  // первые контроллеры
  getIt.registerSingletonAsync<LocalSettingsController>(() async => LocalSettingsController().init(), dependsOn: [HiveStorage, PackageInfo]);

  getIt.registerSingleton<AppController>(AppController());
  getIt.registerSingleton<HistoryController>(HistoryController());
  getIt.registerSingleton<MainController>(MainController());
  getIt.registerSingleton<BabyController>(BabyController());
}
