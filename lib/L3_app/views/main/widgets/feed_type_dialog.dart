import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../L1_domain/entities/feed.dart';
import '../../../components/button.dart';
import '../../../components/colors.dart';
import '../../../components/dialog.dart';
import '../../../components/images.dart';
import '../../../components/text.dart';
import '../../_base/loader_screen.dart';
import '../../app/services.dart';
import '../../history/history_controller.dart';

class FeedTypeDialog extends StatelessWidget {
  const FeedTypeDialog({super.key});

  static Future show() async => await showMTDialog(const FeedTypeDialog());

  HistoryController get _hc => mainController.selectedBabyController!.historyController;

  Future _addFeed(FeedingType type, BuildContext context) async {
    await _hc.addFeed(type);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // final screen = screenSize(context);
    // final size = min(180.0, min(screen.width, screen.height) / 2 - P3);
    // final buttonSize = Size.square(size);

    return Observer(builder: (_) {
      return _hc.loading
          ? LoaderScreen(_hc)
          : MTDialog(
              body: ListView(
                shrinkWrap: true,
                children: [
                  Column(
                    children: [
                      // первая строка: смесь
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        /// бутылочка, смесь
                        MTButton(
                            // minSize: buttonSize,
                            minSize: Size.square(200),
                            constrained: false,
                            color: b3Color,
                            type: MTButtonType.main,
                            middle: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MTImage('bottle_baby_formula', height: 90),
                                SmallText('Смесь'),
                              ],
                            ),
                            onTap: () => _addFeed(FeedingType.baby_formula_bottle, context)),
                      ]),

                      // вторая строка: грудь и кнопка закрытия
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// правая грудь
                          MTButton(
                            // minSize: buttonSize,
                            minSize: Size.square(150),
                            constrained: false,
                            color: b3Color,
                            type: MTButtonType.main,
                            middle: const MTImage('breast', height: 100),
                            onTap: () => _addFeed(FeedingType.right_breast, context),
                          ),

                          /// кнопка закрытия
                          MTButton(
                            // minSize: buttonSize,
                            minSize: const Size.square(60),
                            constrained: false,
                            color: b3Color,
                            type: MTButtonType.main,
                            middle: const MTImage('close', height: 30),
                            onTap: Navigator.of(context).pop,
                          ),

                          /// левая грудь
                          MTButton(
                            // minSize: buttonSize,
                            minSize: Size.square(150),
                            constrained: false,
                            color: b3Color,
                            type: MTButtonType.main,
                            middle: const MTImage('breast', height: 100),
                            onTap: () => _addFeed(FeedingType.left_breast, context),
                          ),
                        ],
                      ),

                      // третья строка: бутылочка с молоком
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// бутылочка, молоко
                          MTButton(
                            // minSize: buttonSize,
                            minSize: Size.square(200),
                            constrained: false,
                            color: b3Color,
                            type: MTButtonType.main,
                            middle: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MTImage('bottle_milk', height: 90),
                                SmallText('Молоко'),
                              ],
                            ),
                            onTap: () => _addFeed(FeedingType.milk_bottle, context),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
              forceBottomPadding: true,
            );
    });
  }
}
