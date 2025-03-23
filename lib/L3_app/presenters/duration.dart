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
}
