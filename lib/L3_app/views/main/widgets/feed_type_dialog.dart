import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../L1_domain/entities/feed.dart';
import '../../../components/button.dart';
import '../../../components/colors.dart';
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

                    return GestureDetector(
                      onTap: Navigator.of(context).pop,
                      child: Container(
                        color: Colors.transparent,
                        width: constraints.maxWidth,
                        child: Stack(
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
                                      const MTImage('bottle_baby_formula', height: 90),
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
                                      const MTImage('bottle_milk', height: 90),
                                      BaseText(loc.feed_type_milk, color: f2Color),
                                    ],
                                  ),
                                  onTap: () => _addFeed(FeedingType.milk_bottle, context),
                                ),
                              ],
                            ),

                            /// левая грудь
                            Positioned(
                              left: -125,
                              child: MTButton(
                                minSize: const Size.square(250),
                                color: b3Color,
                                type: MTButtonType.main,
                                middle: const MTImage('breast', height: 200),
                                onTap: () => _addFeed(FeedingType.left_breast, context),
                              ),
                            ),

                            /// правая грудь
                            Positioned(
                              right: -125,
                              child: MTButton(
                                minSize: const Size.square(250),
                                constrained: false,
                                color: b3Color,
                                type: MTButtonType.main,
                                middle: const MTImage('breast', height: 200),
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
