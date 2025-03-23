// Copyright (c) 2023. Alexandr Moroz

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../L2_data/services/platform.dart';
import 'colors.dart';
import 'constants.dart';
import 'icons.dart';
import 'list_tile.dart';
import 'toolbar_controller.dart';

class VerticalToolbar extends StatelessWidget implements PreferredSizeWidget {
  const VerticalToolbar(this._tbc, {super.key, required this.child, this.rightSide = true});
  final MTToolbarController _tbc;
  final Widget child;
  final bool rightSide;

  @override
  Size get preferredSize => Size.fromWidth(_tbc.width);

  double get _tgBtnSize => isWeb ? P6 : P7;
  double get _btnDx => _tgBtnSize * 0.2;
  static const _panelColor = b3Color;

  List<BoxShadow> _panelShadow(BuildContext context) => [
        BoxShadow(blurRadius: P_2, offset: Offset(rightSide ? -1 : 1, 0), color: b1Color.resolve(context)),
      ];

  Widget _btnContainer(BuildContext context, double paneWidth, {Widget? child, bool withShadow = false}) {
    final radius = Radius.circular(_tgBtnSize * 0.5);
    return SafeArea(
      left: false,
      right: false,
      child: Container(
        width: paneWidth + _btnDx,
        height: _tgBtnSize,
        decoration: BoxDecoration(
          color: _panelColor.resolve(context),
          borderRadius: BorderRadius.horizontal(
            left: rightSide ? radius : Radius.zero,
            right: rightSide ? Radius.zero : radius,
          ),
          boxShadow: withShadow ? _panelShadow(context) : [],
        ),
        alignment: rightSide ? Alignment.centerLeft : Alignment.centerRight,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mqPadding = MediaQuery.paddingOf(context);
    final paneWidth = (rightSide ? mqPadding.right : mqPadding.left) + preferredSize.width;

    /// Тень для кнопки сворачивания / разворачивания
    final tgBtnShadow = _btnContainer(context, paneWidth, withShadow: true);

    return Observer(builder: (_) {
      /// Панель инструментов с тенью
      final panel = Container(
        padding: EdgeInsets.only(top: _tgBtnSize),
        width: paneWidth,
        decoration: BoxDecoration(
          color: _panelColor.resolve(context),
          borderRadius: BorderRadius.horizontal(
            left: rightSide ? const Radius.circular(DEF_BORDER_RADIUS) : Radius.zero,
            right: rightSide ? Radius.zero : const Radius.circular(DEF_BORDER_RADIUS),
          ),
          boxShadow: _panelShadow(context),
        ),
        child: SafeArea(
          left: !rightSide,
          right: rightSide,
          maintainBottomViewPadding: true,
          child: child,
        ),
      );

      /// Кнопка для сворачивания / разворачивания
      final icon = ChevronCaretIcon(
        size: Size(_tgBtnSize / 5, _tgBtnSize / 9),
        left: rightSide ? _tbc.compact : !_tbc.compact,
      );
      final tgBtn = _btnContainer(
        context,
        paneWidth,
        child: MTListTile(
          padding: EdgeInsets.symmetric(horizontal: _btnDx),
          minHeight: _tgBtnSize,
          bottomDivider: false,
          color: Colors.transparent,
          leading: rightSide ? icon : null,
          trailing: rightSide ? null : icon,
          onTap: _tbc.toggleWidth,
        ),
      );

      return Stack(
        clipBehavior: Clip.none,
        alignment: rightSide ? Alignment.topRight : Alignment.topLeft,
        children: [
          tgBtnShadow,
          panel,
          tgBtn,
        ],
      );
    });
  }
}
