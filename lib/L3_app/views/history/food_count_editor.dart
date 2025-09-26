import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../L1_domain/entities/feed.dart';
import '../../components/button.dart';
import '../../components/card.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/field_data.dart';
import '../../components/images.dart';
import '../../components/text.dart';
import '../../components/text_field.dart';
import '../_base/edit_controller.dart';
import '../app/services.dart';
import 'history_controller.dart';

const int _countStep = 10;
const int _maxCount = 9999;
const double _buttonSize = 60.0;
const double _imageSize = 30.0;

int _roundUpToTen(int value) => ((value + 9) ~/ 10) * 10;
int _roundDownToTen(int value) => (value ~/ 10) * 10;
int _clampCount(int value) => value.clamp(0, _maxCount);

class _FoodCountEditorController extends EditController {
  _FoodCountEditorController({
    required this.feed,
  }) {
    initState(fds: [MTFieldData(0, text: feed.count?.toString() ?? '0')]);
  }

  final Feed feed;

  HistoryController get _hc => mainController.selectedBabyController!.historyController;
  Timer? _debounceTimer;

  void updateCount(String value) {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(TEXT_SAVE_DELAY_DURATION, () => _saveCount(value));
  }

  void _saveCount(String value) {
    final countText = value.trim();
    final count = countText.isEmpty ? 0 : (int.tryParse(countText) ?? 0);
    _hc.editFeed(feed.copyWith(count: _clampCount(count)));
  }

  void incrementCount() {
    final currentCount = currentCountFromField;
    if (currentCount >= _maxCount) return;

    final roundedUp = _roundUpToTen(currentCount);
    final newCount = currentCount == roundedUp ? currentCount + _countStep : roundedUp;
    _updateCount(_clampCount(newCount));
  }

  void decrementCount() {
    final currentCount = currentCountFromField;
    if (currentCount <= 0) return;

    final roundedDown = _roundDownToTen(currentCount);
    final newCount = currentCount == roundedDown ? currentCount - _countStep : roundedDown;
    _updateCount(_clampCount(newCount));
  }

  int get currentCountFromField {
    final text = teController(0)?.text.trim() ?? '';
    if (text.isEmpty) return 0;
    return _clampCount(int.tryParse(text) ?? 0);
  }

  void _updateCount(int newCount) {
    _hc.editFeed(feed.copyWith(count: newCount));
    teController(0)?.text = newCount.toString();
    focusNode(0)?.requestFocus();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

class FoodCountEditor extends StatefulWidget {
  const FoodCountEditor._(this.feed);
  final Feed feed;

  factory FoodCountEditor(Feed feed) => FoodCountEditor._(feed);

  @override
  State<FoodCountEditor> createState() => _FoodCountEditorState();
}

class _FoodCountEditorState extends State<FoodCountEditor> {
  late _FoodCountEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _FoodCountEditorController(feed: widget.feed);
    _controller.teController(0)?.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _controller.teController(0)?.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCount = _controller.currentCountFromField;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            /// кнопка минус
            MTButton(
              type: MTButtonType.main,
              color: b3Color,
              middle: const MTImage('minus', height: _imageSize),
              minSize: const Size(_buttonSize, _buttonSize),
              onTap: currentCount > 0 ? _controller.decrementCount : null,
            ),
            const SizedBox(width: P3),

            /// кнопка плюс
            MTButton(
              type: MTButtonType.main,
              color: b3Color,
              middle: const MTImage('plus', height: _imageSize),
              minSize: const Size(_buttonSize, _buttonSize),
              onTap: currentCount < _maxCount ? _controller.incrementCount : null,
            ),
          ],
        ),
        const SizedBox(height: P2),

        /// поле ввода количества
        MTCard(
          margin: const EdgeInsets.symmetric(vertical: P, horizontal: P3),
          radius: 40,
          elevation: 0,
          child: MTTextField(
            controller: _controller.teController(0),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const H1('', color: f1Color).style(context),
            margin: EdgeInsets.zero,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: _controller.updateCount,
          ),
        ),
      ],
    );
  }
}
