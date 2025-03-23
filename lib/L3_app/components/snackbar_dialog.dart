// Copyright (c) 2024. Alexandr Moroz

import 'dart:async';

import 'package:flutter/material.dart';

import 'colors.dart';
import 'constants.dart';
import 'dialog.dart';
import 'text.dart';

Future showMTSnackbar(String text) async {
  await showMTDialog(
    _MTSnackbarDialog(text),
    forceBottomSheet: true,
    barrierColor: Colors.transparent,
  );
}

class _MTSnackbarDialog extends StatelessWidget {
  const _MTSnackbarDialog(this._text);
  final String _text;

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 1000), () {
      if (context.mounted) Navigator.of(context).pop();
    });

    return MTDialog(
      topBar: null,
      bgColor: f1Color,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(DEF_BORDER_RADIUS),
        topRight: Radius.circular(DEF_BORDER_RADIUS),
      ),
      body: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          H3(
            _text,
            color: b3Color,
            align: TextAlign.center,
            maxLines: 5,
            padding: const EdgeInsets.all(P3).copyWith(bottom: 0),
          ),
        ],
      ),
      forceBottomPadding: true,
    );
  }
}
