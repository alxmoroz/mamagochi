// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/cupertino.dart';

import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/images.dart';
import '../../components/text.dart';
import 'services.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: P6,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MTImage(ImageName.app_icon.name, height: P6, width: P6),
          if (!compact) DecorAppTitle(loc.app_title.substring(1), color: f2Color, padding: const EdgeInsets.only(top: 12, left: 1)),
        ],
      ),
    );
  }
}
