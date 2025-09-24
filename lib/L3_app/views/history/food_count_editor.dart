import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../L1_domain/entities/feed.dart';
import '../../components/card.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/field_data.dart';
import '../../components/text.dart';
import '../../components/text_field.dart';
import '../_base/edit_controller.dart';
import '../app/services.dart';
import 'history_controller.dart';

class _FoodCountEditorController extends EditController {
  _FoodCountEditorController({
    required this.feed,
  }) {
    initState(fds: [MTFieldData(0, text: feed.count?.toString() ?? '')]);
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
    int? count;
    if (countText.isNotEmpty) {
      count = int.tryParse(countText);
    }
    if (count != null) {
      _hc.editFeed(feed.copyWith(count: count));
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

class FoodCountEditor extends StatefulWidget {
  const FoodCountEditor({
    super.key,
    required this.feed,
  });

  final Feed feed;

  @override
  State<FoodCountEditor> createState() => _FoodCountEditorState();
}

class _FoodCountEditorState extends State<FoodCountEditor> {
  late _FoodCountEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _FoodCountEditorController(
      feed: widget.feed,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MTCard(
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
    );
  }
}
