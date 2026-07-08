// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mamagochi/L3_app/presenters/feed.dart';

import '../../../../L1_domain/utils/dates.dart';
import '../../../components/adaptive.dart';
import '../../../components/button.dart';
import '../../../components/colors.dart';
import '../../../components/constants.dart';
import '../../../components/images.dart';
import '../../../components/text.dart';
import '../../../presenters/baby.dart';
import '../../../presenters/date.dart';
import '../../app/services.dart';
import '../../history/history_controller.dart';

class BottomMenu extends StatelessWidget implements PreferredSizeWidget {
  const BottomMenu({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(BOTTOM_BAR_ZONE_HEIGHT);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final hc = mainController.selectedBabyController?.historyController;
        if (hc == null) return const SizedBox();

        final baby = mainController.selectedBabyController!.baby;
        final buttonSize = Size.square(bottomBarButtonSize(screenSize(context)));

        /// Левая кнопка: сон — либо «Проснулся», либо «Сон» + последнее время
        final sleepButton = hc.babyIsSleeping ? _buttonStopSleep(hc, baby, buttonSize) : _buttonStartSleep(hc, buttonSize);

        /// Правая кнопка: кормление — либо «Завершить кормление», либо «Добавить кормление» + последнее время
        final feedButton = hc.babyIsEating ? _buttonStopFeed(hc, baby, buttonSize) : _buttonAddFeed(hc, buttonSize);

        return Row(
          children: [
            const SizedBox(width: P2),
            sleepButton,
            const Spacer(),
            feedButton,
            const SizedBox(width: P2),
          ],
        );
      },
    );
  }

  static Widget _menuButton({
    required Size buttonSize,
    required Widget image,
    Widget? subtitle,
    required VoidCallback onTap,
  }) =>
      MTButton(
        minSize: buttonSize,
        constrained: false,
        color: b3Color,
        type: MTButtonType.main,
        middle: Column(
          mainAxisSize: MainAxisSize.min,
          children: [image, if (subtitle != null) subtitle],
        ),
        onTap: onTap,
      );

  static Widget _buttonStopSleep(HistoryController hc, dynamic baby, Size buttonSize) => _menuButton(
        buttonSize: buttonSize,
        image: BabyPresenter(baby).face(size: 90),
        subtitle: SmallText(baby.isBoy ? loc.action_stop_sleep_title_boy : loc.action_stop_sleep_title_girl),
        onTap: () => hc.stopSleep(now),
      );

  static Widget _buttonStartSleep(HistoryController hc, Size buttonSize) => _menuButton(
        buttonSize: buttonSize,
        image: const MTSvgImage('bed', height: 90),
        subtitle: hc.hasSleepEntriesFor24Hours ? SmallText(hc.lastSleep!.end.strTimeAgo) : null,
        onTap: () => hc.babyIsEating ? hc.stopBreastFeedAndStartSleep(now) : hc.startSleep(now),
      );

  static Widget _buttonStopFeed(HistoryController hc, dynamic baby, Size buttonSize) => _menuButton(
        buttonSize: buttonSize,
        image: BabyPresenter(baby).face(size: 90),
        subtitle: SmallText(baby.isBoy ? loc.action_stop_feed_title_boy : loc.action_stop_feed_title_girl),
        onTap: () => hc.stopBreastFeed(now),
      );

  static Widget _buttonAddFeed(HistoryController hc, Size buttonSize) => _menuButton(
        buttonSize: buttonSize,
        image: MTSvgImage(hc.hasFeedEntriesFor24Hours ? hc.lastFeed!.feedImageName : 'bottle_baby_formula', height: 90),
        subtitle: hc.hasFeedEntriesFor24Hours ? SmallText(hc.lastFeed!.end.strTimeAgo) : null,
        onTap: () => hc.addFeed(),
      );
}
