// Copyright (c) 2025. Xenia Moroz

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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          H1(
            loc.onboarding_hello_step_title(_bc.baby.name ?? _bc.baby.boyOrGirlStr),
            align: TextAlign.center,
            padding: const EdgeInsets.all(P6).copyWith(bottom: P3),
          ),
          const SizedBox(height: P3),
          Center(child: _bc.baby.image()),
          const SizedBox(height: P3),
          // BaseText.medium(
          //   loc.onboarding_hello_step_text(_bc.baby.daysSinceBirth ?? ''),
          //   align: TextAlign.center,
          // ),
          const SizedBox(height: P3),
          MTButton.main(
            titleText: loc.onboarding_hello_step_text(_bc.baby.daysSinceBirth ?? ''),
            onTap: router.pop,
          ),
        ],
      ),
    );
  }
}
