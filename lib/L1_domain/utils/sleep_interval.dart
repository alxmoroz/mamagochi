// Copyright (c) 2026. Alexandr Moroz

import '../entities/sleep.dart';
import 'dates.dart';

/// Максимальная длительность сна без завершения — дольше считаем запись «зависшей».
const maxPlausibleOngoingSleep = Duration(hours: 24);

/// Единственный текущий сон без endDate, если он правдоподобен и не опровергнут более поздними записями.
Sleep? findOngoingSleep(Iterable<Sleep> sleeps, DateTime at) {
  final unfinished = sleeps.where((s) => s.isStillSleeping).toList();
  if (unfinished.isEmpty) return null;

  unfinished.sort((a, b) => b.start.compareTo(a.start));
  final candidate = unfinished.first;

  if (at.difference(candidate.start) > maxPlausibleOngoingSleep) return null;

  final hasLaterCompleted = sleeps.any(
    (other) => !other.isStillSleeping && other.end.isAfter(candidate.start),
  );
  if (hasLaterCompleted) return null;

  if (unfinished.length > 1) return null;

  return candidate;
}

/// Конец сна для расчёта пересечений и статистики.
DateTime effectiveSleepEnd(Sleep sleep, Iterable<Sleep> all, DateTime at, {Sleep? ongoingSleep}) {
  if (!sleep.isStillSleeping) return sleep.end;

  final ongoing = ongoingSleep ?? findOngoingSleep(all, at);
  if (ongoing != null && ongoing.created.isAtSameMomentAs(sleep.created)) {
    return at;
  }

  return inferredStaleSleepEnd(sleep, all);
}

DateTime inferredStaleSleepEnd(Sleep sleep, Iterable<Sleep> all) {
  final sorted = all.toList()..sort((a, b) => a.start.compareTo(b.start));
  final index = sorted.indexWhere((s) => s.created.isAtSameMomentAs(sleep.created));

  if (index >= 0) {
    for (var i = index + 1; i < sorted.length; i++) {
      if (sorted[i].start.isAfter(sleep.start)) return sorted[i].start;
    }
  }

  return sleep.start.date.add(const Duration(days: 1));
}

bool isStaleUnfinishedSleep(Sleep sleep, Iterable<Sleep> all, DateTime at, {Sleep? ongoingSleep}) {
  if (!sleep.isStillSleeping) return false;
  final ongoing = ongoingSleep ?? findOngoingSleep(all, at);
  return ongoing == null || !ongoing.created.isAtSameMomentAs(sleep.created);
}

List<Sleep> staleUnfinishedSleeps(Iterable<Sleep> all, DateTime at) {
  final ongoing = findOngoingSleep(all, at);
  return all.where((s) => isStaleUnfinishedSleep(s, all, at, ongoingSleep: ongoing)).toList();
}

DateTime closedEndDateForStaleSleep(Sleep sleep, Iterable<Sleep> all) {
  final end = inferredStaleSleepEnd(sleep, all);
  if (end.isAfter(sleep.start)) return end;
  return sleep.start.add(const Duration(minutes: 1));
}
