// Copyright (c) 2025. Xenia Moroz

import 'package:flutter/cupertino.dart';
import 'package:mamagochi/L3_app/navigation/router.dart';
import 'package:mamagochi/L3_app/presenters/baby.dart';

import '../../components/button.dart';
import '../../components/constants.dart';
import '../../components/text.dart';
import '../app/services.dart';

class HelloBabyStep extends StatelessWidget {
  const HelloBabyStep({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        H1(
          loc.onboarding_hello_step_title('${babyController.firstBaby?.name ?? babyController.firstBaby?.boyOrGirlStr}'),
          align: TextAlign.center,
          padding: const EdgeInsets.all(P6).copyWith(bottom: P3),
        ),
        Center(child: babyController.firstBaby?.image()),
        const SizedBox(height: P3),
        BaseText.medium(
          loc.onboarding_hello_step_text(babyController.firstBaby?.daysSinceBirth ?? '1'),
          align: TextAlign.center,
        ),
        const SizedBox(height: P3),
        MTButton.main(
          titleText: loc.lets_go_action_title,
          onTap: router.pop,
        ),
      ],
    );
  }
}
