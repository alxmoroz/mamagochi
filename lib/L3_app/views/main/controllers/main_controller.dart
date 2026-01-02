// Copyright (c) 2024. Alexandr Moroz

import 'dart:async';

import 'package:mobx/mobx.dart';

import '../../../../L1_domain/entities/baby.dart';
import '../../../../L1_domain/utils/dates.dart';
import '../../../navigation/route.dart';
import '../../../navigation/router.dart';
import '../../../views/_base/loadable.dart';
import '../../app/services.dart';
import '../../baby/baby_controller.dart';

part 'main_controller.g.dart';

class MainController extends _Base with _$MainController {
  Future reload() async => await load(() async {
    setLoaderScreenLoading();
    await _fetchBabies();
  });

  static const _updatePeriod = Duration(seconds: 15);
  Timer? _refreshTimer;

  Future startup() async {
    await appController.startup();

    // обновление данных
    await reload();

    // Онбординг
    if (babiesControllers.isEmpty) {
      _addBaby();
      await router.pushOnboarding(selectedBabyController!);
    } else {
      selectBaby(babiesControllers.first);
    }

    // обновляем историю записей по выбранному сейчас ребенку
    _refreshTimer ??= Timer.periodic(_updatePeriod, (_) => selectedBabyController?.historyController.reload());
  }

  void onInactive() {
    if (_refreshTimer?.isActive == true) {
      _refreshTimer!.cancel();
      _refreshTimer = null;
    }
  }

  Future selectBaby(BabyController bc) async {
    _selectBaby(bc);
    await bc.historyController.reload();
  }

  void clear() {
    babiesControllers.clear();
    selectedBabyController = null;
    currentRoute = null;
  }
}

abstract class _Base with Store, Loadable {
  @observable
  ObservableList<BabyController> babiesControllers = ObservableList();

  @action
  void _addBaby() {
    selectedBabyController = BabyController(Baby(created: now));
    babiesControllers.add(selectedBabyController!);
  }

  @action
  Future _fetchBabies() async {
    final babies = await babyUC.babies();
    babiesControllers = ObservableList.of(babies.map((b) => BabyController(b)));
  }

  @observable
  BabyController? selectedBabyController;
  @action
  void _selectBaby(BabyController value) => selectedBabyController = value;

  @observable
  MTRoute? currentRoute;
  @action
  void setRoute(MTRoute? route) => currentRoute = route;
}
