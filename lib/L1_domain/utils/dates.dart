// Copyright (c) 2023. Alexandr Moroz

const YEAR = Duration(days: 365);
const DAYS_IN_MONTH = 30.41666;

DateTime get now => DateTime.now();
DateTime get yesterday => DateTime(now.year, now.month, now.day - 1);
DateTime get today => DateTime(now.year, now.month, now.day);
DateTime get tomorrow => DateTime(now.year, now.month, now.day + 1);
DateTime get nextWeek => DateTime(now.year, now.month, now.day + 7);
DateTime get lastWeek => DateTime(now.year, now.month, now.day - 7);

extension DateUtils on DateTime {
  DateTime get date => DateTime(year, month, day);
  bool get thisYear => year == now.year;
}
