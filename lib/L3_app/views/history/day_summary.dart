import '../../../L1_domain/entities/feed.dart';
import '../../../L1_domain/entities/sleep.dart';
import '../../../L1_domain/utils/dates.dart';
import '../../../L1_domain/utils/sleep_interval.dart';

const _minStatDuration = Duration(minutes: 1);

/// Сводка сна и кормлений за календарный день для карточек в истории.
class DaySummary {
  const DaySummary({
    required this.showSleepCard,
    required this.showFeedCard,
    required this.sleepDuration,
    required this.awakeDuration,
    required this.showBreastRow,
    required this.breastDuration,
    required this.showBottleRow,
    required this.bottleCountMl,
  });

  final bool showSleepCard;
  final bool showFeedCard;
  final Duration sleepDuration;
  final Duration awakeDuration;
  final bool showBreastRow;
  final Duration breastDuration;
  final bool showBottleRow;
  final int bottleCountMl;

  factory DaySummary.calculate({
    required DateTime date,
    required Iterable<Sleep> sleepEntries,
    required Iterable<Feed> feedEntries,
    DateTime? referenceTime,
  }) {
    final at = referenceTime ?? now;
    final (dayStart, dayEndExclusive) = _dayBounds(date);
    final ongoingSleep = findOngoingSleep(sleepEntries, at);

    var sleepDuration = Duration.zero;
    var showSleepCard = false;
    for (final sleep in sleepEntries) {
      final overlap = _sleepOverlapWithDay(
        sleep,
        dayStart,
        dayEndExclusive,
        at,
        sleepEntries: sleepEntries,
        ongoingSleep: ongoingSleep,
      );
      if (overlap == null) continue;
      showSleepCard = true;
      sleepDuration += _statOverlap(overlap);
    }

    final dayElapsed = date.date == at.date ? at.difference(date.date) : const Duration(hours: 24);
    final awake = dayElapsed - sleepDuration;
    final awakeDuration = awake.isNegative ? Duration.zero : awake;

    final showBreastRow = feedEntries.any((feed) => _breastFeedIntersectsDay(feed, dayStart, dayEndExclusive, at));
    final breastDuration = feedEntries.where((f) => f.type.isBreast).fold(Duration.zero, (total, feed) {
      final overlap = _breastFeedOverlapWithDay(feed, dayStart, dayEndExclusive, at);
      return overlap == null ? total : total + _statOverlap(overlap);
    });

    final showBottleRow = feedEntries.any((feed) => _bottleFeedBelongsToDay(feed, date));
    final bottleCountMl = feedEntries
        .where((f) => _bottleFeedBelongsToDay(f, date))
        .fold(0, (sum, f) => sum + (f.count ?? 0));

    final showFeedCard = showBreastRow || showBottleRow;

    return DaySummary(
      showSleepCard: showSleepCard,
      showFeedCard: showFeedCard,
      sleepDuration: sleepDuration,
      awakeDuration: awakeDuration,
      showBreastRow: showBreastRow,
      breastDuration: breastDuration,
      showBottleRow: showBottleRow,
      bottleCountMl: bottleCountMl,
    );
  }
}

/// В статистике запись короче 1 минуты считается как 1 минута (только карточки, не список истории).
Duration _statOverlap(Duration overlap) => overlap < _minStatDuration ? _minStatDuration : overlap;

(DateTime dayStart, DateTime dayEndExclusive) _dayBounds(DateTime date) {
  final dayStart = date.date;
  return (dayStart, dayStart.add(const Duration(days: 1)));
}

bool _sleepIntersectsDay(
  Sleep sleep,
  DateTime dayStart,
  DateTime dayEndExclusive,
  DateTime at, {
  required Iterable<Sleep> all,
  Sleep? ongoingSleep,
}) {
  final sleepStart = sleep.start;
  final sleepEnd = effectiveSleepEnd(sleep, all, at, ongoingSleep: ongoingSleep);
  return !sleepEnd.isBefore(dayStart) && sleepStart.isBefore(dayEndExclusive);
}

Duration? _sleepOverlapWithDay(
  Sleep sleep,
  DateTime dayStart,
  DateTime dayEndExclusive,
  DateTime at, {
  required Iterable<Sleep> sleepEntries,
  Sleep? ongoingSleep,
}) {
  if (!_sleepIntersectsDay(
    sleep,
    dayStart,
    dayEndExclusive,
    at,
    all: sleepEntries,
    ongoingSleep: ongoingSleep,
  )) {
    return null;
  }

  final sleepStart = sleep.start;
  final sleepEnd = effectiveSleepEnd(sleep, sleepEntries, at, ongoingSleep: ongoingSleep);

  final overlapStart = sleepStart.isAfter(dayStart) ? sleepStart : dayStart;
  final overlapEnd = sleepEnd.isBefore(dayEndExclusive) ? sleepEnd : dayEndExclusive;

  if (!overlapStart.isBefore(overlapEnd)) return Duration.zero;
  return overlapEnd.difference(overlapStart);
}

/// Бутылочка — точечная запись, день определяется по [Feed.end].
bool _bottleFeedBelongsToDay(Feed feed, DateTime date) => feed.type.isBottle && feed.end.date == date.date;

bool _breastFeedIntersectsDay(Feed feed, DateTime dayStart, DateTime dayEndExclusive, DateTime at) {
  if (!feed.type.isBreast) return false;

  final feedStart = feed.start;
  final feedEnd = feed.isStillFeeding ? at : feed.end;
  return !feedEnd.isBefore(dayStart) && feedStart.isBefore(dayEndExclusive);
}

Duration? _breastFeedOverlapWithDay(Feed feed, DateTime dayStart, DateTime dayEndExclusive, DateTime at) {
  if (!_breastFeedIntersectsDay(feed, dayStart, dayEndExclusive, at)) return null;

  final feedStart = feed.start;
  final feedEnd = feed.isStillFeeding ? at : feed.end;

  final overlapStart = feedStart.isAfter(dayStart) ? feedStart : dayStart;
  final overlapEnd = feedEnd.isBefore(dayEndExclusive) ? feedEnd : dayEndExclusive;

  if (!overlapStart.isBefore(overlapEnd)) return Duration.zero;
  return overlapEnd.difference(overlapStart);
}
