// Copyright (c) 2025. Xenia Moroz

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../L1_domain/utils/dates.dart';
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
        final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;

        return Stack(
          alignment: Alignment.center,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final titlePad = isLandscape
                    ? const EdgeInsets.symmetric(horizontal: P3, vertical: P)
                    : const EdgeInsets.all(P6).copyWith(bottom: P3);
                // Заголовок + кнопка + зазоры — picker забирает остаток, чтобы кнопка не обрезалась.
                final reserved = isLandscape ? 44.0 + MIN_BTN_HEIGHT + P : 88.0 + MIN_BTN_HEIGHT + P3;
                final cakeMax = isLandscape ? 0.0 : constraints.maxHeight * 0.28;
                final pickerMax = max(120.0, constraints.maxHeight - reserved - cakeMax);

                return Column(
                  children: [
                    H1(
                      loc.onboarding_baby_date_of_birth_step_title,
                      align: TextAlign.center,
                      padding: titlePad,
                    ),
                    if (!isLandscape && cakeMax > 0)
                      Center(child: MTSvgImage('cake', height: min(cakeMax, constraints.maxHeight * 0.3))),
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          height: pickerMax,
                          child: CupertinoDatePicker(
                            maximumDate: now.add(const Duration(days: 365)),
                            initialDateTime: _date,
                            mode: CupertinoDatePickerMode.date,
                            onDateTimeChanged: (DateTime value) => _date = value,
                          ),
                        ),
                      ),
                    ),
                    MTButton.main(titleText: loc.next_action_title, onTap: _tap),
                  ],
                );
              },
            ),
            if (_bc.loading) const MTLoader(),
          ],
        );
      },
    );
  }
}
