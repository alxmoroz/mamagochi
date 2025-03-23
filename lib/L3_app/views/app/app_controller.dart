// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import '../_base/loadable.dart';
import 'services.dart';

part 'app_controller.g.dart';

class AppController extends _AppControllerBase with _$AppController {
  AppController() {
    stopLoading();
  }
}

abstract class _AppControllerBase with Store, Loadable {
  // @computed
  // int get _buildNumber => int.parse((settings?.frontendVersion ?? '1.0').split('.').last);

  // @computed
  // int get _ltsBuildNumber => int.parse((settings?.frontendLtsVersion ?? '1.0').split('.').last);

  // @computed
  // bool get mayUpgrade => localSettingsController.buildNumber < _buildNumber;

  // @computed
  // bool get mustUpgrade => localSettingsController.buildNumber < _ltsBuildNumber;

  Future startup() async {
    // действия после обновления версии
    if (localSettingsController.isNewVersion) {
      try {
        localSettingsController.resetAppUpgradeProposalDate();
        localSettingsController.resetOldVersionFlag();
      } catch (e) {
        if (kDebugMode) print('app startup $e');
      }
    }
  }
}
