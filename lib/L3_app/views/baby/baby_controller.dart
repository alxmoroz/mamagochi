// Copyright (c) 2025. Xenia Moroz

import 'dart:core';

import 'package:mobx/mobx.dart';

import '../../../L1_domain/entities/baby.dart';
import '../../components/field_data.dart';
import '../_base/edit_controller.dart';
import '../_base/loadable.dart';
import '../app/services.dart';
import '../history/history_controller.dart';

part 'baby_controller.g.dart';

enum OnboardingStep { boy_or_girl, baby_name, date_of_birth, hello_baby }

class BabyController extends _Base with Loadable, _$BabyController {
  BabyController(Baby babyIn) {
    baby = babyIn;
    initState(fds: [MTFieldData(0, validate: true, text: baby.name ?? '')]);
    historyController = HistoryController(baby);
    stopLoading();
  }

  Future setBoyOrGirl(bool isBoy) async {
    await load(() async {
      await babyUC.editBaby(baby);
    });
  }

  Future setName() async {
    await load(() async {
      baby.name = fData(0).text.trim();
      await babyUC.editBaby(baby);
    });
  }

  Future setDateOfBirth(DateTime? date) async {
    await load(() async {
      baby.dateOfBirth = date;
      await babyUC.editBaby(baby);
    });
  }
}

abstract class _Base extends EditController with Store {
  late final Baby baby;
  late final HistoryController historyController;

  /// онбординг

  @observable
  OnboardingStep _step = OnboardingStep.boy_or_girl;

  @action
  void setStep(OnboardingStep value) => _step = value;

  @computed
  bool get isBabyNameStep => _step == OnboardingStep.baby_name;

  @computed
  bool get isBoyOrGirlStep => _step == OnboardingStep.boy_or_girl;

  @computed
  bool get isDateOfBirthStep => _step == OnboardingStep.date_of_birth;

  @computed
  bool get isHelloBabyStep => _step == OnboardingStep.hello_baby;
}
