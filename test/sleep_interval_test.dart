import 'package:flutter_test/flutter_test.dart';
import 'package:mamagochi/L1_domain/entities/sleep.dart';
import 'package:mamagochi/L1_domain/utils/sleep_interval.dart';
import 'package:mamagochi/L3_app/views/history/day_summary.dart';

void main() {
  final babyCreated = DateTime(2024, 1, 1);

  Sleep sleep({
    required DateTime created,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      Sleep(created: created, startDate: startDate, endDate: endDate, babyCreatedTime: babyCreated);

  final at = DateTime(2026, 7, 4, 15, 0);

  test('stale unfinished sleep is not treated as ongoing', () {
    final sleeps = [
      sleep(
        created: DateTime(2026, 6, 1, 10),
        startDate: DateTime(2026, 6, 1, 10),
      ),
      sleep(
        created: DateTime(2026, 7, 1, 8),
        startDate: DateTime(2026, 7, 1, 7),
        endDate: DateTime(2026, 7, 1, 9),
      ),
    ];

    expect(findOngoingSleep(sleeps, at), isNull);
    expect(staleUnfinishedSleeps(sleeps, at).length, 1);
  });

  test('day summary does not count stale sleep until now', () {
    final sleeps = [
      sleep(
        created: DateTime(2026, 6, 10, 22),
        startDate: DateTime(2026, 6, 10, 22),
      ),
      sleep(
        created: DateTime(2026, 7, 2, 8),
        startDate: DateTime(2026, 7, 2, 7),
        endDate: DateTime(2026, 7, 2, 9),
      ),
    ];

    final summary = DaySummary.calculate(
      date: DateTime(2026, 7, 2),
      sleepEntries: sleeps,
      feedEntries: const [],
      referenceTime: at,
    );

    expect(summary.sleepDuration.inHours, lessThan(24));
  });

  test('current ongoing sleep counts until now', () {
    final sleeps = [
      sleep(
        created: DateTime(2026, 7, 4, 13),
        startDate: DateTime(2026, 7, 4, 13),
      ),
    ];

    expect(findOngoingSleep(sleeps, at), isNotNull);
    expect(effectiveSleepEnd(sleeps.single, sleeps, at), at);
  });

  test('inferred end uses next sleep start', () {
    final stale = sleep(
      created: DateTime(2026, 7, 1, 10),
      startDate: DateTime(2026, 7, 1, 10),
    );
    final next = sleep(
      created: DateTime(2026, 7, 1, 14),
      startDate: DateTime(2026, 7, 1, 14),
      endDate: DateTime(2026, 7, 1, 15),
    );

    expect(inferredStaleSleepEnd(stale, [stale, next]), DateTime(2026, 7, 1, 14));
  });
}
