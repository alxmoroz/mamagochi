// Copyright (c) 2025. Xenia Moroz

import 'package:collection/collection.dart';
import 'package:mamagochi/L1_domain/entities/abstract_entry.dart';
import 'package:mamagochi/L1_domain/entities/sleep.dart';
import 'package:mamagochi/L1_domain/utils/dates.dart';
import 'package:mobx/mobx.dart';

import '../../../L1_domain/entities/feed.dart';
import '../../components/snackbar_dialog.dart';
import '../_base/loadable.dart';

part 'history_controller.g.dart';

class HistoryController extends _Base with _$HistoryController {}

abstract class _Base with Store, Loadable {
  /// записи о сне
  @observable
  ObservableList<Sleep> sleepEntries = ObservableList();

  @action
  void addSleep() {
    final sleep = Sleep(end: DateTime.now());
    sleepEntries.add(sleep);
    showMTSnackbar('Поспал');
  }

  @computed
  bool get hasSleepEntries => sleepEntries.isNotEmpty;

  @computed
  Sleep? get lastSleepEntry => sleepEntries.lastOrNull;

  @computed
  Iterable<Sleep> get sortedSleepEntries => sleepEntries.reversed;

  /// записи о кормлении
  @observable
  ObservableList<Feed> feedEntries = ObservableList();

  @action
  void addFeed() {
    final feed = Feed(end: DateTime.now());
    feedEntries.add(feed);
    showMTSnackbar('Покушал');
  }

  @computed
  bool get hasFeedEntries => feedEntries.isNotEmpty;

  @computed
  Feed? get lastFeedEntry => feedEntries.lastOrNull;

  @computed
  Iterable<Feed> get sortedFeedEntries => feedEntries.reversed;

  /// общие
  @computed
  Iterable<AbstractEntry> get _entries => [...feedEntries, ...sleepEntries];

  @computed
  Iterable<AbstractEntry> get sortedEntries => _entries.sortedBy<DateTime>((e) => e.end).reversed;

  @computed
  Map<DateTime, Iterable<AbstractEntry>> get groupedEntries => sortedEntries.groupListsBy((e) => e.end.date);

  @computed
  bool get hasEntries => _entries.isNotEmpty;
}
