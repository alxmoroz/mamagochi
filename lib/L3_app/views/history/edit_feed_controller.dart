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

  Timer? _countEditTimer;
  HistoryController get _hc => mainController.selectedBabyController!.historyController;

  Future<void> _editCount(String str) async {
    final countText = str.trim();
    if (countText.isNotEmpty) {
      final count = int.parse(countText);
      await _hc.editFeed(feed.copyWith(count: count));
      _setCount(count);
    }
  }

  void editCount(String str) {
    if (_countEditTimer != null) {
      _countEditTimer!.cancel();
    }
    _countEditTimer = Timer(const Duration(milliseconds: 500), () => _editCount(str));
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
  void _setEnd(DateTime value) => feed = feed.copyWith(endDate: value);

  @action
  void _setFeedType(FeedingType value) => feed = feed.copyWith(type: value);

  @action
  void _setCount(int value) => feed = feed.copyWith(count: value);
}