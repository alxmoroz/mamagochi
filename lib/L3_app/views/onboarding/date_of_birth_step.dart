// Copyright (c) 2025. Xenia Moroz

import 'package:flutter/cupertino.dart';
import 'package:mamagochi/L3_app/components/text_field.dart';

import '../../components/button.dart';
import '../../components/constants.dart';
import '../../components/images.dart';
import '../../components/text.dart';
import '../app/services.dart';
import '../baby/baby_controller.dart';

class DateOfBirthStep extends StatelessWidget {
  const DateOfBirthStep({super.key});

  Future _setDateOfBirth() async {
    //   await babyController.setDateOfBirth();
    babyController.setStep(OnboardingStep.hello_baby);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        H1(
          loc.onboarding_baby_date_of_birth_step_title,
          align: TextAlign.center,
          padding: const EdgeInsets.all(P6).copyWith(bottom: P3),
        ),
        const Center(child: MTImage('cake', height: 180)),
        Center(
          child: MTTextField(
            label: babyController.firstBaby?.isBoy == true
                ? loc.onboarding_baby_date_of_birth_step_field_label_boy
                : loc.onboarding_baby_date_of_birth_step_field_label_girl,
          ),
        ),
        const SizedBox(height: P3),
        MTButton.main(
          titleText: loc.next_action_title,
          // onTap: babyController.validated ? _setDateOfBirth : null,
          onTap: _setDateOfBirth,
        ),
      ],
    );
  }
}
