// Copyright (c) 2024. Alexandr Moroz

import 'dart:async';

import 'package:mobx/mobx.dart';

import '../../../../L1_domain/utils/dates.dart';
import '../../../navigation/route.dart';
import '../../../navigation/router.dart';
import '../../../views/_base/loadable.dart';
import '../../app/services.dart';

part 'main_controller.g.dart';

class MainController extends _Base with _$MainController {
  Future _reloadData() async {
    setLoaderScreenLoading();
    // await myAccountController.reload();

    _setUpdateDate(now);
  }

  Future reload() async => await load(_reloadData);

  @override
  startLoading() {
    setLoaderScreenLoading();
    super.startLoading();
  }

  // static const _updatePeriod = Duration(hours: 1);

  Future startup() async {
    await appController.startup();

    // await authController.checkLocalAuth();
    // if (authController.authorized) {

    // удаляем инфу о переходе по рекламе (передали в хедере)
    if (localSettingsController.hasUTM) await localSettingsController.deleteUTM();

    // обновление данных
    final isTimeToUpdate = _updatedDate == null; // || _updatedDate!.add(_updatePeriod).isBefore(now);
    if (isTimeToUpdate || router.isDeepLink) {
      await reload();
    }

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
