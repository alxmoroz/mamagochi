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

  static const _breastSizeLandscape = 100.0;

  Future _editStart() async {
    final start = await MTDateTimePicker.show(_fec.feed.editFeedStartDateTitle, initialDate: _fec.feed.startDate ?? _fec.feed.created);
    if (start != null) await _fec.setStart(start);
  }

  Future _editEnd() async {
    final end = await MTDateTimePicker.show(_fec.feed.editFeedEndFieldTitle, initialDate: _fec.feed.endDate);
    if (end != null) _fec.setEnd(end);
  }

  Widget _breastTypeButton(
    BuildContext context, {
    required bool isLeft,
    required double size,
    required Size buttonSize,
    required bool hangOffEdge,
    double? left,
    double? right,
  }) {
    final label = isLeft ? loc.feed_type_left_breast : loc.feed_type_right_breast;
    final feedType = isLeft ? FeedingType.left_breast : FeedingType.right_breast;
    final isSelected = isLeft ? _fec.feed.type.isLeftBreast : _fec.feed.type.isRightBreast;

    // Портрет (выезд за край): подпись к центру экрана. Landscape: по центру кнопки.
    final labelPadding = hangOffEdge
        ? EdgeInsets.only(left: isLeft ? size / 2 : 0, right: isLeft ? 0 : size / 2)
        : EdgeInsets.zero;
    final labelAlignment = hangOffEdge
        ? (isLeft ? Alignment.centerRight : Alignment.centerLeft)
        : Alignment.center;
    final labelWidget = isSelected ? BaseText(label, sizeScale: 20 / 18, weight: FontWeight.w600, color: mainColor) : BaseText(label);

    return Positioned(
      left: hangOffEdge ? (isLeft ? -size / 2 : null) : left,
      right: hangOffEdge ? (isLeft ? null : -size / 2) : right,
      top: 0,
      child: MTButton(
        minSize: buttonSize,
        constrained: false,
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

  Widget _breastButtons(BuildContext context, {required double size, required bool isLandscape}) {
    final buttonSize = Size.square(size);

    if (!isLandscape) {
      // Портрет — как было: выезд за края на половину размера.
      return SizedBox(
        height: size + P2,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _breastTypeButton(context, isLeft: true, size: size, buttonSize: buttonSize, hangOffEdge: true),
            _breastTypeButton(context, isLeft: false, size: size, buttonSize: buttonSize, hangOffEdge: true),
          ],
        ),
      );
    }

    // Landscape: 150, целиком на экране, подпись по центру (как FeedTypeDialog / BottleCountStep).
    return SizedBox(
      height: size + P2,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final leftBreastLeft = (constraints.maxWidth - P3) / 2 - size;
          final rightBreastLeft = (constraints.maxWidth + P3) / 2;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              _breastTypeButton(
                context,
                isLeft: true,
                size: size,
                buttonSize: buttonSize,
                hangOffEdge: false,
                left: leftBreastLeft,
              ),
              _breastTypeButton(
                context,
                isLeft: false,
                size: size,
                buttonSize: buttonSize,
                hangOffEdge: false,
                left: rightBreastLeft,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final screen = screenSize(context);
        final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
        final size = isLandscape ? _breastSizeLandscape : min(320.0, min(screen.width, screen.height) - P3);

        return MTDialog(
          topBar: MTTopBar(middle: H2(_fec.feed.editFeedTitle, color: f2Color)),
          body: ListView(
            shrinkWrap: true,
            children: [
              _fec.feed.type.isBreast
                  ? Column(
                      children: [
                        const SizedBox(height: P2),
                        _breastButtons(context, size: size, isLandscape: isLandscape),
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: P2),

              /// редактор количества (только для бутылочек)
              if (_fec.feed.type.isBottle) ...[FoodCountEditor(_fec), const SizedBox(height: P2)],

              /// время начала (только для грудного кормления)
              if (_fec.feed.type.isBreast)
                MTAdaptive.xs(
                  child: MTCard(
                    margin: const EdgeInsets.symmetric(vertical: P),
                    radius: 40,
                    elevation: 0,
                    child: MTListTile(
                      leading: const MTSvgIcon('bottle_fill', size: 60),
                      middle: SmallText.medium(_fec.feed.editFeedStartDateTitle),
                      subtitle: H1(_fec.feed.startDateTime),
                      bottomDivider: false,
                      onTap: _editStart,
                    ),
                  ),
                ),
              if (_fec.feed.type.isBreast) const SizedBox(height: P2),

              /// редактор времени окончания
              MTAdaptive.xs(
                child: MTCard(
                  margin: const EdgeInsets.symmetric(vertical: P),
                  radius: 40,
                  elevation: 0,
                  child: MTListTile(
                    leading: MTSvgIcon(_fec.feed.type.isBreast ? 'bottle_empty' : 'clock', size: 60),
                    middle: SmallText.medium(_fec.feed.editFeedEndFieldTitle),
                    subtitle: H1(_fec.feed.endDateTime),
                    bottomDivider: false,
                    onTap: _editEnd,
                  ),
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
