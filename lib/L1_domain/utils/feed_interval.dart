// Copyright (c) 2026. Alexandr Moroz

import '../entities/feed.dart';

/// Максимальная длительность грудного кормления без завершения — дольше считаем запись «зависшей».
const maxPlausibleOngoingFeed = Duration(hours: 24);

/// Единственное текущее грудное кормление без endDate, если оно правдоподобно.
/// При нескольких незакрытых выбирается самое новое по start (затем created).
Feed? findOngoingBreastFeed(Iterable<Feed> feeds, DateTime at) {
  final unfinished = feeds.where((f) => f.isStillFeeding).toList();
  if (unfinished.isEmpty) return null;

  unfinished.sort((a, b) {
    final byStart = b.start.compareTo(a.start);
    if (byStart != 0) return byStart;
    return b.created.compareTo(a.created);
  });

  for (final candidate in unfinished) {
    if (at.difference(candidate.start) > maxPlausibleOngoingFeed) continue;
    return candidate;
  }

  return null;
}

/// Конец кормления для расчёта статистики.
DateTime effectiveFeedEnd(Feed feed, Iterable<Feed> all, DateTime at, {Feed? ongoingFeed}) {
  if (!feed.isStillFeeding) return feed.end;

  final ongoing = ongoingFeed ?? findOngoingBreastFeed(all, at);
  if (ongoing != null && ongoing.created.isAtSameMomentAs(feed.created)) {
    return at;
  }

  return feed.start;
}

bool isStaleUnfinishedFeed(Feed feed, Iterable<Feed> all, DateTime at, {Feed? ongoingFeed}) {
  if (!feed.isStillFeeding) return false;
  final ongoing = ongoingFeed ?? findOngoingBreastFeed(all, at);
  return ongoing == null || !ongoing.created.isAtSameMomentAs(feed.created);
}

/// Незакрытые груди на закрытие при reload: старше 24ч и дубли кроме текущего newest.
List<Feed> feedsToAutoCloseOnReload(Iterable<Feed> all, DateTime at) {
  final ongoing = findOngoingBreastFeed(all, at);
  return all.where((f) => isStaleUnfinishedFeed(f, all, at, ongoingFeed: ongoing)).toList();
}

/// Конец при автозакрытии: не угадываем время — пишем start.
DateTime closedEndDateForStaleFeed(Feed feed) => feed.start;
