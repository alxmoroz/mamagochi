// Copyright (c) 2025. Xenia Moroz

import 'package:mamagochi/L1_domain/entities/sleep.dart';
import 'package:mobx/mobx.dart';

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
}
