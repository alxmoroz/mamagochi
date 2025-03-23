// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../components/adaptive.dart';
import '../../components/button.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/text.dart';
import '../../components/toolbar.dart';
import '../app/services.dart';
import 'abstract_quiz_controller.dart';

class QuizHeader extends StatelessWidget implements PreferredSizeWidget {
  const QuizHeader(this._controller, {super.key});
  final AbstractQuizController _controller;

  Widget _stepMark(BuildContext context, int index) {
    final isCurrent = _controller.stepIndex == index;
    final r1 = isCurrent ? P2 : P;
    final r2 = r1 - P_3;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: P_3),
      child: CircleAvatar(
        radius: r1,
        backgroundColor: (isCurrent ? mainColor : f3Color).resolve(context),
        child: CircleAvatar(
          radius: r2,
          backgroundColor: b2Color.resolve(context),
          child: isCurrent ? DSmallText.bold('${_controller.stepIndex + 1}', color: mainColor) : null,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(P9);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MTTopBar(
        innerHeight: preferredSize.height,
        color: isBigScreen(context) ? b2Color : navbarColor,
        leading: const SizedBox(),
        middle: MTAdaptive(
            padding: const EdgeInsets.symmetric(horizontal: P2),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_controller.stepsCount > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var index = 0; index < _controller.stepsCount; index++) _stepMark(context, index),
                    ],
                  ),
                Row(
                  children: [
                    if (_controller.stepIndex > 0 || _controller.step.awaiting) MTButton(titleText: loc.action_back_title, onTap: _controller.back),
                    const Spacer(),
                    if (_controller.stepIndex < _controller.stepsCount - 1)
                      MTButton(
                        titleText: loc.action_skip_title,
                        padding: const EdgeInsets.only(right: P2),
                        onTap: _controller.finish,
                      )
                  ],
                ),
              ],
            )),
        bottomWidget: _controller.stepTitle.trim().isNotEmpty
            ? BaseText.medium(
                _controller.stepTitle,
                align: TextAlign.center,
                maxLines: 1,
                padding: const EdgeInsets.symmetric(vertical: P, horizontal: P3),
              )
            : null,
      ),
    );
  }
}
