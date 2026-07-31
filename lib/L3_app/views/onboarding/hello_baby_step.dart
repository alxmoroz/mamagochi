// Copyright (c) 2025. Xenia Moroz

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:mamagochi/L3_app/navigation/router.dart';
import 'package:mamagochi/L3_app/presenters/baby.dart';

import '../../components/button.dart';
import '../../components/constants.dart';
import '../../components/text.dart';
import '../app/services.dart';
import '../baby/baby_controller.dart';

class HelloBabyStep extends StatelessWidget {
  const HelloBabyStep(this._bc, {super.key});
  final BabyController _bc;

  Widget get _button => MTButton.main(
    titleText: _bc.baby.wasBorn
        ? loc.onboarding_hello_step_text_born(_bc.baby.daysSinceBirth ?? '')
        : loc.onboarding_hello_step_text_not_born,
    onTap: router.pop,
  );

  Widget _title({required EdgeInsets padding}) => H1(
    loc.onboarding_hello_step_title(_bc.baby.name ?? _bc.baby.boyOrGirlStr),
    align: TextAlign.center,
    padding: padding,
  );

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;

    if (!isLandscape) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _title(padding: const EdgeInsets.all(P6).copyWith(bottom: P3)),
            const SizedBox(height: P3),
            Center(child: _bc.baby.face()),
            const SizedBox(height: P3),
            _button,
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const reserved = 48.0 + MIN_BTN_HEIGHT + P;
        final faceSize = min(300.0, max(120.0, constraints.maxHeight - reserved));

        return Column(
          children: [
            _title(padding: const EdgeInsets.symmetric(horizontal: P3, vertical: P_2)),
            Expanded(
              child: Center(child: _bc.baby.face(size: faceSize)),
            ),
            _button,
          ],
        );
      },
    );
  }
}
