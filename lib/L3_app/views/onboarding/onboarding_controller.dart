// Copyright (c) 2024. Alexandr Moroz

import 'package:mobx/mobx.dart';

import '../../components/quiz/abstract_quiz_controller.dart';
import '../../navigation/router.dart';

part 'onboarding_controller.g.dart';

enum OnboardingStepCode { where_we_go }

class OnboardingController extends _OnboardingControllerBase with _$OnboardingController {
  // OnboardingController() {}

  @override
  Future afterNext() async {}

  @override
  Future finish() async {
    router.pop(step.code);
    // await myAccountController.registerOnboardingPassed(step.code);
  }
}

abstract class _OnboardingControllerBase extends AbstractQuizController with Store {
  @computed
  bool get isWhereWeGoStep => step.code == OnboardingStepCode.where_we_go.name;

  @override
  Iterable<QuizStep> get steps => [
        // показываем шаг с выбором финального действия
        QuizStep(OnboardingStepCode.where_we_go.name, '', awaiting: false),
      ];
}
