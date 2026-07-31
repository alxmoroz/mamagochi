// Copyright (c) 2024. Alexandr Moroz

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../components/constants.dart';
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

  Widget get _step => _bc.isBoyOrGirlStep
      ? BoyOrGirlStep(_bc)
      : _bc.isBabyNameStep
      ? BabyNameStep(_bc)
      : _bc.isDateOfBirthStep
      ? DateOfBirthStep(_bc)
      : _bc.isHelloBabyStep
      ? HelloBabyStep(_bc)
      : const SizedBox();

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => _bc.loading
          ? LoaderScreen(_bc)
          : MTPage(
              body: LayoutBuilder(
                builder: (context, constraints) {
                  // MTPage пишет top/bottom в MediaQuery, но не вставляет их в body;
                  // MTAdaptive прижимает к верху — шаги «ниже центра», длинный контент обрезает низ.
                  final padding = MediaQuery.paddingOf(context);
                  final width = min(SCR_M_WIDTH, constraints.maxWidth);
                  final height = max(0.0, constraints.maxHeight - padding.top - padding.bottom);

                  return Padding(
                    padding: EdgeInsets.only(top: padding.top, bottom: padding.bottom),
                    child: Center(
                      child: SizedBox(
                        width: width,
                        height: height,
                        child: _step,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
