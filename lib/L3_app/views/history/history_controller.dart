// Copyright (c) 2025. Xenia Moroz

import 'package:collection/collection.dart';
import 'package:mobx/mobx.dart';

import '../../../L1_domain/entities/abstract_entry.dart';
import '../../../L1_domain/entities/baby.dart';
import '../../../L1_domain/entities/feed.dart';
import '../../../L1_domain/entities/sleep.dart';
import '../../../L1_domain/utils/dates.dart';
import '../../components/snackbar_dialog.dart';
import '../_base/loadable.dart';
import '../app/services.dart';

part 'history_controller.g.dart';

class HistoryController extends _Base with Loadable, _$HistoryController {
  HistoryController(Baby baby) {
    _baby = baby;
  }
  Future reload() async {
    await load(() async {
      await _fetchSleepEntries();
      await _fetchFeedEntries();
    });
  }

  Future startSleep(DateTime startDate) async {
    await load(() async {
      await _startSleep(startDate);
    });
    showMTSnackbar(_baby.isBoy ? loc.action_start_sleep_title_boy : loc.action_start_sleep_title_girl);
  }

  Future stopSleep(DateTime endDate) async {
    await load(() async {
      await _stopSleep(endDate);
    });
  }

  Future addFeed() async {
    await load(() async {
      await _addFeed();
    });
    showMTSnackbar(loc.action_add_feed_title);
  }
}

abstract class _Base with Store {
  late final Baby _baby;

  /// записи о сне
  @observable
  ObservableList<Sleep> sleepEntries = ObservableList();

  @observable
  Sleep? currentSleep;

  @action
  Future _fetchSleepEntries() async {
    sleepEntries = ObservableList.of(await sleepUC.entries(_baby));
  }

  @action
  Future _startSleep(DateTime startDate) async {
    currentSleep = Sleep(created: now, startDate: startDate, babyCreatedTime: _baby.created);
    sleepEntries.add(currentSleep!);
    await sleepUC.edit(currentSleep!);
  }

  @action
  Future _stopSleep(DateTime endDate) async {
    final sleep = currentSleep;
    if (sleep != null) {
      final index = sleepEntries.indexOf(sleep);
      if (index > -1) {
        currentSleep = null;
        sleepEntries[index] = sleep.copyWith(endDate: endDate);
        await sleepUC.edit(sleep);
      }
    }
  }

  @computed
  bool get babyIsSleeping => currentSleep != null;

  @computed
  bool get hasSleepEntriesToday => lastSleepEntry?.endIsToday == true;

  @computed
  Sleep? get lastSleepEntry => sleepEntries.lastOrNull;

  @computed
  Iterable<Sleep> get sortedSleepEntries => sleepEntries.reversed;

  /// записи о кормлении
  @observable
  ObservableList<Feed> feedEntries = ObservableList();

  @action
  Future _fetchFeedEntries() async {
    feedEntries = ObservableList.of(await feedUC.entries(_baby));
  }

  @action
  Future _addFeed() async {
    final feed = Feed(created: now, babyCreatedTime: _baby.created);
    feedEntries.add(feed);
    await feedUC.edit(feed);
  }

  @computed
  bool get hasFeedEntriesToday => lastFeedEntry?.endIsToday == true;

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
