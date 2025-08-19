import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

import '/../L3_app/presenters/entry.dart';
import '/../L3_app/presenters/feed.dart';
import '../../../L1_domain/entities/feed.dart';
import '../../components/card.dart';
import '../../components/constants.dart';
import '../../components/datetime_picker.dart';
import '../../components/dialog.dart';
import '../../components/images.dart';
import '../../components/list_tile.dart';
import '../../components/text.dart';
import '../../components/toolbar.dart';
import '../_base/loader_screen.dart';
import '../app/services.dart';
import 'history_controller.dart';

part 'edit_feed_dialog.g.dart';

class _EditFeedController extends _Base with _$_EditFeedController {
  _EditFeedController(Feed feedIn) {
    feed = feedIn;
  }
}

abstract class _Base with Store {
  @observable
  late Feed feed;

  @action
  void setEnd(DateTime value) => feed = feed.copyWith(endDate: value);
}

class EditFeedDialog extends StatelessWidget {
  const EditFeedDialog._(this._fc);
  final _EditFeedController _fc;

  static Future show(Feed feed) async => await showMTDialog(EditFeedDialog._(_EditFeedController(feed)));

  HistoryController get _hc => mainController.selectedBabyController!.historyController;

  Future _editEnd() async {
    final end = await MTDateTimePicker.show(_fc.feed.editFeedDateTimeTitle, initialDate: _fc.feed.end);
    if (end != null) {
      await _hc.editFeed(_fc.feed, end, _fc.feed.type);
      _fc.setEnd(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return _hc.loading
          ? LoaderScreen(_hc)
          : MTDialog(
              topBar: MTTopBar(middle: H1(_fc.feed.editFeedTitle)),
              body: ListView(
                shrinkWrap: true,
                children: [
                  MTCard(
                    margin: const EdgeInsets.symmetric(vertical: P, horizontal: P3),
                    radius: 40,
                    elevation: 0,
                    child: MTListTile(
                      leading: const MTImage('time', height: 60),
                      middle: BaseText(_fc.feed.editFeedDateTimeTitle),
                      subtitle: H2(_fc.feed.endDateTime),
                      bottomDivider: false,
                      onTap: _editEnd,
                    ),
                  ),
                ],
              ),
              forceBottomPadding: true,
            );
    });
  }
}
