// Copyright (c) 2024. Alexandr Moroz

import 'package:url_launcher/url_launcher_string.dart';

import '../../L3_app/views/app/services.dart';
import '../services/platform.dart';

const _host = 'https://moroz.team';
const _contactUsMailAddress = 'hello@mamagochi.ru';

const docsPath = '$_host/mamagochi/docs/';

const feedbackUrlString = '$_host/mamagochi/feedback';
const legalConfidentialUrlString = '$_host/legal/confidential';
const legalRulesUrlString = '$_host/mamagochi/legal/rules';
const releaseNotesUrlString = '$_host/mamagochi/changelog';
const tariffsUrlString = '$_host/mamagochi/tariffs';
const telegramUrlString = 'https://t.me/mamagochi';
const vkUrlString = 'https://vk.com/morozteamnews';
const homepageUrlString = '$_host/mamagochi';

// const _appAppStoreUrlString = 'https://apps.apple.com/app/mamagochi/id1661313266';
// const _appGooglePlayUrlString = 'https://play.google.com/store/apps/details?id=team.moroz.mamagochi';

// String get appInstallUrlString => isIOS ? _appAppStoreUrlString : _appGooglePlayUrlString;

Future<bool> sendMail(String subject, String appIdentifier, int? userId, {String? text = ''}) async {
  final body = ''
      '$text'
      '\r\n-----'
      '\r\n$appIdentifier'
      '\r\n$deviceModelName'
      '\r\n$deviceSystemInfo'
      '\r\nUserId:$userId'
      '\r\n';

  final url = Uri.encodeFull('mailto:$_contactUsMailAddress?subject=${loc.contact_us_mail_subject}&body=$body');
  return await launchUrlString(url);
}
