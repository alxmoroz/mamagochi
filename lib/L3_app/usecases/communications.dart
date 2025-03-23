// Copyright (c) 2024. Alexandr Moroz

import 'package:url_launcher/url_launcher_string.dart';

import '../../L2_data/repositories/communications_repo.dart';
import '../presenters/communications.dart';
import '../views/app/services.dart';

Future<bool> mailUs({String? subject, String? text}) async {
  return await sendMail(
    subject ?? loc.contact_us_mail_subject,
    appIdentifier,
    null,
    text: text,
  );
}

// Future go2AppInstall() async => await launchUrlString(appInstallUrlString);

Future go2LegalRules() async => await launchUrlString(legalRulesUrlString);
Future go2LegalConfidential() async => await launchUrlString(legalConfidentialUrlString);

Future go2ReleaseNotes() async => await launchUrlString(releaseNotesUrlString);
Future go2Feedback() async => await launchUrlString(feedbackUrlString);
Future go2Telegram() async => await launchUrlString(telegramUrlString);
Future go2VK() async => await launchUrlString(vkUrlString);
Future go2Homepage() async => await launchUrlString(homepageUrlString);
