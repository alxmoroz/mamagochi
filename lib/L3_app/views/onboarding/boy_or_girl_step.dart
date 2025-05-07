// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/cupertino.dart';

import '../../components/button.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/images.dart';
import '../../components/text.dart';
import '../app/services.dart';
import '../baby/baby_controller.dart';

class BoyOrGirlStep extends StatelessWidget {
  const BoyOrGirlStep({super.key});

  Future _setBoyOrGirl({required bool isBoy}) async {
    await babyController.setBoyOrGirl(isBoy);
    babyController.setStep(OnboardingStep.baby_name);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        H1(
          loc.onboarding_boy_or_girl_step_title,
          align: TextAlign.center,
          padding: const EdgeInsets.all(P6).copyWith(bottom: P3),
        ),
        Center(
          child: Wrap(
            spacing: P3,
            runSpacing: P3,
            children: [
              MTButton(
                minSize: const Size(240, 240),
                constrained: false,
                color: b3Color,
                type: MTButtonType.main,
                middle: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MTImage('baby', height: 180),
                    SmallText(loc.sex_man),
                  ],
                ),
                onTap: () => _setBoyOrGirl(isBoy: true),
              ),
              MTButton(
                minSize: const Size(240, 240),
                constrained: false,
                color: b3Color,
                type: MTButtonType.main,
                middle: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MTImage('baby_girl', height: 180),
                    SmallText(loc.sex_woman),
                  ],
                ),
                onTap: () => _setBoyOrGirl(isBoy: false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
