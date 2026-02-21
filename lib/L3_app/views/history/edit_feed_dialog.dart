import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '/../L3_app/presenters/entry.dart';
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
import '../app/services.dart';
import 'edit_feed_controller.dart';
import 'food_count_editor.dart';

class EditFeedDialog extends StatelessWidget {
  const EditFeedDialog._(this._fec);
  final EditFeedController _fec;

  static Future show(Feed feed) async => await showMTDialog(EditFeedDialog._(EditFeedController(feed)));

  Future _editStart() async {
    final start = await MTDateTimePicker.show(
      _fec.feed.editFeedStartDateTitle,
      initialDate: _fec.feed.startDate ?? _fec.feed.created,
    );
    if (start != null) await _fec.setStart(start);
  }

  Future _editEnd() async {
    final end = await MTDateTimePicker.show(_fec.feed.editFeedDateTimeTitle, initialDate: _fec.feed.endDate);
    if (end != null) _fec.setEnd(end);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final screen = screenSize(context);
        final size = min(180.0, min(screen.width, screen.height) / 2 - P3);
        final buttonSize = Size.square(size);

        return MTDialog(
          topBar: MTTopBar(middle: H1(_fec.feed.editFeedTitle)),
          body: ListView(
            shrinkWrap: true,
            children: [
              _fec.feed.type.isBreast
                  ? Column(
                      children: [
                        const SizedBox(height: P2),
                        SizedBox(
                          height: size + P2,
                          child: Stack(
                            children: [
                              /// левая грудь
                              Positioned(
                                left: P2,
                                child: MTButton(
                                  minSize: buttonSize,
                                  color: b3Color,
                                  type: _fec.feed.type.isLeftBreast ? MTButtonType.secondary : MTButtonType.main,
                                  middle: BaseText(loc.feed_type_left_breast),
                                  onTap: () => _fec.setFeedType(FeedingType.left_breast),
                                ),
                              ),

                              /// правая грудь
                              Positioned(
                                right: P2,
                                child: MTButton(
                                  minSize: buttonSize,
                                  constrained: false,
                                  color: b3Color,
                                  type: _fec.feed.type.isRightBreast ? MTButtonType.secondary : MTButtonType.main,
                                  middle: BaseText(loc.feed_type_right_breast),
                                  onTap: () => _fec.setFeedType(FeedingType.right_breast),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: P2),

              /// редактор количества (только для бутылочек)
              if (_fec.feed.type.isBottle) ...[FoodCountEditor(_fec.feed), const SizedBox(height: P2)],

              /// время начала (только для грудного кормления)
              if (_fec.feed.type.isBreast)
                MTCard(
                  margin: const EdgeInsets.symmetric(vertical: P, horizontal: P3),
                  radius: 40,
                  elevation: 0,
                  child: MTListTile(
                    leading: const MTImage('time', height: 60),
                    middle: BaseText(_fec.feed.editFeedStartDateTitle),
                    subtitle: H2(_fec.feed.startDateTime),
                    bottomDivider: false,
                    onTap: _editStart,
                  ),
                ),
              if (_fec.feed.type.isBreast) const SizedBox(height: P2),

              /// редактор времени окончания
              MTCard(
                margin: const EdgeInsets.symmetric(vertical: P, horizontal: P3),
                radius: 40,
                elevation: 0,
                child: MTListTile(
                  leading: const MTImage('time', height: 60),
                  middle: BaseText(_fec.feed.editFeedDateTimeTitle),
                  subtitle: H2(_fec.feed.endDateTime),
                  bottomDivider: false,
                  onTap: _editEnd,
                ),
              ),
            ],
          ),
          hasKBInput: true,
          forceBottomPadding: true,
        );
      },
    );
  }
}
