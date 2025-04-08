// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mamagochi/L3_app/components/button.dart';
import 'package:mamagochi/L3_app/components/colors.dart';
import 'package:mamagochi/L3_app/components/images.dart';
import 'package:mamagochi/L3_app/components/text.dart';
import 'package:mamagochi/L3_app/presenters/date.dart';
import 'package:mamagochi/L3_app/views/app/services.dart';

class BottomMenu extends StatelessWidget implements PreferredSizeWidget {
  const BottomMenu({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(250);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Row(
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
                if (historyController.hasSleepEntries) SmallText(historyController.lastSleepEntry!.end.strTimeAgo),
              ],
            ),
            onTap: historyController.addSleep,
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
                if (historyController.hasFeedEntries) SmallText(historyController.lastFeedEntry!.end.strTimeAgo),
              ],
            ),
            onTap: historyController.addFeed,
          ),
        ],
      ),
    );
  }
}
