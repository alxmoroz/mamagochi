// Copyright (c) 2025. Xenia Moroz

import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../components/button.dart';
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
      builder: (_) => ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          H1(
            loc.onboarding_baby_name_step_title,
            align: TextAlign.center,
            padding: const EdgeInsets.all(P6).copyWith(bottom: P3),
          ),
          Center(child: _bc.baby.image()),
          MTTextField(
            controller: _bc.teController(0),
            label: loc.onboarding_baby_name_step_field_label,
          ),
          const SizedBox(height: P3),
          MTButton.main(
            titleText: loc.next_action_title,
            onTap: _bc.validated ? _setName : null,
          ),
        ],
      ),
    );
  }
}
