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
import '../../components/icons.dart';
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
    final start = await MTDateTimePicker.show(_fec.feed.editFeedStartDateTitle, initialDate: _fec.feed.startDate ?? _fec.feed.created);
    if (start != null) await _fec.setStart(start);
  }

  Future _editEnd() async {
    final end = await MTDateTimePicker.show(_fec.feed.editFeedEndFieldTitle, initialDate: _fec.feed.endDate);
    if (end != null) _fec.setEnd(end);
  }

  Widget _breastTypeButton(BuildContext context, {required bool isLeft, required double size, required Size buttonSize}) {
    final label = isLeft ? loc.feed_type_left_breast : loc.feed_type_right_breast;
    final feedType = isLeft ? FeedingType.left_breast : FeedingType.right_breast;
    final isSelected = isLeft ? _fec.feed.type.isLeftBreast : _fec.feed.type.isRightBreast;
    // Подписи сильнее сдвинуты к центру (size / 2 вместо size / 3)
    final labelPadding = EdgeInsets.only(left: isLeft ? size / 2 : 0, right: isLeft ? 0 : size / 2);
    final labelAlignment = isLeft ? Alignment.centerRight : Alignment.centerLeft;
    final labelWidget = isSelected ? BaseText(label, sizeScale: 20 / 18, weight: FontWeight.w600, color: mainColor) : BaseText(label);

    return Positioned(
      left: isLeft ? -size / 2 : null,
      right: isLeft ? null : -size / 2,
      top: 0,
      child: MTButton(
        minSize: buttonSize,
        color: b3Color,
        type: isSelected ? MTButtonType.secondary : MTButtonType.main,
        borderSide: isSelected ? BorderSide(color: mainColor.resolve(context), width: 3) : null,
        middle: Padding(
          padding: labelPadding,
          child: Align(alignment: labelAlignment, child: labelWidget),
        ),
        onTap: () => _fec.setFeedType(feedType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final screen = screenSize(context);
        final size = min(320.0, min(screen.width, screen.height) - P3);
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
                            clipBehavior: Clip.none,
                            children: [
                              _breastTypeButton(context, isLeft: true, size: size, buttonSize: buttonSize),
                              _breastTypeButton(context, isLeft: false, size: size, buttonSize: buttonSize),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: P2),

              /// редактор количества (только для бутылочек)
              if (_fec.feed.type.isBottle) ...[FoodCountEditor(_fec), const SizedBox(height: P2)],

              /// время начала (только для грудного кормления)
              if (_fec.feed.type.isBreast)
                MTCard(
                  margin: const EdgeInsets.symmetric(vertical: P, horizontal: P3),
                  radius: 40,
                  elevation: 0,
                  child: MTListTile(
                    leading: const MTSvgIcon('bottle_fill', size: 60),
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
                  leading: MTSvgIcon(_fec.feed.type.isBreast ? 'bottle_empty' : 'clock', size: 60),
                  middle: BaseText(_fec.feed.editFeedEndFieldTitle),
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
