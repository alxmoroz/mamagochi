// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../components/adaptive.dart';
import '../../components/page.dart';
import '../../navigation/route.dart';
import '../_base/loader_screen.dart';
import '../baby/baby_controller.dart';
import 'baby_name_step.dart';
import 'boy_or_girl_step.dart';
import 'date_of_birth_step.dart';
import 'hello_baby_step.dart';

final onboardingRoute = MTRoute(
  path: '/onboarding',
  baseName: 'onboarding',
  noTransition: true,
  redirect: (_, state) => state.extra == null ? '/' : null,
  builder: (_, state) => _OnboardingView(state.extra as BabyController),
);

class _OnboardingView extends StatelessWidget {
  const _OnboardingView(this._bc);
  final BabyController _bc;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => _bc.loading
          ? LoaderScreen(_bc)
          : MTPage(
              body: MTAdaptive(
                child: _bc.isBoyOrGirlStep
                    ? BoyOrGirlStep(_bc)
                    : _bc.isBabyNameStep
                    ? BabyNameStep(_bc)
                    : _bc.isDateOfBirthStep
                    ? DateOfBirthStep(_bc)
                    : _bc.isHelloBabyStep
                    ? HelloBabyStep(_bc)
                    : const SizedBox(),
              ),
            ),
    );
  }
}
