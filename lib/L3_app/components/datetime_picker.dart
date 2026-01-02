// Copyright (c) 2025. Xenia Moroz

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:mamagochi/L3_app/components/adaptive.dart';
import 'package:mamagochi/L3_app/components/text.dart';

import '../../L1_domain/utils/dates.dart';
import '../views/app/services.dart';
import 'button.dart';
import 'dialog.dart';
import 'toolbar.dart';

class MTDateTimePicker extends StatefulWidget {
  const MTDateTimePicker._(this.title, {this.initialDate});

  final String title;
  final DateTime? initialDate;

  static Future<DateTime?> show(String title, {DateTime? initialDate}) async =>
      await showMTDialog(MTDateTimePicker._(title, initialDate: initialDate));

  @override
  State<MTDateTimePicker> createState() => _State();
}

class _State extends State<MTDateTimePicker> {
  late DateTime _date;

  @override
  void initState() {
    _date = widget.initialDate ?? now;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screen = screenSize(context);
    final datePickerHeight = min(380.0, screen.height * 0.6);

    return MTDialog(
      topBar: MTTopBar(middle: H1(widget.title, maxLines: 1)),
      body: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: datePickerHeight,
            child: CupertinoDatePicker(initialDateTime: _date, maximumDate: now, use24hFormat: true, onDateTimeChanged: (value) => _date = value),
          ),
          MTButton.main(titleText: loc.action_save_title, onTap: () => Navigator.of(context).pop(_date)),
        ],
      ),
      forceBottomPadding: true,
    );
  }
}
