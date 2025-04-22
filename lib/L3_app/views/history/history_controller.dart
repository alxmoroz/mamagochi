// Copyright (c) 2025. Xenia Moroz

import 'package:collection/collection.dart';
import 'package:mamagochi/L1_domain/entities/abstract_entry.dart';
import 'package:mamagochi/L1_domain/entities/sleep.dart';
import 'package:mamagochi/L1_domain/utils/dates.dart';
import 'package:mamagochi/L3_app/views/app/services.dart';
import 'package:mobx/mobx.dart';

import '../../../L1_domain/entities/feed.dart';
import '../../components/snackbar_dialog.dart';
import '../_base/loadable.dart';

part 'history_controller.g.dart';

class HistoryController extends _Base with Loadable, _$HistoryController {
  Future reload() async {
    await load(() async {
      await _fetchSleepEntries();
      await _fetchFeedEntries();
    });
  }

  Future addSleep() async {
    await load(() async {
      await _addSleep();
    });
    showMTSnackbar(loc.action_add_sleep_title);
  }

  Future addFeed() async {
    await load(() async {
      await _addFeed();
    });
    showMTSnackbar(loc.action_add_feed_title);
  }
}

abstract class _Base with Store {
  /// записи о сне
  @observable
  ObservableList<Sleep> sleepEntries = ObservableList();

  @action
  Future _fetchSleepEntries() async {
    sleepEntries = ObservableList.of(await sleepUC.entries());
  }

  @action
  Future _addSleep() async {
    final sleep = Sleep(end: DateTime.now());
    sleepEntries.add(sleep);
    await sleepUC.addEntry(sleep);
  }

  @computed
  bool get hasSleepEntriesToday => lastSleepEntry?.end.day == DateTime.now().day;

  @computed
  Sleep? get lastSleepEntry => sleepEntries.lastOrNull;

  @computed
  Iterable<Sleep> get sortedSleepEntries => sleepEntries.reversed;

  /// записи о кормлении
  @observable
  ObservableList<Feed> feedEntries = ObservableList();

  @action
  Future _fetchFeedEntries() async {
    feedEntries = ObservableList.of(await feedUC.entries());
  }

  @action
  Future _addFeed() async {
    final feed = Feed(end: DateTime.now());
    feedEntries.add(feed);
    await feedUC.addEntry(feed);
  }

  @computed
  bool get hasFeedEntriesToday => lastFeedEntry?.end.day == DateTime.now().day;

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
