import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';

import '../../../L1_domain/entities/baby.dart';
import '../../../L1_domain/entities/feed.dart';
import '../../components/card.dart';
import '../../components/constants.dart';
import '../../components/datetime_picker.dart';
import '../../components/dialog.dart';
import '../../components/images.dart';
import '../../components/list_tile.dart';
import '../../components/text.dart';
import '../../components/toolbar.dart';
import '../../presenters/baby.dart';
import '../../presenters/date.dart';
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
  Baby get _baby => mainController.selectedBabyController!.baby;

  Future _editEnd() async {
    final end = await MTDateTimePicker.show(Intl.message('action_add_feed_title_${_baby.sex}'), initialDate: _fc.feed.end);
    if (end != null) {
      await _hc.editFeed(_fc.feed, end);
      _fc.setEnd(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return _hc.loading
          ? LoaderScreen(_hc)
          : MTDialog(
              topBar: MTTopBar(middle: H1(Intl.message('action_add_feed_title_${_baby.sex}'))),
              body: ListView(
                shrinkWrap: true,
                children: [
                  MTCard(
                    margin: const EdgeInsets.symmetric(vertical: P, horizontal: P3),
                    radius: 40,
                    elevation: 0,
                    child: MTListTile(
                      leading: const MTImage('time', height: 60),
                      middle: BaseText(Intl.message('action_add_feed_title_${_baby.sex}')),
                      subtitle: H2('${_fc.feed.end.strMedium}, ${_fc.feed.end.strTime}'),
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
