// Copyright (c) 2025. Xenia Moroz

import 'package:flutter/cupertino.dart';

import '../../../../L1_domain/entities/baby.dart';
import '../../../../L1_domain/utils/dates.dart';
import '../../components/button.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/text.dart';
import '../app/services.dart';
import '../baby/baby_controller.dart';
import '../baby_face/baby_face_config.dart';
import '../baby_face/baby_face_mode.dart';
import '../baby_face/baby_face_widget.dart';

class BoyOrGirlStep extends StatelessWidget {
  const BoyOrGirlStep(this._bc, {super.key});
  final BabyController _bc;

  Future _setBoyOrGirl({required bool isBoy}) async {
    await _bc.setBoyOrGirl(isBoy);
    _bc.setStep(OnboardingStep.baby_name);
  }

  Widget _genderButton({required bool isBoy, required double faceSize, required Size minSize}) {
    return MTButton(
      minSize: minSize,
      constrained: false,
      color: b3Color,
      type: MTButtonType.main,
      middle: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BabyFaceWidget(
            config: BabyFaceConfig.forBaby(Baby(created: now, isBoy: isBoy), BabyFaceMode.awake),
            size: faceSize,
            enableBlink: false,
          ),
          SmallText.medium(isBoy ? loc.sex_man : loc.sex_woman),
        ],
      ),
      onTap: () => _setBoyOrGirl(isBoy: isBoy),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    const faceSize = 180.0;
    const minSize = Size(240, 240);

    final buttons = [
      _genderButton(isBoy: true, faceSize: faceSize, minSize: minSize),
      _genderButton(isBoy: false, faceSize: faceSize, minSize: minSize),
    ];

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          H1(
            loc.onboarding_boy_or_girl_step_title,
            align: TextAlign.center,
            padding: EdgeInsets.all(isLandscape ? P3 : P6).copyWith(bottom: isLandscape ? P3 : P5),
          ),
          isLandscape
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buttons[0],
                    const SizedBox(width: P5),
                    buttons[1],
                  ],
                )
              : Wrap(
                  direction: Axis.vertical,
                  spacing: P3,
                  runSpacing: P5,
                  children: buttons,
                ),
        ],
      ),
    );
  }
}
