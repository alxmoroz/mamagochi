// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

enum FeedbackType { light, medium, heavy, vibrate, selection }

void unfocusAll() {
  final fm = FocusManager.instance;
  fm.applyFocusChangesIfNeeded();
  fm.primaryFocus?.unfocus();
}

mixin GestureManaging {
  Future tapAction(bool uf, Function action, {FeedbackType? fbType}) async {
    if (uf) unfocusAll();

    if (fbType != null) {
      switch (fbType) {
        case FeedbackType.light:
          await HapticFeedback.lightImpact();
          break;
        case FeedbackType.medium:
          await SystemSound.play(SystemSoundType.click);
          await HapticFeedback.mediumImpact();
          break;
        case FeedbackType.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case FeedbackType.vibrate:
          await HapticFeedback.vibrate();
          break;
        case FeedbackType.selection:
          await HapticFeedback.selectionClick();
          break;
      }
    }

    await action();
  }
}

class FocusDroppable extends StatelessWidget {
  const FocusDroppable(this._child, {super.key});
  final Widget? _child;

  @override
  Widget build(BuildContext context) => GestureDetector(onTap: unfocusAll, child: _child);
}
