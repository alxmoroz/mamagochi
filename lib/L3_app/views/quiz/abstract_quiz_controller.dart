// Copyright (c) 2023. Alexandr Moroz

import 'package:mobx/mobx.dart';

import '../../components/button.dart';
import '../../navigation/router.dart';
import '../app/services.dart';

part 'abstract_quiz_controller.g.dart';

class QuizStep {
  QuizStep(this.code, this.title, {this.nextButtonTitle, this.nextButtonType = MTButtonType.main, this.awaiting = true});
  final String code;
  final String title;
  final String? nextButtonTitle;
  final MTButtonType nextButtonType;
  final bool awaiting;
}

abstract class AbstractQuizController extends _Base with _$AbstractQuizController {
  void back() {
    if (step.awaiting) {
      router.pop();
    } else {
      _back();
    }
  }

  Future beforeNext() async {}
  Future afterNext() async {}
  void finish() {}

  Future next() async {
    await beforeNext();
    if (_lastStep) {
      finish();
    } else {
      final wasAwaiting = step.awaiting;
      _next();
      await afterNext();
      if (wasAwaiting) _back();
    }
  }
}

abstract class _Base with Store {
  Iterable<QuizStep> get steps => [];
  int get stepsCount => steps.length;

  @observable
  int stepIndex = 0;

  @computed
  QuizStep get step => steps.elementAt(stepIndex);

  @computed
  bool get _lastStep => stepIndex == stepsCount - 1;

  @computed
  String get stepTitle => step.title;

  @computed
  String get nextBtnTitle => step.nextButtonTitle ?? (_lastStep ? loc.lets_go_action_title : loc.next_action_title);

  @action
  void _back() {
    if (stepIndex > 0) {
      stepIndex--;
    }
  }

  @action
  void _next() => stepIndex++;
}
