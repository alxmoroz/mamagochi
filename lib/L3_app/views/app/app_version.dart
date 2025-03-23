// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/cupertino.dart';

import '../../../L2_data/services/environment.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/text.dart';
import 'services.dart';

class AppVersion extends StatelessWidget {
  const AppVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DSmallText(localSettingsController.settings.version, color: f2Color),
        if (visibleApiHost.isNotEmpty) BaseText.medium(visibleApiHost, color: dangerColor, padding: const EdgeInsets.only(left: P2)),
      ],
    );
  }
}
