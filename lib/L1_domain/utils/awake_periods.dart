// Copyright (c) 2026. Alexandr Moroz

import '../entities/awake_period.dart';
import '../entities/sleep.dart';
import 'dates.dart';

(DateTime dayStart, DateTime dayEndExclusive) dayBounds(DateTime date) {
  final dayStart = date.date;
  return (dayStart, dayStart.add(const Duration(days: 1)));
}

bool sleepIntersectsDay(Sleep sleep, DateTime dayStart, DateTime dayEndExclusive, DateTime at) {
  final sleepStart = sleep.start;
  final sleepEnd = sleep.isStillSleeping ? at : sleep.end;
  return !sleepEnd.isBefore(dayStart) && sleepStart.isBefore(dayEndExclusive);
}

bool dayHasSleep(DateTime date, Iterable<Sleep> sleeps, DateTime at) {
  final (dayStart, dayEndExclusive) = dayBounds(date);
  return sleeps.any((sleep) => sleepIntersectsDay(sleep, dayStart, dayEndExclusive, at));
}

List<(DateTime start, DateTime end)> _sleepIntervalsInDay(
  DateTime date,
  Iterable<Sleep> sleeps,
  DateTime referenceTime,
) {
  final (dayStart, dayEndExclusive) = dayBounds(date);
  final intervals = <(DateTime, DateTime)>[];

  for (final sleep in sleeps) {
    if (!sleepIntersectsDay(sleep, dayStart, dayEndExclusive, referenceTime)) continue;

    final sleepEnd = sleep.isStillSleeping ? referenceTime : sleep.end;
    final start = sleep.start.isAfter(dayStart) ? sleep.start : dayStart;
    final end = sleepEnd.isBefore(dayEndExclusive) ? sleepEnd : dayEndExclusive;
    if (start.isBefore(end)) intervals.add((start, end));
  }

  intervals.sort((a, b) => a.$1.compareTo(b.$1));
  return _mergeIntervals(intervals);
}

List<(DateTime start, DateTime end)> _mergeIntervals(List<(DateTime start, DateTime end)> intervals) {
  if (intervals.isEmpty) return intervals;

  final merged = <(DateTime, DateTime)>[intervals.first];
  for (var i = 1; i < intervals.length; i++) {
    final (start, end) = intervals[i];
    final last = merged.last;
    if (!start.isAfter(last.$2)) {
      if (end.isAfter(last.$2)) {
        merged[merged.length - 1] = (last.$1, end);
      }
    } else {
      merged.add((start, end));
    }
  }
  return merged;
}

List<AwakePeriod> awakePeriodsForDay(DateTime date, Iterable<Sleep> sleeps, DateTime referenceTime) {
  if (!dayHasSleep(date, sleeps, referenceTime)) return const [];

  final (dayStart, dayEndExclusive) = dayBounds(date);
  final isToday = date.date == referenceTime.date;
  final dayEndEffective = isToday ? referenceTime : dayEndExclusive;
  if (!dayStart.isBefore(dayEndEffective)) return const [];

  final sleepIntervals = _sleepIntervalsInDay(date, sleeps, referenceTime);
  final periods = <AwakePeriod>[];
  var cursor = dayStart;

  for (final (sleepStart, sleepEnd) in sleepIntervals) {
    if (cursor.isBefore(sleepStart)) {
      periods.add(AwakePeriod(start: cursor, end: sleepStart, isOngoing: false));
    }
    if (sleepEnd.isAfter(cursor)) cursor = sleepEnd;
  }

  if (cursor.isBefore(dayEndEffective)) {
    periods.add(
      AwakePeriod(
        start: cursor,
        end: isToday ? null : dayEndEffective,
        isOngoing: isToday,
      ),
    );
  }

  return periods.where((period) => period.isMoreMinute).toList();
}
