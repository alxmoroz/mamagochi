// Copyright (c) 2025. Xenia Moroz

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../components/adaptive.dart';
import '../../components/button.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/text.dart';
import '../../components/text_field.dart';
import '../../presenters/baby.dart';
import '../app/services.dart';
import '../baby/baby_controller.dart';

class BabyNameStep extends StatelessWidget {
  const BabyNameStep(this._bc, {super.key});
  final BabyController _bc;

  Future _setName() async {
    await _bc.setName();
    _bc.setStep(OnboardingStep.date_of_birth);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Center(
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            H1(
              loc.onboarding_baby_name_step_title,
              align: TextAlign.center,
              padding: const EdgeInsets.all(P6).copyWith(bottom: P3),
            ),
            Center(child: _bc.baby.image()),
            MTAdaptive.s(
              child: MTTextField(
                maxLines: 1,
                controller: _bc.teController(0),
                style: const H2('', color: f2Color).style(context),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: loc.onboarding_baby_name_step_field_label,
                  hintStyle: const H2('', color: f3Color).style(context),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _bc.validated ? _setName() : null,
              ),
            ),
            const SizedBox(height: P3),
            if (MediaQuery.viewInsetsOf(context).bottom == 0) MTButton.main(titleText: loc.next_action_title, onTap: _bc.validated ? _setName : null),
          ],
        ),
      ),
    );
  }
}
