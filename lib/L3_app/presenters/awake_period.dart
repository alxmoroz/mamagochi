// Copyright (c) 2026. Alexandr Moroz

import 'package:flutter/cupertino.dart';

import '../../L1_domain/entities/awake_period.dart';
import '../components/images.dart';
import '../presenters/date.dart';
import '../presenters/duration.dart';
import '../views/app/services.dart';

extension AwakePeriodPresenter on AwakePeriod {
  Widget awakeImage({double? size}) => MTSvgImage('sun_with_face', height: size, width: size);

  String get historyTitle => loc.history_awake_title;

  String get historyDuration => duration.strInHoursAndMinutes;

  String get historyTrailingTimeTitle => isOngoing ? historySinceTitle : historyStartEndTimeTitle;

  String get historySinceTitle => loc.history_awake_since(start.strTime);

  String get historyStartEndTimeTitle => isMoreMinute ? '$startTitle\n$endTitle' : startTitle;

  String get startTitle => start.strTime;

  String get endTitle => end?.strTime ?? '';
}
