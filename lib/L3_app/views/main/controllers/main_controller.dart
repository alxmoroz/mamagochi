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
import '../../birthday/birthday_congrats_dialog.dart';

part 'main_controller.g.dart';

class MainController extends _Base with _$MainController {
  Future reload() async => await load(() async {
    setLoaderScreenLoading();
    await _fetchBabies();
  });

  static const _updatePeriod = Duration(seconds: 15);
  Timer? _refreshTimer;
  Future<void>? _startupInFlight;

  Future startup() async {
    // iOS при запуске/возврате из фона может дать несколько resumed подряд —
    // параллельные startup сбрасывали историю и мигали «засыпанием».
    final inFlight = _startupInFlight;
    if (inFlight != null) return inFlight;

    final done = _startupBody();
    _startupInFlight = done;
    try {
      await done;
    } finally {
      if (_startupInFlight == done) _startupInFlight = null;
    }
  }

  Future<void> _startupBody() async {
    await appController.startup();

    // Держим loader, пока не решим, показывать ли поздравление —
    // чтобы после онбординга/старта не мелькал главный экран.
    startLoading();
    setLoaderScreenLoading();
    await _fetchBabies();

    if (babiesControllers.isEmpty) {
      _addBaby();
      await router.pushOnboarding(selectedBabyController!);
      await BirthdayCongratsDialog.showIfNeeded();
      await selectedBabyController!.historyController.reload();
    } else {
      await selectBaby(babiesControllers.first);
      await BirthdayCongratsDialog.showIfNeeded();
    }

    stopLoading();

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
