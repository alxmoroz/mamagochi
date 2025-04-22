// Copyright (c) 2024. Alexandr Moroz

import 'dart:async';

import 'package:mobx/mobx.dart';

import '../../../navigation/route.dart';
import '../../../navigation/router.dart';
import '../../../views/_base/loadable.dart';
import '../../app/services.dart';

part 'main_controller.g.dart';

class MainController extends _Base with _$MainController {
  Future _reloadData() async {
    setLoaderScreenLoading();
    await historyController.reload();
  }

  Future reload() async => await load(_reloadData);

  static const _updatePeriod = Duration(seconds: 15);
  Timer? _refreshTimer;

  Future startup() async {
    await appController.startup();

    // await authController.checkLocalAuth();
    // if (authController.authorized) {

    // обновление данных
    await reload();

    // Онбординг
    // String? onbPassedStepCode;
    const onboardingPassed = false;
    if (!onboardingPassed) {
      // onbPassedStepCode =
      await router.pushOnboarding();
    }

    // } else {
    //   authController.signOut();
    // }
    _refreshTimer ??= Timer.periodic(_updatePeriod, (_) => historyController.reload());
  }

  void onInactive() {
    if (_refreshTimer?.isActive == true) {
      _refreshTimer!.cancel();
      _refreshTimer = null;
    }
  }

  void clear() {
    // myAccountController.clear();

    _setUpdateDate(null);
  }
}

abstract class _Base with Store, Loadable {
  @observable
  DateTime? _updatedDate;
  @action
  void _setUpdateDate(DateTime? dt) => _updatedDate = dt;

  @observable
  MTRoute? currentRoute;
  @action
  void setRoute(MTRoute? route) => currentRoute = route;
}
