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

/// Промежутки бодрствования между снами и после последнего завершённого сна.
List<AwakePeriod> calculateAwakePeriods(Iterable<Sleep> sleeps, DateTime referenceTime) {
  final sorted = sleeps.toList()..sort((a, b) => a.start.compareTo(b.start));
  final periods = <AwakePeriod>[];

  for (var i = 0; i < sorted.length; i++) {
    final sleep = sorted[i];
    if (sleep.isStillSleeping) continue;

    final wakeStart = sleep.end;
    final DateTime? wakeEnd;
    final bool isOngoing;

    if (i + 1 < sorted.length) {
      wakeEnd = sorted[i + 1].start;
      isOngoing = false;
    } else {
      wakeEnd = null;
      isOngoing = true;
    }

    final wakeEndOrNow = wakeEnd ?? referenceTime;
    if (!wakeStart.isBefore(wakeEndOrNow)) continue;

    periods.add(AwakePeriod(start: wakeStart, end: wakeEnd, isOngoing: isOngoing));
  }

  return periods;
}

AwakePeriod? clipAwakePeriodToDay(AwakePeriod period, DateTime date, DateTime referenceTime) {
  final (dayStart, dayEndExclusive) = dayBounds(date);
  final periodEnd = period.isOngoing ? referenceTime : period.end!;

  final overlapStart = period.start.isAfter(dayStart) ? period.start : dayStart;
  final overlapEnd = periodEnd.isBefore(dayEndExclusive) ? periodEnd : dayEndExclusive;
  if (!overlapStart.isBefore(overlapEnd)) return null;

  final isOngoing = period.isOngoing && overlapEnd.isAtSameMomentAs(periodEnd);

  return AwakePeriod(
    start: overlapStart,
    end: isOngoing ? null : overlapEnd,
    isOngoing: isOngoing,
  );
}

List<AwakePeriod> awakePeriodsForDay(DateTime date, Iterable<Sleep> sleeps, DateTime referenceTime) {
  if (!dayHasSleep(date, sleeps, referenceTime)) return const [];

  return calculateAwakePeriods(sleeps, referenceTime)
      .map((period) => clipAwakePeriodToDay(period, date, referenceTime))
      .whereType<AwakePeriod>()
      .where((period) => period.isMoreMinute)
      .toList();
}
