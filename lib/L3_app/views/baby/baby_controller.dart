// Copyright (c) 2025. Xenia Moroz

import 'dart:core';

import 'package:mobx/mobx.dart';

import '../../../L1_domain/entities/baby.dart';
import '../../components/field_data.dart';
import '../_base/edit_controller.dart';
import '../_base/loadable.dart';
import '../app/services.dart';

part 'baby_controller.g.dart';

enum OnboardingStep { boy_or_girl, baby_name, date_of_birth, hello_baby }

class BabyController extends _Base with Loadable, _$BabyController {
  BabyController() {
    initState(fds: [const MTFieldData(0, validate: true)]);
  }

  Future reload() async {
    await load(() async {
      await _fetchBabies();
    });
    // print(babies);
  }

  Future setBoyOrGirl(bool isBoy) async {
    await load(() async {
      final newBaby = Baby(isBoy: isBoy);
      await _editBaby(newBaby, newBaby);
    });
  }

  Future setName() async {
    await load(() async {
      final baby = babies.firstWhere((b) => !b.named);
      await _editBaby(baby, baby.copyWith(name: fData(0).text));
    });
  }
}

abstract class _Base extends EditController with Store {
  @observable
  ObservableList<Baby> babies = ObservableList();

  @action
  Future _fetchBabies() async {
    babies = ObservableList.of(await babyUC.babies());
  }

  @action
  Future _editBaby(Baby notEditedBaby, Baby baby) async {
    final index = babies.indexOf(notEditedBaby);
    if (index > -1) {
      babies[index] = baby;
    } else {
      babies.add(baby);
    }
    await babyUC.editBaby(notEditedBaby, baby);
  }

  @computed
  Baby? get firstBaby => babies.firstOrNull;

  @computed
  bool get allBabiesDefined => babies.isNotEmpty && !babies.any((b) => !b.defined);

  @computed
  bool get isFirstBabyNamed => firstBaby?.named == true;

  @computed
  bool get isFirstBabyHasDateOfBirth => firstBaby?.hasDateOfBirth == true;

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
