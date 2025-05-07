// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mamagochi/L3_app/components/button.dart';
import 'package:mamagochi/L3_app/components/text_field.dart';

import '../../components/constants.dart';
import '../../components/images.dart';
import '../../components/text.dart';
import '../app/services.dart';
import '../baby/baby_controller.dart';

class BabyNameStep extends StatelessWidget {
  const BabyNameStep({super.key});

  Future _setName() async {
    await babyController.setName();
    babyController.setStep(OnboardingStep.date_of_birth);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          H1(
            loc.onboarding_baby_name_step_title,
            align: TextAlign.center,
            padding: const EdgeInsets.all(P6).copyWith(bottom: P3),
          ),
          Center(child: MTImage(babyController.firstBaby?.isBoy == true ? 'baby' : 'baby_girl')),
          MTTextField(
            controller: babyController.teController(0),
            label: loc.onboarding_baby_name_step_field_label,
          ),
          const SizedBox(height: P3),
          MTButton.main(
            titleText: loc.next_action_title,
            onTap: babyController.validated ? _setName : null,
          ),
        ],
      ),
    );
  }
}
