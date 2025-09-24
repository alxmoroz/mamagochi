import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mamagochi/L3_app/presenters/entry.dart';
import 'package:mamagochi/L3_app/presenters/feed.dart';
import 'package:mobx/mobx.dart';

import '../../../L1_domain/entities/feed.dart';
import '../../components/adaptive.dart';
import '../../components/button.dart';
import '../../components/card.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/datetime_picker.dart';
import '../../components/dialog.dart';
import '../../components/field_data.dart';
import '../../components/images.dart';
import '../../components/list_tile.dart';
import '../../components/text.dart';
import '../../components/text_field.dart';
import '../../components/toolbar.dart';
import '../_base/edit_controller.dart';
import '../app/services.dart';
import 'history_controller.dart';

part 'edit_feed_dialog.g.dart';

class _EditFeedController extends _Base with _$_EditFeedController {
  _EditFeedController(Feed feedIn) {
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

class EditFeedDialog extends StatelessWidget {
  const EditFeedDialog._(this._fc);
  final _EditFeedController _fc;

  static Future show(Feed feed) async => await showMTDialog(EditFeedDialog._(_EditFeedController(feed)));

  HistoryController get _hc => mainController.selectedBabyController!.historyController;

  Future _editEnd() async {
    final end = await MTDateTimePicker.show(_fc.feed.editFeedDateTimeTitle, initialDate: _fc.feed.endDate);
    if (end != null) _fc.setEnd(end);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final screen = screenSize(context);
      final size = min(180.0, min(screen.width, screen.height) / 2 - P3);
      final buttonSize = Size.square(size);

      return MTDialog(
        topBar: MTTopBar(middle: H1(_fc.feed.editFeedTitle)),
        body: ListView(
          shrinkWrap: true,
          children: [
            _fc.feed.type.isBreast
                ? SizedBox(
                    height: size + P2,
                    child: Stack(
                      children: [
                        /// левая грудь
                        Positioned(
                          left: P2,
                          child: MTButton(
                            minSize: buttonSize,
                            color: b3Color,
                            type: _fc.feed.type.isLeftBreast ? MTButtonType.secondary : MTButtonType.main,
                            middle: const BaseText('Левая'),
                            onTap: () => _fc.setFeedType(FeedingType.left_breast),
                          ),
                        ),

                        /// правая грудь
                        Positioned(
                          right: P2,
                          child: MTButton(
                            minSize: buttonSize,
                            constrained: false,
                            color: b3Color,
                            type: _fc.feed.type.isRightBreast ? MTButtonType.secondary : MTButtonType.main,
                            middle: const BaseText('Правая'),
                            onTap: () => _fc.setFeedType(FeedingType.right_breast),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
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

            /// редактор количества (только для бутылочек)
            if (_fc.feed.type.isBottle) ...[
              const SizedBox(height: P2),
              MTCard(
                margin: const EdgeInsets.symmetric(vertical: P, horizontal: P3),
                radius: 40,
                elevation: 0,
                child: MTTextField(
                  controller: _fc.teController(0),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const H1('', color: f1Color).style(context),
                  margin: EdgeInsets.zero,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: (value) => _fc.editCount(value),
                ),
              ),
            ],
          ],
        ),
        hasKBInput: true,
      );
    });
  }
}
