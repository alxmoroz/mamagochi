// Copyright (c) 2026. Alexandr Moroz

import '../../../L1_domain/entities/abstract_entry.dart';
import '../../../L1_domain/entities/awake_period.dart';

sealed class HistoryDayItem {
  DateTime get sortTime;
}

class HistoryEntryItem extends HistoryDayItem {
  HistoryEntryItem(this.entry);

  final AbstractEntry entry;

  @override
  DateTime get sortTime => entry.end;
}

class HistoryAwakeItem extends HistoryDayItem {
  HistoryAwakeItem(this.period);

  final AwakePeriod period;

  @override
  DateTime get sortTime => period.sortTime;
}
