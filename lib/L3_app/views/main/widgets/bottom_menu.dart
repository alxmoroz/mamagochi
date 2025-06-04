// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../L1_domain/utils/dates.dart';
import '../../../components/button.dart';
import '../../../components/colors.dart';
import '../../../components/images.dart';
import '../../../components/text.dart';
import '../../../presenters/baby.dart';
import '../../../presenters/date.dart';
import '../../app/services.dart';
import '../../history/history_controller.dart';

class BottomMenu extends StatelessWidget implements PreferredSizeWidget {
  const BottomMenu({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(250);

  Future _startSleep(HistoryController hc) async {
    DateTime? startDate = now;
    hc.startSleep(startDate);
  }

  Future _stopSleep(HistoryController hc) async {
    DateTime? endDate = now;
    hc.stopSleep(endDate);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final hc = mainController.selectedBabyController?.historyController;
      final baby = mainController.selectedBabyController?.baby;

      return hc != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                hc.babyIsSleeping
                    ? MTButton(
                        minSize: const Size(180, 180),
                        constrained: false,
                        color: b3Color,
                        type: MTButtonType.main,
                        middle: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            baby.image(size: 100),
                            SmallText(baby!.isBoy ? loc.action_stop_sleep_title_boy : loc.action_stop_sleep_title_girl),
                          ],
                        ),
                        onTap: () => _stopSleep(hc),
                      )
                    : MTButton(
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
