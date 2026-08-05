import 'package:flutter_test/flutter_test.dart';
import 'package:mamagochi/L1_domain/entities/feed.dart';
import 'package:mamagochi/L1_domain/utils/feed_interval.dart';
import 'package:mamagochi/L3_app/views/history/day_summary.dart';

void main() {
  final babyCreated = DateTime(2024, 1, 1);

  Feed breast({
    required DateTime created,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      Feed(
        created: created,
        startDate: startDate,
        endDate: endDate,
        babyCreatedTime: babyCreated,
        type: FeedingType.left_breast,
      );

  final at = DateTime(2026, 7, 4, 15, 0);

  test('stale unfinished breast feed is not treated as ongoing', () {
    final feeds = [
      breast(
        created: DateTime(2026, 6, 1, 10),
        startDate: DateTime(2026, 6, 1, 10),
      ),
    ];

    expect(findOngoingBreastFeed(feeds, at), isNull);
    expect(feedsToAutoCloseOnReload(feeds, at).single.created, DateTime(2026, 6, 1, 10));
    expect(effectiveFeedEnd(feeds.single, feeds, at), DateTime(2026, 6, 1, 10));
  });

  test('current ongoing breast feed counts until now', () {
    final feeds = [
      breast(
        created: DateTime(2026, 7, 4, 14, 30),
        startDate: DateTime(2026, 7, 4, 14, 30),
      ),
    ];

    expect(findOngoingBreastFeed(feeds, at), isNotNull);
    expect(effectiveFeedEnd(feeds.single, feeds, at), at);
  });

  test('reload closes older unfinished breast under 24h, keeps newest', () {
    final older = breast(
      created: DateTime(2026, 7, 4, 10),
      startDate: DateTime(2026, 7, 4, 10),
    );
    final newer = breast(
      created: DateTime(2026, 7, 4, 12),
      startDate: DateTime(2026, 7, 4, 12),
    );

    expect(feedsToAutoCloseOnReload([older, newer], at), [older]);
    expect(findOngoingBreastFeed([older, newer], at), newer);
  });

  test('day summary does not count stale breast until now', () {
    final feeds = [
      breast(
        created: DateTime(2026, 6, 10, 22),
        startDate: DateTime(2026, 6, 10, 22),
      ),
    ];

    final summary = DaySummary.calculate(
      date: DateTime(2026, 7, 2),
      sleepEntries: const [],
      feedEntries: feeds,
      referenceTime: at,
    );

    expect(summary.showBreastRow, isFalse);
    expect(summary.breastDuration, Duration.zero);
  });

  test('closed end date for stale feed equals start', () {
    final feed = breast(
      created: DateTime(2026, 7, 1, 10),
      startDate: DateTime(2026, 7, 1, 10),
    );
    expect(closedEndDateForStaleFeed(feed), DateTime(2026, 7, 1, 10));
  });
}
