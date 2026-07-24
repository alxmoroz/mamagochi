import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../L1_domain/entities/feed.dart';
import '../../../components/adaptive.dart';
import '../../../components/button.dart';
import '../../../components/colors.dart';
import '../../../components/constants.dart';
import '../../../components/dialog.dart';
import '../../../components/icons.dart';
import '../../../components/images.dart';
import '../../../components/text.dart';
import '../../_base/loader_screen.dart';
import '../../app/services.dart';
import '../../history/history_controller.dart';

class FeedTypeDialog extends StatelessWidget {
  const FeedTypeDialog._();

  static Future<FeedingType?> show() async => await showMTDialog(const FeedTypeDialog._(), forceCenter: true);

  HistoryController get _hc => mainController.selectedBabyController!.historyController;

  Future _addFeed(FeedingType type, BuildContext context) async {
    Navigator.of(context).pop(type);
  }

  static const _closeButtonMargin = 40.0;
  static const _breastSize = 250.0;
  static const _breastHangOffset = 125.0;
  static const _breastImageHeight = 200.0;

  /// Круглая кнопка груди (ландшафт / большой экран).
  /// [imageCentered] — контент по центру или к внутреннему краю.
  Widget _breastButton({
    required bool isLeft,
    required bool imageCentered,
    required VoidCallback onTap,
  }) {
    final contentAlign = imageCentered
        ? Alignment.center
        : (isLeft ? Alignment.centerRight : Alignment.centerLeft);
    final label = isLeft ? loc.feed_type_left_breast : loc.feed_type_right_breast;

    return MTButton(
      minSize: const Size.square(_breastSize),
      constrained: false,
      color: b3Color,
      type: MTButtonType.main,
      middle: SizedBox(
        width: _breastSize,
        height: _breastSize,
        child: Align(
          alignment: contentAlign,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MTSvgImage('breast', height: _breastImageHeight),
              BaseText(label, color: f2Color),
            ],
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return _hc.loading
            ? LoaderScreen(_hc)
            : SafeArea(
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final btnSize = min(200.0, constraints.maxHeight / 2 - _closeButtonMargin);
                    // Старый выезд за край — только портрет на небольшом экране.
                    final classicBreastLayout =
                        MediaQuery.orientationOf(context) == Orientation.portrait && !isBigScreen(context);

                    // Ландшафт / big screen: целиком на экране, если помещаются; с подписями.
                    final centerLeft = (constraints.maxWidth - btnSize) / 2;
                    final leftBreastLeft = centerLeft - P3 - _breastSize;
                    final rightBreastLeft = centerLeft + btnSize + P3;
                    final leftFits = leftBreastLeft >= 0;
                    final rightFits = rightBreastLeft + _breastSize <= constraints.maxWidth;

                    return GestureDetector(
                      onTap: Navigator.of(context).pop,
                      child: Container(
                        color: Colors.transparent,
                        width: constraints.maxWidth,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// бутылочка, смесь
                                MTButton(
                                  minSize: Size.square(btnSize),
                                  color: b3Color,
                                  type: MTButtonType.main,
                                  middle: Column(
                                    children: [
                                      const MTSvgImage('bottle_baby_formula', height: 90),
                                      BaseText(loc.feed_type_baby_formula, color: f2Color),
                                    ],
                                  ),
                                  onTap: () => _addFeed(FeedingType.baby_formula_bottle, context),
                                ),

                                /// кнопка закрытия
                                constraints.maxHeight > btnSize * 2 + 100 + _closeButtonMargin * 2
                                    ? MTButton(
                                        margin: const EdgeInsets.symmetric(vertical: _closeButtonMargin),
                                        minSize: const Size.square(100),
                                        color: b3Color,
                                        type: MTButtonType.main,
                                        middle: const MTSvgIcon('close', size: 50),
                                        onTap: Navigator.of(context).pop,
                                      )
                                    : const SizedBox(height: _closeButtonMargin),

                                /// бутылочка с молоком
                                MTButton(
                                  minSize: Size.square(btnSize),
                                  color: b3Color,
                                  type: MTButtonType.main,
                                  middle: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const MTSvgImage('bottle_milk', height: 90),
                                      BaseText(loc.feed_type_milk, color: f2Color),
                                    ],
                                  ),
                                  onTap: () => _addFeed(FeedingType.milk_bottle, context),
                                ),
                              ],
                            ),

                            /// левая грудь
                            if (classicBreastLayout)
                              Positioned(
                                left: -_breastHangOffset,
                                child: MTButton(
                                  minSize: const Size.square(_breastSize),
                                  color: b3Color,
                                  type: MTButtonType.main,
                                  middle: const MTSvgImage('breast', height: _breastImageHeight),
                                  onTap: () => _addFeed(FeedingType.left_breast, context),
                                ),
                              )
                            else
                              Positioned(
                                left: leftBreastLeft,
                                child: _breastButton(
                                  isLeft: true,
                                  imageCentered: leftFits,
                                  onTap: () => _addFeed(FeedingType.left_breast, context),
                                ),
                              ),

                            /// правая грудь
                            if (classicBreastLayout)
                              Positioned(
                                right: -_breastHangOffset,
                                child: MTButton(
                                  minSize: const Size.square(_breastSize),
                                  constrained: false,
                                  color: b3Color,
                                  type: MTButtonType.main,
                                  middle: const MTSvgImage('breast', height: _breastImageHeight),
                                  onTap: () => _addFeed(FeedingType.right_breast, context),
                                ),
                              )
                            else
                              Positioned(
                                left: rightBreastLeft,
                                child: _breastButton(
                                  isLeft: false,
                                  imageCentered: rightFits,
                                  onTap: () => _addFeed(FeedingType.right_breast, context),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
      },
    );
  }
}
