// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mamagochi/L1_domain/utils/dates.dart';
import 'package:mamagochi/L3_app/components/button.dart';
import 'package:mamagochi/L3_app/components/colors.dart';
import 'package:mamagochi/L3_app/components/images.dart';
import 'package:mamagochi/L3_app/components/text.dart';
import 'package:mamagochi/L3_app/presenters/date.dart';
import 'package:mamagochi/L3_app/views/app/services.dart';
import 'package:mamagochi/L3_app/views/history/history_controller.dart';

class BottomMenu extends StatelessWidget implements PreferredSizeWidget {
  const BottomMenu({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(250);

  Future _startSleep(HistoryController hc) async {
    DateTime? startDate = now;
    // вызов диалога редактирования времени
    // if (startDate != null) {
    hc.startSleep(startDate);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final hc = mainController.selectedBabyController?.historyController;
      return hc != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MTButton(
                  minSize: const Size(180, 180),
                  constrained: false,
                  color: b3Color,
                  type: MTButtonType.main,
                  middle: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MTImage('bed', height: 100),
                      if (hc.hasSleepEntriesToday) SmallText(hc.lastSleepEntry!.end.strTimeAgo),
                    ],
                  ),
                  onTap: () => _startSleep(hc),
                ),
                // Spacer(),
                MTButton(
                  minSize: const Size(180, 180),
                  constrained: false,
                  color: b3Color,
                  type: MTButtonType.main,
                  middle: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MTImage('babybottle', height: 100),
                      if (hc.hasFeedEntriesToday) SmallText(hc.lastFeedEntry!.end.strTimeAgo),
                    ],
                  ),
                  onTap: hc.addFeed,
                ),
              ],
            )
          : const SizedBox();
    });
  }
}
