// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../components/adaptive.dart';
import '../../components/button.dart';
import '../../components/constants.dart';
import '../../components/icons.dart';
import '../../components/text.dart';
import '../app/services.dart';
import 'onboarding_controller.dart';

class WhereWeGoStep extends StatelessWidget {
  const WhereWeGoStep(this._controller, {super.key});
  final OnboardingController _controller;

  @override
  Widget build(BuildContext context) {
    return MTAdaptive(
      force: true,
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          H2(
            loc.onboarding_where_we_go_step_title,
            align: TextAlign.center,
            padding: const EdgeInsets.symmetric(horizontal: P6).copyWith(bottom: P2),
          ),
          const MTCardButton(
            margin: EdgeInsets.symmetric(horizontal: P4, vertical: P2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  SizedBox(width: P2),
                  Expanded(child: H3('loc.onboarding_start_with_XXXX_title')),
                  if (!kIsWeb) ChevronIcon(),
                ]),
                SizedBox(height: P2),
                BaseText('loc.onboarding_start_with_XXXX_text', align: TextAlign.left, maxLines: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
