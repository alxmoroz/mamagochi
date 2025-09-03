import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mamagochi/L3_app/presenters/entry.dart';
import 'package:mobx/mobx.dart';

import '/../L3_app/presenters/feed.dart';
import '../../../L1_domain/entities/feed.dart';
import '../../components/adaptive.dart';
import '../../components/button.dart';
import '../../components/card.dart';
import '../../components/colors.dart';
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

  @action
  void setFeedType(FeedingType value) => feed = feed.copyWith(type: value);
}

class EditFeedDialog extends StatelessWidget {
  const EditFeedDialog._(this._fc);
  final _EditFeedController _fc;

  static Future show(Feed feed) async => await showMTDialog(EditFeedDialog._(_EditFeedController(feed)));

  HistoryController get _hc => mainController.selectedBabyController!.historyController;

  Future _editEnd() async {
    final end = await MTDateTimePicker.show(_fc.feed.editFeedDateTimeTitle, initialDate: _fc.feed.end);
    if (end != null) {
      await _hc.editFeed(_fc.feed, end, _fc.feed.type, _fc.feed.count);
      _fc.setEnd(end);
    }
  }

  Future _editFeedType(FeedingType type) async {
    await _hc.editFeed(_fc.feed, _fc.feed.end, type, _fc.feed.count);
    _fc.setFeedType(type);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final screen = screenSize(context);
      final size = min(180.0, min(screen.width, screen.height) / 2 - P3);
      final buttonSize = Size.square(size);

      return _hc.loading
          ? LoaderScreen(_hc)
          : MTDialog(
              topBar: MTTopBar(middle: H1(_fc.feed.editFeedTitle)),
              body: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: P2),

                      /// левая грудь
                      _fc.feed.type.isBreast
                          ? Positioned(
                              left: -125,
                              child: MTButton(
                                minSize: buttonSize,
                                color: b3Color,
                                type: _fc.feed.type.isLeftBreast ? MTButtonType.secondary : MTButtonType.main,
                                middle: const BaseText('Левая'),
                                onTap: () => _editFeedType(FeedingType.left_breast),
                              ),
                            )
                          : const SizedBox(),
                      const Spacer(),

                      /// правая грудь
                      _fc.feed.type.isBreast
                          ? Positioned(
                              right: -125,
                              child: MTButton(
                                minSize: buttonSize,
                                constrained: false,
                                color: b3Color,
                                type: _fc.feed.type.isRightBreast ? MTButtonType.secondary : MTButtonType.main,
                                middle: const BaseText('Правая'),
                                onTap: () => _editFeedType(FeedingType.right_breast),
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(width: P2),
                    ],
                  ),
                  const SizedBox(height: P2),

                  /// редактор времени
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
            );
    });
  }
}
