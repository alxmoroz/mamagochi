// Copyright (c) 2022. Alexandr Moroz

import '../../L1_domain/utils/dates.dart';
import '../views/app/services.dart';

const _DAYS_IN_YEAR = 365.0;
const _DAYS_IN_WEEK = 7.0;

extension DurationPresenter on Duration {
  num get _inWeeks => inDays / _DAYS_IN_WEEK;
  num get _inMonths => inDays / DAYS_IN_MONTH;
  num get _inYears => inDays / _DAYS_IN_YEAR;
  String get localizedString => _inYears >= 1
      ? loc.years_count(_inYears.round())
      : _inMonths >= 1
      ? loc.months_count(_inMonths.round())
      : _inWeeks >= 2
      ? loc.weeks_count_accusative(_inWeeks.round())
      : loc.days_count(inDays);

  String get strInHoursAndMinutes {
    String result = '';
    int hours = inHours;
    int minutes = inMinutes - inHours * 60;
    if (inMinutes < 1) {
      result = '';
    } else if (hours < 1) {
      result = loc.time_minutes(minutes);
    } else {
      result = minutes > 0 ? loc.time_hours_minutes(hours, minutes) : loc.time_hours(hours);
    }
    return result;
  }

  /// Часы, минуты и секунды. При нулевых секундах используется strInHoursAndMinutes.
  /// Иначе собирается строка из ненулевых частей: «1 ч», «1 ч 30 с», «15 мин 30 с», «1 ч 15 мин 30 с» и т.п.
  String get strInHoursMinutesAndSeconds {
    final totalSeconds = inSeconds;
    if (totalSeconds == 0) return '';
    final seconds = totalSeconds % 60;
    if (seconds == 0) return strInHoursAndMinutes;

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final parts = <String>[if (hours > 0) loc.time_hours(hours), if (minutes > 0) loc.time_minutes(minutes), loc.time_seconds(seconds)];
    return parts.join(' ');
  }
}
