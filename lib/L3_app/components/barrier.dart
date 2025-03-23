// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/cupertino.dart';

import 'adaptive.dart';
import 'background.dart';
import 'colors.dart';
import 'constants.dart';
import 'gesture.dart';

class MTBarrier extends StatelessWidget {
  const MTBarrier({
    required this.child,
    this.visible = false,
    this.inDialog = false,
    this.duration = KB_RELATED_ANIMATION_DURATION,
    this.margin,
    super.key,
  });
  final Widget child;
  final bool visible;
  final bool inDialog;
  final Duration duration;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: duration,
            child: IgnorePointer(
              ignoring: !visible,
              child: FocusDroppable(
                Container(
                  margin: margin,
                  decoration: backgroundDecoration(
                    context,
                    bg1Color: b2BarrierColor,
                    bg2Color: (!inDialog && isBigScreen(context) ? b1BarrierColor : b2BarrierColor),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
