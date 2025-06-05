// Copyright (c) 2025. Xenia Moroz

import 'package:flutter/cupertino.dart';

import '../../components/button.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/images.dart';
import '../../components/text.dart';
import '../app/services.dart';
import '../baby/baby_controller.dart';

class BoyOrGirlStep extends StatelessWidget {
  const BoyOrGirlStep(this._bc, {super.key});
  final BabyController _bc;

  Future _setBoyOrGirl({required bool isBoy}) async {
    await _bc.setBoyOrGirl(isBoy);
    _bc.setStep(OnboardingStep.baby_name);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          H1(
            loc.onboarding_boy_or_girl_step_title,
            align: TextAlign.center,
            padding: const EdgeInsets.all(P6).copyWith(bottom: P5),
          ),
          Center(
            child: Wrap(
              direction: Axis.vertical,
              spacing: P3,
              runSpacing: P5,
              children: [
                MTButton(
                  minSize: const Size(240, 240),
                  constrained: false,
                  color: b3Color,
                  type: MTButtonType.main,
                  middle: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MTImage('boy', height: 180),
                      SmallText.medium(loc.sex_man),
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
                      const MTImage('girl', height: 180),
                      SmallText.medium(loc.sex_woman),
                    ],
                  ),
                  onTap: () => _setBoyOrGirl(isBoy: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
