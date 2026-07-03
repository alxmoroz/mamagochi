import 'package:flutter_test/flutter_test.dart';
import 'package:mamagochi/L1_domain/entities/sleep.dart';
import 'package:mamagochi/L1_domain/utils/awake_periods.dart';

void main() {
  final babyCreated = DateTime(2024, 1, 1);

  Sleep sleep({
    required DateTime created,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      Sleep(created: created, startDate: startDate, endDate: endDate, babyCreatedTime: babyCreated);

  final at = DateTime(2026, 3, 15, 18, 0);

  test('wake period between two sleeps', () {
    final sleeps = [
      sleep(
        created: DateTime(2026, 3, 15, 8),
        startDate: DateTime(2026, 3, 15, 7),
        endDate: DateTime(2026, 3, 15, 9),
      ),
      sleep(
        created: DateTime(2026, 3, 15, 14),
        startDate: DateTime(2026, 3, 15, 11),
        endDate: DateTime(2026, 3, 15, 13),
      ),
    ];

    final periods = calculateAwakePeriods(sleeps, at);

    expect(periods.length, 2);
    expect(periods[0].start, DateTime(2026, 3, 15, 9));
    expect(periods[0].end, DateTime(2026, 3, 15, 11));
    expect(periods[0].isOngoing, isFalse);
    expect(periods[1].isOngoing, isTrue);
    expect(periods[1].start, DateTime(2026, 3, 15, 13));
    expect(periods[1].end, isNull);
  });

  test('no wake after still sleeping', () {
    final sleeps = [
      sleep(
        created: DateTime(2026, 3, 15, 8),
        startDate: DateTime(2026, 3, 15, 7),
        endDate: DateTime(2026, 3, 15, 9),
      ),
      sleep(
        created: DateTime(2026, 3, 15, 16),
        startDate: DateTime(2026, 3, 15, 16),
      ),
    ];

    final periods = calculateAwakePeriods(sleeps, at);

    expect(periods.length, 1);
    expect(periods[0].end, DateTime(2026, 3, 15, 16));
  });

  test('wake period split across midnight', () {
    final sleeps = [
      sleep(
        created: DateTime(2026, 3, 14, 22),
        startDate: DateTime(2026, 3, 14, 21),
        endDate: DateTime(2026, 3, 14, 23),
      ),
      sleep(
        created: DateTime(2026, 3, 15, 9),
        startDate: DateTime(2026, 3, 15, 7),
        endDate: DateTime(2026, 3, 15, 8),
      ),
    ];

    final day1 = awakePeriodsForDay(DateTime(2026, 3, 14), sleeps, at);
    final day2 = awakePeriodsForDay(DateTime(2026, 3, 15), sleeps, at);

    expect(day1.length, 1);
    expect(day1[0].start, DateTime(2026, 3, 14, 23));
    expect(day1[0].end, DateTime(2026, 3, 15));
    expect(day2.length, 2);
    expect(day2[0].start, DateTime(2026, 3, 15));
    expect(day2[0].end, DateTime(2026, 3, 15, 7));
    expect(day2[1].start, DateTime(2026, 3, 15, 8));
    expect(day2[1].isOngoing, isTrue);
    expect(day2[1].end, isNull);
  });

  test('day without sleep has no wake rows', () {
    final sleeps = [
      sleep(
        created: DateTime(2026, 3, 15, 8),
        startDate: DateTime(2026, 3, 15, 7),
        endDate: DateTime(2026, 3, 15, 9),
      ),
    ];

    expect(awakePeriodsForDay(DateTime(2026, 3, 14), sleeps, at), isEmpty);
  });

  test('skips wake shorter than one minute between sleeps', () {
    final sleeps = [
      sleep(
        created: DateTime(2026, 3, 15, 8),
        startDate: DateTime(2026, 3, 15, 7),
        endDate: DateTime(2026, 3, 15, 9),
      ),
      sleep(
        created: DateTime(2026, 3, 15, 10),
        startDate: DateTime(2026, 3, 15, 9, 0, 30),
        endDate: DateTime(2026, 3, 15, 11),
      ),
      sleep(
        created: DateTime(2026, 3, 15, 12),
        startDate: DateTime(2026, 3, 15, 11, 0, 30),
      ),
    ];

    expect(awakePeriodsForDay(DateTime(2026, 3, 15), sleeps, at), isEmpty);
  });
}
