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
    if (minutes < 1) {
      result = 'только что';
    } else if (hours < 1) {
      result = '$minutes мин назад';
    } else if (duration.inDays < 1) {
      final mStr = minutes > 0 ? ' $minutes мин' : '';
      result = '$hours ч$mStr назад';
    } else {
      result = 'давно';
    }
    return result;
  }

  String get strShort => thisYear ? DateFormat.Md().format(this) : DateFormat.yMd().format(this);
  String get strMedium => date == yesterday
      ? loc.yesterday_date_title
      : date == today
          ? loc.today_title.toLowerCase()
          : date == tomorrow
              ? loc.tomorrow_title.toLowerCase()
              : thisYear
                  ? DateFormat.MMMMd().format(this)
                  : DateFormat.yMMMMd().format(this);
}
