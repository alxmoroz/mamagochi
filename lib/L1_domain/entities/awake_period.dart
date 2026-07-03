// Copyright (c) 2026. Alexandr Moroz

import '../utils/dates.dart';

/// Период бодрствования между снами. Не сохраняется в БД.
class AwakePeriod {
  const AwakePeriod({required this.start, this.end, required this.isOngoing});

  final DateTime start;
  final DateTime? end;
  final bool isOngoing;

  DateTime get sortTime => isOngoing ? now : end!;

  Duration get duration => sortTime.difference(start);

  bool get isMoreMinute => duration.inMinutes > 0;
}
