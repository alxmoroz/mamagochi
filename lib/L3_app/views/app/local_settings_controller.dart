// Copyright (c) 2024. Alexandr Moroz

import 'package:mobx/mobx.dart';

import '../../../L1_domain/entities/app_local_settings.dart';
import '../../../L1_domain/utils/dates.dart';
import '../../../L2_data/services/platform.dart';
import 'services.dart';

part 'local_settings_controller.g.dart';

class LocalSettingsController extends _LocalSettingsControllerBase with _$LocalSettingsController {
  Future<LocalSettingsController> init() async {
    // await dotenv.load(fileName: kReleaseMode ? 'assets/.env' : 'assets/.debug.env');

    settings = await localSettingsUC.settings();
    oldVersion = settings.version;
    settings = await localSettingsUC.updateSettingsFromLaunch(packageInfo.version);

    return this;
  }
}

abstract class _LocalSettingsControllerBase with Store {
  @observable
  AppLocalSettings settings = AppLocalSettings();

  @observable
  String oldVersion = '';
  @action
  void resetOldVersionFlag() => oldVersion = '';

  @computed
  bool get isNewVersion => oldVersion.isNotEmpty && oldVersion != settings.version;

  @computed
  int get buildNumber => int.parse(settings.version.split('.').lastOrNull ?? '0');

  /// Дата предложения обновиться (неделя), если не обновился ещё
  @computed
  DateTime? get _appUpgradeProposalDate => settings.getDate(ALSDateCode.APP_UPGRADE_PROPOSAL);
  @computed
  bool get canProposeAppUpgrade => _appUpgradeProposalDate == null || _appUpgradeProposalDate!.isBefore(lastWeek);

  @action
  Future setAppUpgradeProposalDate() async => settings = await localSettingsUC.setDate(ALSDateCode.APP_UPGRADE_PROPOSAL, now);

  @action
  Future resetAppUpgradeProposalDate() async => settings = await localSettingsUC.setDate(ALSDateCode.APP_UPGRADE_PROPOSAL, null);

  /// Обработка диплинков
  @action
  Future parseQueryParameter(Uri uri, String key, String settingsCode) async {
    final params = uri.queryParameters;
    if (params.containsKey(key)) {
      settings = await localSettingsUC.setString(settingsCode, params[key]);
    }
  }

  @action
  Future parseMainQuery(Uri uri) async {
    final params = uri.queryParameters;
    if (params.keys.any((k) => k.startsWith('utm'))) {
      settings = await localSettingsUC.setString(ALSStringCode.UTM_QUERY, uri.query);
    }
  }

  /// Реклама
  @computed
  String? get utmQuery => settings.getString(ALSStringCode.UTM_QUERY);
  @computed
  bool get hasUTM => utmQuery != null && utmQuery!.isNotEmpty;
  @action
  Future deleteUTM() async => settings = await localSettingsUC.setString(ALSStringCode.UTM_QUERY, null);

  @action
  Future markBreastFeedHintShown() async =>
      settings = await localSettingsUC.setString(ALSStringCode.BREAST_FEED_HINT_DISMISSED, 'true');

  @action
  Future markSleepHintShown() async =>
      settings = await localSettingsUC.setString(ALSStringCode.SLEEP_HINT_DISMISSED, 'true');

  bool wasBirthdayCongratsShownToday(DateTime babyCreated) {
    final shown = settings.getDate(ALSDateCode.birthdayCongratsShown(babyCreated));
    return shown?.date == today;
  }

  @action
  Future markBirthdayCongratsShown(DateTime babyCreated) async =>
      settings = await localSettingsUC.setDate(ALSDateCode.birthdayCongratsShown(babyCreated), today);

  /// Токен регистрации
  // @computed
  // String? get registrationToken => settings.getString(ALSStringCode.REGISTRATION_TOKEN);
  // @computed
  // bool get hasRegistration => registrationToken != null && registrationToken!.isNotEmpty;
  // @action
  // Future deleteRegistrationToken() async => settings = await localSettingsUC.setString(ALSStringCode.REGISTRATION_TOKEN, null);
}
