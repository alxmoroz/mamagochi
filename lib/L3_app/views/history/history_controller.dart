// Copyright (c) 2025. Xenia Moroz

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

import '/../L3_app/presenters/duration.dart';
import '/../L3_app/presenters/feed.dart';
import '../../../L1_domain/entities/abstract_entry.dart';
import '../../../L1_domain/entities/baby.dart';
import '../../../L1_domain/entities/feed.dart';
import '../../../L1_domain/entities/sleep.dart';
import '../../../L1_domain/utils/dates.dart';
import '../../components/colors.dart';
import '../../components/snackbar_dialog.dart';
import '../../components/text.dart';
import '../_base/loadable.dart';
import '../app/services.dart';
import '../main/widgets/feed_type_dialog.dart';
import 'edit_feed_dialog.dart';
import 'edit_sleep_dialog.dart';

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

  /// сон
  Future startSleep(DateTime startDate) async {
    await load(() async {
      await _startSleep(startDate);
    });
    showMTSnackbar(_baby.isBoy ? loc.action_start_sleep_title_boy : loc.action_start_sleep_title_girl);
  }

  Future stopSleep(DateTime endDate) async {
    await load(() async {
      await _editSleep(lastSleep!, endDate: endDate);
    });

    final hc = mainController.selectedBabyController?.historyController;
    final sleepDuration = hc!.lastSleep!.durationFromStartToEnd.strInHoursAndMinutes;
    showMTSnackbar(
      _baby.isBoy ? loc.how_much_slept_boy(sleepDuration) : loc.how_much_slept_girl(sleepDuration),
      titleAlign: TextAlign.start,
      trailing: BaseText.medium(loc.action_edit_title, color: mainColor),
      onTap: () => EditSleepDialog.show(lastSleep!),
    );
  }

  Future editSleep(Sleep sleep, {DateTime? startDate, DateTime? endDate}) async {
    await load(() async {
      await _editSleep(sleep, startDate: startDate, endDate: endDate);
    });
  }

  Future editLastSleep({DateTime? startDate, DateTime? endDate}) async {
    await editSleep(lastSleep!, startDate: startDate, endDate: endDate);
  }

  /// кормление
  Future addFeed() async {
    final feedType = await FeedTypeDialog.show();
    if (feedType != null) {
      if (feedType.isBreast) {
        await startBreastFeed(feedType);
      } else {
        await load(() async {
          await _addFeed(feedType);
        });
        await EditFeedDialog.show(lastFeed!);
        showMTSnackbar(
          lastFeed!.addFeedTitle,
          titleAlign: TextAlign.start,
          trailing: BaseText.medium(loc.action_edit_title, color: mainColor),
          onTap: () => EditFeedDialog.show(lastFeed!),
        );
      }
    }
  }

  Future startBreastFeed(FeedingType type) async {
    await load(() async {
      await _startBreastFeed(type);
    });
  }

  Future stopBreastFeed(DateTime endDate) async {
    final feed = lastOngoingBreastFeed!;
    await load(() async {
      await _editFeed(feed.copyWith(endDate: endDate));
    });
    final finishedFeed = lastFeed!;
    final feedDuration = finishedFeed.durationFromStartToEnd.strInHoursAndMinutes;
    showMTSnackbar(
      '${finishedFeed.addFeedTitle} • $feedDuration',
      titleAlign: TextAlign.start,
      trailing: BaseText.medium(loc.action_edit_title, color: mainColor),
      onTap: () => EditFeedDialog.show(finishedFeed),
    );
  }

  Future editFeed(Feed feed) async {
    await load(() async {
      await _editFeed(feed);
    });
  }

  /// общие
  Future deleteEntry(AbstractEntry entry) async {
    await load(() async {
      await _deleteEntry(entry);
    });
  }
}

abstract class _Base with Store {
  late final Baby _baby;

  /// записи о сне
  @observable
  ObservableList<Sleep> _sleepEntries = ObservableList();

  @computed
  Sleep? get lastSleep => _sortedSleepEntries.lastOrNull;

  @action
  Future _fetchSleepEntries() async => _sleepEntries = ObservableList.of(await sleepUC.entries(_baby));

  @action
  Future _startSleep(DateTime startDate) async {
    final sleep = Sleep(created: now, startDate: startDate, babyCreatedTime: _baby.created);
    _sleepEntries.add(sleep);
    await sleepUC.edit(sleep);
  }

  @action
  Future _editSleep(Sleep sleep, {DateTime? startDate, DateTime? endDate}) async {
    final index = _sleepEntries.indexWhere((s) => s.created == sleep.created);
    final editedSleep = sleep.copyWith(startDate: startDate, endDate: endDate);
    _sleepEntries[index] = editedSleep;
    await sleepUC.edit(editedSleep);
  }

  @computed
  bool get babyIsSleeping => lastSleep != null && lastSleep!.isStillSleeping;

  @computed
  bool get hasSleepEntriesFor24Hours => lastSleep != null && now.difference(lastSleep!.end).inHours < 24;

  @computed
  Iterable<Sleep> get _sortedSleepEntries => _sleepEntries.sortedBy<DateTime>((e) => e.end);

  /// записи о кормлении
  @observable
  ObservableList<Feed> _feedEntries = ObservableList();

  @action
  Future _fetchFeedEntries() async => _feedEntries = ObservableList.of(await feedUC.entries(_baby));

  @action
  Future _addFeed(FeedingType type) async {
    final feed = Feed(created: now, babyCreatedTime: _baby.created, type: type);
    _feedEntries.add(feed);
    await feedUC.edit(feed);
  }

  @action
  Future _startBreastFeed(FeedingType type) async {
    final feed = Feed(
      created: now,
      startDate: now,
      endDate: null,
      babyCreatedTime: _baby.created,
      type: type,
    );
    _feedEntries.add(feed);
    await feedUC.edit(feed);
  }

  @action
  Future _editFeed(Feed feed) async {
    final index = _feedEntries.indexWhere((f) => f.created == feed.created);
    _feedEntries[index] = feed;
    await feedUC.edit(feed);
  }

  @computed
  bool get hasFeedEntriesFor24Hours => lastFeed != null && now.difference(lastFeed!.end).inHours < 24;

  @computed
  Feed? get lastFeed => _sortedFeedEntries.lastOrNull;

  @computed
  Iterable<Feed> get _sortedFeedEntries => _feedEntries.sortedBy<DateTime>((e) => e.end);

  @computed
  Feed? get lastOngoingBreastFeed =>
      _feedEntries.where((f) => f.type.isBreast && f.endDate == null).sortedBy<DateTime>((e) => e.created).lastOrNull;

  @computed
  bool get babyIsEating => lastOngoingBreastFeed != null;

  /// общие
  @computed
  Iterable<AbstractEntry> get _entries => [..._feedEntries, ..._sleepEntries];

  @computed
  Map<DateTime, Iterable<AbstractEntry>> get groupedEntries {
    final sorted = _entries.sortedBy<DateTime>((e) => e.end).reversed;
    return sorted.groupListsBy((e) => e.end.date);
  }

  @computed
  bool get hasEntries => _entries.isNotEmpty;

  @action
  Future _deleteEntry(AbstractEntry entry) async {
    if (entry is Feed) {
      _feedEntries.remove(entry);
      await feedUC.delete(entry);
    } else if (entry is Sleep) {
      _sleepEntries.remove(entry);
      await sleepUC.delete(entry);
    }
  }
}
