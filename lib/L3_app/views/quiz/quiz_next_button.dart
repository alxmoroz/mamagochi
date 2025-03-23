// Copyright (c) 2023. Alexandr Moroz

import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../components/button.dart';
import '../../components/constants.dart';
import 'abstract_quiz_controller.dart';

class QuizNextButton extends StatelessWidget {
  const QuizNextButton(this._controller, {super.key, this.margin, this.loading, this.disabled});
  final AbstractQuizController _controller;
  final EdgeInsets? margin;
  final bool? loading;
  final bool? disabled;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MTButton(
        type: _controller.step.nextButtonType,
        constrained: true,
        titleText: _controller.nextBtnTitle,
        margin: margin ?? const EdgeInsets.symmetric(vertical: P3),
        loading: loading,
        onTap: disabled == true ? null : _controller.next,
      ),
    );
  }
}
