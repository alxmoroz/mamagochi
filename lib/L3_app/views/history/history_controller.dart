// Copyright (c) 2025. Xenia Moroz

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamagochi/L3_app/presenters/duration.dart';
import 'package:mobx/mobx.dart';

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
      trailing: BaseText(loc.action_edit_title, color: mainBtnTitleColor),
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

  Future addFeed() async {
    await load(() async {
      await _addFeed();
    });
    showMTSnackbar(_baby.isBoy ? loc.action_add_feed_title_boy : loc.action_add_feed_title_girl);
  }
}

abstract class _Base with Store {
  late final Baby _baby;

  /// записи о сне
  @observable
  ObservableList<Sleep> sleepEntries = ObservableList();

  @computed
  Sleep? get lastSleep => sleepEntries.lastOrNull;

  @action
  Future _fetchSleepEntries() async {
    sleepEntries = ObservableList.of(await sleepUC.entries(_baby));
  }

  @action
  Future _startSleep(DateTime startDate) async {
    final sleep = Sleep(created: now, startDate: startDate, babyCreatedTime: _baby.created);
    sleepEntries.add(sleep);
    await sleepUC.edit(sleep);
  }

  @action
  Future _editSleep(Sleep sleep, {DateTime? startDate, DateTime? endDate}) async {
    final index = sleepEntries.indexWhere((s) => s.created == sleep.created);
    final editedSleep = sleep.copyWith(startDate: startDate, endDate: endDate);
    sleepEntries[index] = editedSleep;
    await sleepUC.edit(editedSleep);
  }

  @computed
  bool get babyIsSleeping => lastSleep != null && lastSleep!.endDate == null;

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
