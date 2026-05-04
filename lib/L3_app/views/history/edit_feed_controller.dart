import 'dart:async';

import 'package:mobx/mobx.dart';

import '../../../L1_domain/entities/feed.dart';
import '../../components/field_data.dart';
import '../_base/edit_controller.dart';
import '../app/services.dart';
import 'history_controller.dart';

part 'edit_feed_controller.g.dart';

class EditFeedController extends _Base with _$EditFeedController {
  EditFeedController(Feed feedIn) {
    feed = feedIn;
    initState(fds: [MTFieldData(0, text: feed.count?.toString() ?? '')]);
  }

  HistoryController get _hc => mainController.selectedBabyController!.historyController;

  Future setStart(DateTime start) async {
    await _hc.editFeed(feed.copyWith(startDate: start));
    _setStart(start);
  }

  Future setEnd(DateTime end) async {
    await _hc.editFeed(feed.copyWith(endDate: end));
    _setEnd(end);
  }

  Future setFeedType(FeedingType type) async {
    await _hc.editFeed(feed.copyWith(type: type));
    _setFeedType(type);
  }
}

abstract class _Base extends EditController with Store {
  @observable
  late Feed feed;

  @action
  void _setStart(DateTime value) => feed = feed.copyWith(startDate: value);

  @action
  void _setEnd(DateTime value) => feed = feed.copyWith(endDate: value);

  @action
  void _setFeedType(FeedingType value) => feed = feed.copyWith(type: value);
}
