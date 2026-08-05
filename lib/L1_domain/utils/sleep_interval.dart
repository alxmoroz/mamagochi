// Copyright (c) 2026. Alexandr Moroz

import '../entities/sleep.dart';

/// Максимальная длительность сна без завершения — дольше считаем запись «зависшей».
const maxPlausibleOngoingSleep = Duration(hours: 24);

/// Единственный текущий сон без endDate, если он правдоподобен и не опровергнут более поздними записями.
/// При нескольких незакрытых выбирается самый новый по start (затем created).
Sleep? findOngoingSleep(Iterable<Sleep> sleeps, DateTime at) {
  final unfinished = sleeps.where((s) => s.isStillSleeping).toList();
  if (unfinished.isEmpty) return null;

  unfinished.sort((a, b) {
    final byStart = b.start.compareTo(a.start);
    if (byStart != 0) return byStart;
    return b.created.compareTo(a.created);
  });

  for (final candidate in unfinished) {
    if (at.difference(candidate.start) > maxPlausibleOngoingSleep) continue;

    final hasLaterCompleted = sleeps.any(
      (other) => !other.isStillSleeping && other.end.isAfter(candidate.start),
    );
    if (hasLaterCompleted) continue;

    return candidate;
  }

  return null;
}

/// Конец сна для расчёта пересечений и статистики.
DateTime effectiveSleepEnd(Sleep sleep, Iterable<Sleep> all, DateTime at, {Sleep? ongoingSleep}) {
  if (!sleep.isStillSleeping) return sleep.end;

  final ongoing = ongoingSleep ?? findOngoingSleep(all, at);
  if (ongoing != null && ongoing.created.isAtSameMomentAs(sleep.created)) {
    return at;
  }

  // Забытый незакрытый сон: длительность неизвестна → не считаем до now.
  return sleep.start;
}

bool isStaleUnfinishedSleep(Sleep sleep, Iterable<Sleep> all, DateTime at, {Sleep? ongoingSleep}) {
  if (!sleep.isStillSleeping) return false;
  final ongoing = ongoingSleep ?? findOngoingSleep(all, at);
  return ongoing == null || !ongoing.created.isAtSameMomentAs(sleep.created);
}

/// Незакрытые сны, которые нужно закрыть на reload: старше 24ч и дубли кроме текущего newest.
List<Sleep> sleepsToAutoCloseOnReload(Iterable<Sleep> all, DateTime at) {
  final ongoing = findOngoingSleep(all, at);
  return all.where((s) => isStaleUnfinishedSleep(s, all, at, ongoingSleep: ongoing)).toList();
}

List<Sleep> staleUnfinishedSleeps(Iterable<Sleep> all, DateTime at) => sleepsToAutoCloseOnReload(all, at);

/// Конец при автозакрытии: не угадываем время — пишем start.
DateTime closedEndDateForStaleSleep(Sleep sleep, [Iterable<Sleep>? all]) => sleep.start;
