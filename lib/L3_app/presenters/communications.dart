// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/cupertino.dart';

import '../components/button.dart';
import '../components/colors.dart';
import '../components/constants.dart';
import '../components/icons.dart';
import '../usecases/communications.dart';
import '../views/app/services.dart';

String get appIdentifier => '${loc.app_title} ${localSettingsController.settings.version}';

class ReportErrorButton extends StatelessWidget {
  const ReportErrorButton(this.errorText, {super.key});
  final String errorText;

  @override
  Widget build(BuildContext context) {
    return MTButton.secondary(
      leading: const MailIcon(color: mainColor, size: P4),
      titleText: loc.report_bug_action_title,
      margin: const EdgeInsets.only(top: P3),
      onTap: () => mailUs(text: errorText),
    );
  }
}
