// Copyright (c) 2025. Xenia Moroz

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../L1_domain/utils/dates.dart';
import '../../components/adaptive.dart';
import '../../components/button.dart';
import '../../components/constants.dart';
import '../../components/images.dart';
import '../../components/loader.dart';
import '../../components/text.dart';
import '../app/services.dart';
import '../baby/baby_controller.dart';

final DateTime _initialDate = today;

class DateOfBirthStep extends StatefulWidget {
  const DateOfBirthStep(this._bc, {super.key});
  final BabyController _bc;

  @override
  State<DateOfBirthStep> createState() => _State();
}

class _State extends State<DateOfBirthStep> {
  DateTime _date = _initialDate;

  BabyController get _bc => widget._bc;

  Future _tap() async {
    await _bc.setDateOfBirth(_date);
    _bc.setStep(OnboardingStep.hello_baby);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final screen = screenSize(context);
        final screenHeight = min(SCR_M_HEIGHT, screen.height);

        return Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  H1(
                    loc.onboarding_baby_date_of_birth_step_title,
                    align: TextAlign.center,
                    padding: const EdgeInsets.all(P6).copyWith(bottom: P3),
                  ),
                  Center(child: MTSvgImage('cake', height: screenHeight * 0.3)),
                  SizedBox(
                    height: screenHeight * 0.45,
                    child: CupertinoDatePicker(
                      maximumDate: now.add(const Duration(days: 365)),
                      initialDateTime: _date,
                      mode: CupertinoDatePickerMode.date,
                      onDateTimeChanged: (DateTime value) => _date = value,
                    ),
                  ),
                  MTButton.main(titleText: loc.next_action_title, onTap: _tap),
                ],
              ),
            ),
            if (_bc.loading) const MTLoader(),
          ],
        );
      },
    );
  }
}
