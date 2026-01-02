// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../../L1_domain/utils/dates.dart';
import '../../components/button.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/dialog.dart';
import '../../components/divider.dart';
import '../../components/icons.dart';
import '../../components/images.dart';
import '../../components/list_tile.dart';
import '../../components/text.dart';
import '../../usecases/communications.dart';
import 'app_version.dart';
import 'services.dart';

Future showAboutServiceDialog() async => await showMTDialog(const _AboutDialog(), maxWidth: SCR_XS_WIDTH);

class _AboutDialog extends StatelessWidget {
  const _AboutDialog();

  static const _dividerIndent = P5 + DEF_TAPPABLE_ICON_SIZE;
  static const _contactIconSize = kIsWeb ? P6 : P8;

  @override
  Widget build(BuildContext context) {
    return MTDialog(
      body: ListView(
        shrinkWrap: true,
        children: [
          /// версия
          const AppVersion(),

          /// юр. документы
          MTListGroupTitle(titleText: loc.app_legal_docs_title),
          MTListTile(
            leading: const DocumentIcon(),
            titleText: loc.app_legal_rules_title,
            trailing: const LinkOutIcon(),
            dividerIndent: _dividerIndent,
            onTap: go2LegalRules,
          ),
          MTListTile(
            leading: const PrivacyIcon(),
            titleText: loc.app_legal_privacy_policy_title,
            trailing: const LinkOutIcon(),
            bottomDivider: false,
            onTap: go2LegalConfidential,
          ),

          /// о приложении
          MTListGroupTitle(titleText: loc.app_about_title),
          MTListTile(
            leading: const ReleaseNotesIcon(),
            titleText: loc.app_release_notes_title,
            trailing: const LinkOutIcon(),
            dividerIndent: _dividerIndent,
            onTap: go2ReleaseNotes,
          ),
          MTListTile(
            leading: const FeedbackIcon(),
            titleText: loc.app_feedback_action_title,
            trailing: const LinkOutIcon(),
            bottomDivider: false,
            onTap: go2Feedback,
          ),

          /// контакты
          const SizedBox(height: P6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MTButton.icon(
                MTImage('telegram_icon', width: _contactIconSize, height: _contactIconSize),
                onTap: go2Telegram,
              ),
              SizedBox(width: P3),
              MTButton.icon(
                MTImage('mail_icon', width: _contactIconSize, height: _contactIconSize),
                onTap: mailUs,
              ),
              SizedBox(width: P3),
              MTButton.icon(
                MTImage('vk_icon', width: _contactIconSize, height: _contactIconSize),
                onTap: go2VK,
              ),
              SizedBox(width: P3),
              MTButton.icon(
                MTImage('web_icon', width: _contactIconSize, height: _contactIconSize),
                onTap: go2Homepage,
              ),
            ],
          ),
          const SizedBox(height: P),

          /// копирайт
          const MTDivider(indent: P3, endIndent: P3, verticalIndent: P3),
          SmallText('© ${now.date.year} Moroz Team', color: f3Color, align: TextAlign.center),
          const SizedBox(height: P_2),
          SmallText('© ${now.date.year} ${loc.app_title}', color: f3Color, align: TextAlign.center),
        ],
      ),
      forceBottomPadding: true,
    );
  }
}
