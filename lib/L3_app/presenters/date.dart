// Copyright (c) 2024. Alexandr Moroz

import 'package:intl/intl.dart';

import '../../L1_domain/utils/dates.dart';
import '../views/app/services.dart';

extension DateFormatterPresenter on DateTime {
  String get strTime => DateFormat.Hm().format(this);
  String get strTimeAgo {
    final duration = DateTime.now().difference(this);
    String result = '';
    int hours = duration.inHours;
    int minutes = duration.inMinutes - hours * 60;
    if (duration.inMinutes < 1) {
      result = loc.time_just_now;
    } else if (hours < 1) {
      result = loc.time_minutes_ago(minutes);
    } else if (hours < 24) {
      result = minutes > 0 ? loc.time_hours_minutes_ago(hours, minutes) : loc.time_hours_ago(hours);
    } else {
      result = strTime;
    }
    return result;
  }

  String get strShort => thisYear ? DateFormat.Md().format(this) : DateFormat.yMd().format(this);
  String get strMedium => isYesterday
      ? loc.yesterday_date_title
      : isToday
          ? loc.today_title
          : isTomorrow
              ? loc.tomorrow_title
              : thisYear
                  ? DateFormat.MMMMd().format(this)
                  : DateFormat.yMMMMd().format(this);
}
