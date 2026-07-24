// Copyright (c) 2025. Xenia Moroz

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

import '/../L3_app/presenters/feed.dart';
import '/../L3_app/presenters/sleep.dart';
import '../../../L1_domain/entities/abstract_entry.dart';
import '../../../L1_domain/entities/app_local_settings.dart';
import '../../../L1_domain/entities/baby.dart';
import '../../../L1_domain/entities/feed.dart';
import '../../../L1_domain/entities/sleep.dart';
import '../../../L1_domain/utils/dates.dart';
import '../../../L1_domain/utils/awake_periods.dart';
import '../../../L1_domain/utils/sleep_interval.dart';
import '../../components/colors.dart';
import '../../components/snackbar_dialog.dart';
import '../../components/text.dart';
import '../_base/loadable.dart';
import '../app/services.dart';
import '../main/widgets/feed_type_dialog.dart';
import 'edit_feed_dialog.dart';
import 'edit_sleep_dialog.dart';
import 'day_summary.dart';
import 'history_day_item.dart';

part 'history_controller.g.dart';

class HistoryController extends _Base with Loadable, _$HistoryController {
  HistoryController(Baby baby) {
    _baby = baby;
    stopLoading();
  }
  Future reload() async {
    await load(() async {
      await _fetchSleepEntries();
      // Миграция закомментирована — она закрывала старые «зависшие» записи сна
      // неправильным временем (не now), что ломало длительность завершаемых вручную
      // записей и оставляло endDate равным startDate/created.
      // Все пользователи уже обновились, миграция нужна была только один раз.
      // await _migrateStaleSleepEntries();
      await _fetchFeedEntries();
      await _migrateSleepHintIfNeeded();
    });
  }

  /// сон
  Future startSleep(DateTime startDate) async {
    await load(() async {
      await _startSleep(startDate);
    });
    showMTSnackbar(lastSleep!.startSleepActionTitle);
  }

  Future stopSleep(DateTime endDate) async {
    final sleep = ongoingSleep;
    if (sleep == null) return;
    await load(() async {
      await _editSleep(sleep, endDate: endDate);
    });

    // Актуальная запись после сохранения (со endDate), не старый ongoing-объект.
    final finishedSleep = _sleepAt(sleep);
    final sleptTitle = _baby.isBoy ? loc.how_much_slept_boy('') : loc.how_much_slept_girl('');
    final subtitle = finishedSleep.duration.inMinutes > 0 ? finishedSleep.sleepDuration : null;
    showMTSnackbar(
      sleptTitle.trim(),
      subtitle: subtitle,
      titleAlign: TextAlign.start,
      trailing: BaseText.medium(loc.action_edit_title, color: mainColor),
      onTap: () => EditSleepDialog.show(finishedSleep),
    );
  }

  Future editSleep(Sleep sleep, {DateTime? startDate, DateTime? endDate}) async {
    await load(() async {
      await _editSleep(sleep, startDate: startDate, endDate: endDate);
    });
  }

  Future editLastSleep({DateTime? startDate, DateTime? endDate}) async {
    final sleep = ongoingSleep ?? lastSleep;
    if (sleep == null) return;
    await editSleep(sleep, startDate: startDate, endDate: endDate);
  }

  /// кормление
  Future addFeed() async {
    if (loading) return;

    final feedType = await FeedTypeDialog.show();
    if (feedType == null) return;

    final duringSleep = babyIsSleeping;
    final sleepCreated = duringSleep ? ongoingSleep!.created : null;

    if (feedType.isBreast) {
      if (!duringSleep && babyIsEating) return;

      if (duringSleep) {
        Feed? addedFeed;
        await load(() async {
          addedFeed = await _addBreastFeedDuringSleep(feedType, sleepCreated!);
        });
        final feed = _feedAt(addedFeed!);
        final feedSubtitle = feed.historyBreastFeedDuration.isNotEmpty ? '${feed.whatToEatTitle} ${feed.historyBreastFeedDuration}' : feed.whatToEatTitle;
        showMTSnackbar(
          feed.actionAddFeedTitle,
          subtitle: feedSubtitle,
          titleAlign: TextAlign.start,
          trailing: BaseText.medium(loc.action_edit_title, color: mainColor),
          onTap: () => EditFeedDialog.show(feed),
        );
      } else {
        await startBreastFeed(feedType);
      }
    } else {
      Feed? addedFeed;
      await load(() async {
        addedFeed = await _addFeed(feedType, sleepCreated: sleepCreated);
      });
      await EditFeedDialog.show(addedFeed!);
      // После редактора — актуальная запись по created, не lastFeed (сортировка по end).
      final feed = _feedAt(addedFeed!);
      final feedSubtitle = feed.shouldShowCount ? '${feed.whatToEatTitle} ${feed.feedCount}' : feed.whatToEatTitle;
      showMTSnackbar(
        feed.actionAddFeedTitle,
        subtitle: feedSubtitle,
        titleAlign: TextAlign.start,
        trailing: BaseText.medium(loc.action_edit_title, color: mainColor),
        onTap: () => EditFeedDialog.show(feed),
      );
    }
  }

  Future startBreastFeed(FeedingType type) async {
    if (babyIsEating) return;

    await load(() async {
      await _startBreastFeed(type);
    });
  }

  Future stopBreastFeed(DateTime endDate) async {
    final feed = lastOngoingBreastFeed!;
    await load(() async {
      await _editFeed(feed.copyWith(endDate: endDate));
    });
    final finishedFeed = _feedAt(feed);
    final feedSubtitle = finishedFeed.historyBreastFeedDuration.isNotEmpty
        ? '${finishedFeed.whatToEatTitle} ${finishedFeed.historyBreastFeedDuration}'
        : finishedFeed.whatToEatTitle;
    showMTSnackbar(
      finishedFeed.actionAddFeedTitle,
      subtitle: feedSubtitle,
      titleAlign: TextAlign.start,
      trailing: BaseText.medium(loc.action_edit_title, color: mainColor),
      onTap: () => EditFeedDialog.show(finishedFeed),
    );
  }

  /// Завершить грудное кормление и сразу начать сон (одна кнопка в режиме кормления).
  Future stopBreastFeedAndStartSleep(DateTime endFeedAndStartSleep) async {
    final feed = lastOngoingBreastFeed!;
    await load(() async {
      await _editFeed(feed.copyWith(endDate: endFeedAndStartSleep));
      await _startSleep(endFeedAndStartSleep);
    });
    final finishedFeed = _feedAt(feed);
    showMTSnackbar(
      lastSleep!.ateAndFellAsleepTitle,
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

  /// Старым пользователям с завершёнными снами в истории подсказку не показываем.
  Future _migrateSleepHintIfNeeded() async {
    if (localSettingsController.settings.getString(ALSStringCode.SLEEP_HINT_DISMISSED) == 'true') return;
    if (!hasCompletedSleepEntries) return;
    await localSettingsController.markSleepHintShown();
  }

  /// Закрывает «зависшие» записи сна без endDate — иначе статистика считает их до «сейчас».
  @action
  Future _migrateStaleSleepEntries() async {
    final stale = staleUnfinishedSleeps(_sleepEntries, now);
    for (final sleep in stale) {
      await _editSleep(sleep, endDate: closedEndDateForStaleSleep(sleep, _sleepEntries));
    }
  }
}

abstract class _Base with Store {
  late final Baby _baby;

  /// записи о сне
  @observable
  ObservableList<Sleep> _sleepEntries = ObservableList();

  @computed
  Sleep? get lastSleep => _sortedSleepEntries.lastOrNull;

  @computed
  Sleep? get ongoingSleep => findOngoingSleep(_sleepEntries, now);

  @computed
  bool get babyIsSleeping => ongoingSleep != null;

  /// Загружает записи сна из БД, не затирая актуальные данные в памяти.
  ///
  /// Фоновый [reload] (каждые 15 с с главного экрана) может совпасть с сохранением:
  /// запись уже обновлена в [_sleepEntries], но в БД ещё старая версия (или запись
  /// ещё не успела туда попасть). Без этой защиты список полностью заменялся данными
  /// из БД — в истории и на главной снова показывались старые значения.
  @action
  Future _fetchSleepEntries() async {
    final persisted = await sleepUC.entries(_baby);

    // Для каждой записи из БД: если в памяти уже есть запись с тем же created —
    // берём локальную версию (она новее: правка в диалоге или сон в процессе сохранения).
    final merged = [
      for (final p in persisted)
        _sleepEntries.firstWhereOrNull((s) => s.created.isAtSameMomentAs(p.created)) ?? p,
    ];

    // Текущий сон (endDate == null), которого ещё нет в БД: только что нажали «Сон»,
    // [_startSleep] добавил запись в память, а await sleepUC.edit ещё не завершился.
    final pendingOngoing = _sleepEntries
        .where((s) => s.isStillSleeping)
        .where((s) => !merged.any((p) => p.created.isAtSameMomentAs(s.created)));

    _sleepEntries = ObservableList.of([...merged, ...pendingOngoing]);
  }

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
  bool get hasCompletedSleepEntries => _sleepEntries.any((s) => !s.isStillSleeping);

  @computed
  bool get hasSleepEntriesFor24Hours => lastSleep != null && now.difference(lastSleep!.end).inHours < 24;

  @computed
  Iterable<Sleep> get _sortedSleepEntries => _sleepEntries.sortedBy<DateTime>((e) => e.end);

  /// записи о кормлении
  @observable
  ObservableList<Feed> _feedEntries = ObservableList();

  /// Загружает записи кормления из БД, не затирая актуальные данные в памяти.
  ///
  /// Та же гонка, что и у сна: [reload] читает БД, пока [_editFeed] / [_startBreastFeed]
  /// ещё пишут изменения. Без merge локальная правка (время, тип, количество) могла
  /// исчезнуть из списка до следующего успешного reload.
  @action
  Future _fetchFeedEntries() async {
    final persisted = await feedUC.entries(_baby);

    // Для каждой записи из БД: при совпадении created — приоритет у версии в памяти.
    final merged = [
      for (final p in persisted)
        _feedEntries.firstWhereOrNull((f) => f.created.isAtSameMomentAs(p.created)) ?? p,
    ];

    // Грудное кормление с таймером (endDate == null), ещё не попавшее в БД.
    final pendingOngoing = _feedEntries
        .where((f) => f.isStillFeeding)
        .where((f) => !merged.any((p) => p.created.isAtSameMomentAs(f.created)));

    _feedEntries = ObservableList.of([...merged, ...pendingOngoing]);
  }

  @action
  Future<Feed> _addFeed(FeedingType type, {DateTime? sleepCreated}) async {
    final feed = Feed(created: now, babyCreatedTime: _baby.created, type: type, sleepCreated: sleepCreated);
    _feedEntries.add(feed);
    await feedUC.edit(feed);
    return feed;
  }

  /// Грудное кормление «внутри сна»: запись сразу с endDate (таймер не запускается), привязка ко сну.
  @action
  Future<Feed> _addBreastFeedDuringSleep(FeedingType type, DateTime sleepCreated) async {
    final feed = Feed(created: now, startDate: now, endDate: now, babyCreatedTime: _baby.created, type: type, sleepCreated: sleepCreated);
    _feedEntries.add(feed);
    await feedUC.edit(feed);
    return feed;
  }

  @action
  Future _startBreastFeed(FeedingType type) async {
    if (lastOngoingBreastFeed != null) return;

    final feed = Feed(created: now, startDate: now, endDate: null, babyCreatedTime: _baby.created, type: type);
    _feedEntries.add(feed);
    await feedUC.edit(feed);
  }

  @action
  Future _editFeed(Feed feed) async {
    final index = _feedEntries.indexWhere((f) => f.created == feed.created);
    _feedEntries[index] = feed;
    await feedUC.edit(feed);
  }

  Feed _feedAt(Feed feed) =>
      // created не меняется при редактировании — стабильный ключ записи.
      _feedEntries.firstWhere((f) => f.created.isAtSameMomentAs(feed.created));

  Sleep _sleepAt(Sleep sleep) =>
      _sleepEntries.firstWhere((s) => s.created.isAtSameMomentAs(sleep.created));

  @computed
  bool get hasFeedEntriesFor24Hours => lastFeed != null && now.difference(lastFeed!.end).inHours < 24;

  /// Последняя запись по времени окончания; для снэкбара после добавления не подходит.
  @computed
  Feed? get lastFeed => _sortedFeedEntries.lastOrNull;

  @computed
  Iterable<Feed> get _sortedFeedEntries => _feedEntries.sortedBy<DateTime>((e) => e.end);

  /// Текущее грудное кормление: только записи с явным startDate (новый режим). Старые записи без startDate не считаются текущими.
  @computed
  Feed? get lastOngoingBreastFeed =>
      _feedEntries.where((f) => f.isStillFeeding).sortedBy<DateTime>((e) => e.created).lastOrNull;

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

  List<HistoryDayItem> dayItemsFor(DateTime date) {
    final entries = groupedEntries[date.date] ?? const <AbstractEntry>[];
    final items = <HistoryDayItem>[for (final entry in entries) HistoryEntryItem(entry)];

    for (final period in awakePeriodsForDay(date.date, _sleepEntries, now)) {
      items.add(HistoryAwakeItem(period));
    }

    items.sort((a, b) => b.sortTime.compareTo(a.sortTime));
    return items;
  }

  @computed
  bool get hasEntries => _entries.isNotEmpty;

  DaySummary daySummaryFor(DateTime date) => DaySummary.calculate(
    date: date,
    sleepEntries: _sleepEntries,
    feedEntries: _feedEntries,
    referenceTime: now,
  );

  /// Сводка дня, если запись удалить — для анимации скрытия карточек в истории.
  DaySummary daySummaryAfterRemoving(DateTime date, AbstractEntry entry) => DaySummary.calculate(
    date: date,
    sleepEntries: entry is Sleep
        ? _sleepEntries.where((s) => !s.created.isAtSameMomentAs(entry.created))
        : _sleepEntries,
    feedEntries: entry is Feed
        ? _feedEntries.where((f) => !f.created.isAtSameMomentAs(entry.created))
        : _feedEntries,
    referenceTime: now,
  );

  @action
  Future _deleteEntry(AbstractEntry entry) async {
    if (entry is Feed) {
      _feedEntries.remove(entry);
      await feedUC.delete(entry);
    } else if (entry is Sleep) {
      final sleepCreated = entry.created;

      /// Если есть кормления внутри сна, то удаляем привязку ко сну, записи кормлений остаются
      final feedsToUnlink = _feedEntries.where((f) => f.sleepCreated == sleepCreated).toList();
      for (final feed in feedsToUnlink) {
        await _editFeed(feed.withSleepCreated(null));
      }
      _sleepEntries.remove(entry);
      await sleepUC.delete(entry);
    }
  }
}
