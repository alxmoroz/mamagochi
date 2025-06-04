// Copyright (c) 2024. Alexandr Moroz

import 'dart:async';

import 'package:flutter/material.dart';

import 'colors.dart';
import 'constants.dart';
import 'dialog.dart';
import 'list_tile.dart';
import 'text.dart';

Future showMTSnackbar(String text, {TextAlign? titleAlign = TextAlign.center, Widget? trailing, Function()? onTap}) async {
  await showMTDialog(
    _MTSnackbarDialog(text, titleAlign: titleAlign, trailing: trailing, onTap: onTap),
    forceBottomSheet: true,
    barrierColor: Colors.transparent,
  );
}

class _MTSnackbarDialog extends StatefulWidget {
  const _MTSnackbarDialog(this._text, {this.titleAlign, this.trailing, this.onTap});
  final String _text;
  final TextAlign? titleAlign;
  final Widget? trailing;
  final Function()? onTap;

  @override
  State<_MTSnackbarDialog> createState() => _MyAppState();
}

class _MyAppState extends State<_MTSnackbarDialog> {
  late Timer _closingTimer;

  @override
  void initState() {
    _closingTimer = Timer(const Duration(milliseconds: 2500), () {
      if (context.mounted) Navigator.of(context).pop();
    });
    super.initState();
  }

  @override
  void dispose() {
    _closingTimer.cancel();
    super.dispose();
  }

  Future _onTap(BuildContext context) async {
    _closingTimer.cancel();
    Navigator.of(context).pop();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MTDialog(
      topBar: null,
      bgColor: f3Color,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(DEF_BORDER_RADIUS),
        topRight: Radius.circular(DEF_BORDER_RADIUS),
      ),
      body: SafeArea(
        child: MTListTile(
          padding: const EdgeInsets.all(P3).copyWith(bottom: 0),
          color: Colors.transparent,
          middle: H2(
            widget._text,
            color: b3Color,
            align: widget.titleAlign,
            maxLines: 3,
          ),
          trailing: widget.trailing,
          bottomDivider: false,
          onTap: () => _onTap(context),
        ),
      ),
      forceBottomPadding: true,
    );
  }
}
