// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mamagochi/L3_app/views/_base/loader_screen.dart';
import 'package:mamagochi/L3_app/views/app/services.dart';
import 'package:mamagochi/L3_app/views/onboarding/hello_baby_step.dart';

import '../../components/adaptive.dart';
import '../../components/page.dart';
import '../../navigation/route.dart';
import 'baby_name_step.dart';
import 'boy_or_girl_step.dart';
import 'date_of_birth_step.dart';

final onboardingRoute = MTRoute(
  path: '/onboarding',
  baseName: 'onboarding',
  noTransition: true,
  redirect: (_, state) => state.extra == null ? '/' : null,
  builder: (_, state) => const _OnboardingView(),
);

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => babyController.loading
          ? LoaderScreen(babyController)
          : MTPage(
              body: MTAdaptive(
                child: ListView(
                  children: [
                    if (babyController.isBoyOrGirlStep)
                      const BoyOrGirlStep()
                    else if (babyController.isBabyNameStep)
                      const BabyNameStep()
                    else if (babyController.isDateOfBirthStep)
                      const DateOfBirthStep()
                    else if (babyController.isHelloBabyStep)
                      const HelloBabyStep()
                  ],
                ),
              ),
            ),
    );
  }
}
