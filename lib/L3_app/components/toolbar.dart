// Copyright (c) 2024. Alexandr Moroz

import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../navigation/router.dart';
import 'adaptive.dart';
import 'close_dialog_button.dart';
import 'colors.dart';
import 'constants.dart';
import 'page_title.dart';
import 'toolbar_controller.dart';

class _ToolbarContent extends StatelessWidget {
  const _ToolbarContent({
    this.pageTitle,
    this.parentPageTitle,
    this.leading,
    this.middle,
    this.bottom,
    this.trailing,
  });
  final String? pageTitle;
  final String? parentPageTitle;
  final Widget? leading;
  final Widget? middle;
  final Widget? bottom;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (middle != null) middle! else if (pageTitle != null) PageTitle(pageTitle!, parentPageTitle: parentPageTitle),
            Row(children: [
              if (leading != null) leading!,
              const Spacer(),
              if (trailing != null) trailing!,
            ]),
          ],
        ),
        if (bottom != null) bottom!,
      ],
    );
  }
}

abstract class _MTAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MTAppBar({
    required this.isBottom,
    required this.color,
    this.pageTitle,
    this.parentPageTitle,
    this.leading,
    this.middle,
    this.trailing,
    this.bottomWidget,
    this.innerHeight,
    this.topPadding = 0,
    this.bottomPadding = 0,
    this.ignoreBottomInsets = true,
    this.fullScreen = false,
    this.toolbarController,
    super.key,
  });

  final bool isBottom;
  final Color color;

  final String? pageTitle;
  final String? parentPageTitle;

  final Widget? leading;
  final Widget? middle;
  final Widget? trailing;
  final Widget? bottomWidget;

  final double? innerHeight;
  final double topPadding;
  final double bottomPadding;

  final bool ignoreBottomInsets;
  final bool fullScreen;
  final MTToolbarController? toolbarController;

  double get _innerHeight => innerHeight ?? P8;

  @override
  Size get preferredSize => Size.fromHeight(toolbarController != null ? toolbarController!.height : (topPadding + _innerHeight + bottomPadding));

  Widget? get _leading =>
      leading ??
      (!isBottom && router.canPop()
          ? fullScreen
              ? CupertinoNavigationBarBackButton(onPressed: router.pop)
              : const MTCloseDialogButton()
          : null);

  @override
  Widget build(BuildContext context) {
    final mqPadding = MediaQuery.paddingOf(context);
    final big = isBigScreen(context);

    final bottomInsets = ignoreBottomInsets ? 0.0 : MediaQuery.viewInsetsOf(context).bottom;

    final h = (isBottom ? max(bottomInsets, mqPadding.bottom) : mqPadding.top) + preferredSize.height;

    final flat = big || isBottom;

    final toolbarContent = _ToolbarContent(
      pageTitle: pageTitle,
      parentPageTitle: parentPageTitle,
      leading: _leading,
      middle: middle,
      trailing: trailing,
      bottom: bottomWidget,
    );

    return Container(
      height: h,
      color: flat ? color.resolve(context) : null,
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: flat
          ? SafeArea(
              top: !isBottom,
              bottom: isBottom,
              child: toolbarContent,
            )
          : Platform.isAndroid
              ? AppBar(
                  automaticallyImplyLeading: false,
                  title: toolbarContent,
                  backgroundColor: color,
                )
              : CupertinoNavigationBar(
                  automaticallyImplyLeading: false,
                  automaticallyImplyMiddle: false,
                  padding: EdgeInsetsDirectional.only(top: topPadding, bottom: bottomPadding, start: 0, end: 0),
                  leading: OverflowBox(
                    maxHeight: MIN_BTN_HEIGHT,
                    child: toolbarContent,
                  ),
                  backgroundColor: color,
                  border: null,
                ),
    );
  }
}

class MTTopBar extends _MTAppBar {
  const MTTopBar({
    super.pageTitle,
    super.parentPageTitle,
    super.leading,
    super.middle,
    super.trailing,
    super.bottomWidget,
    super.color = b2Color,
    super.innerHeight,
    super.fullScreen,
    super.key,
  }) : super(isBottom: false);
}

class MTNavBar extends MTTopBar {
  const MTNavBar({
    super.pageTitle,
    super.parentPageTitle,
    super.middle,
    super.trailing,
    super.bottomWidget,
    super.color = navbarColor,
    super.innerHeight,
    super.key,
  }) : super(fullScreen: true);
}

class MTBottomBar extends _MTAppBar {
  const MTBottomBar({
    super.leading,
    super.middle,
    super.trailing,
    super.bottomWidget,
    super.color = b2Color,
    super.innerHeight,
    super.topPadding = P2,
    super.bottomPadding,
    super.ignoreBottomInsets,
    super.toolbarController,
    super.key,
  }) : super(isBottom: true);
}
