// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';
import 'package:mamagochi/L3_app/components/colors.dart';
import 'package:mamagochi/L3_app/components/images.dart';
import 'package:mamagochi/L3_app/components/snackbar_dialog.dart';

import '../../../components/constants.dart';
import '../../../components/list_tile.dart';

class BottomMenu extends StatelessWidget implements PreferredSizeWidget {
  const BottomMenu({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(250);

  static const _btnPadding = EdgeInsets.only(top: P2);
  static const _btnMargin = EdgeInsets.all(P2);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: MTListTile(
            minHeight: 200,
            middle: const MTImage('web_icon_dark'),
            margin: _btnMargin,
            padding: _btnPadding,
            bottomDivider: false,
            decoration: const BoxDecoration(
              color: b3Color,
              shape: BoxShape.circle,
            ),
            onTap: () => showMTSnackbar('Поспал'),
          ),
        ),
        Flexible(
          child: MTListTile(
            minHeight: 200,
            middle: const MTImage('web_icon'),
            margin: _btnMargin,
            padding: _btnPadding,
            bottomDivider: false,
            decoration: const BoxDecoration(
              color: b3Color,
              shape: BoxShape.circle,
              //image: DecorationImage(image: ),
            ),
            onTap: () => showMTSnackbar('Покушал'),
          ),
        ),
      ],
    );
  }
}
