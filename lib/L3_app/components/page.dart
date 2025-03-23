// Copyright (c) 2022. Alexandr Moroz

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'adaptive.dart';
import 'background.dart';
import 'colors.dart';
import 'constants.dart';
import 'gesture.dart';
import 'material_wrapper.dart';
import 'scrollable.dart';

class MTPage extends StatelessWidget {
  const MTPage({
    super.key,
    this.navBar,
    required this.body,
    this.bottomBar,
    this.leftBar,
    this.rightBar,
    this.scrollController,
    this.scrollOffsetTop,
    this.onScrolled,
  });

  final PreferredSizeWidget? leftBar;
  final PreferredSizeWidget? rightBar;
  final PreferredSizeWidget? navBar;
  final Widget body;
  final PreferredSizeWidget? bottomBar;

  final ScrollController? scrollController;
  final double? scrollOffsetTop;
  final Function(bool)? onScrolled;

  Widget get _center {
    return material(Builder(builder: (ctx) {
      final mq = MediaQuery.of(ctx);
      final mqPadding = mq.padding.copyWith(
        top: max(mq.padding.top, DEF_PAGE_TOP_PADDING),
        bottom: max(max(mq.viewPadding.bottom, mq.padding.bottom), DEF_PAGE_BOTTOM_PADDING),
      );

      final hasKB = mq.viewInsets.bottom > 0;

      final big = isBigScreen(ctx);

      final scrollable = scrollOffsetTop != null && scrollController != null;
      final bottomBarHeight = bottomBar?.preferredSize.height ?? 0;

      return MTBackgroundWrapper(
        PrimaryScrollController(
          controller: scrollController ?? ScrollController(),
          child: MediaQuery(
            data: mq.copyWith(padding: mqPadding),
            child: Stack(
              children: [
                MediaQuery(
                  data: mq.copyWith(
                    padding: mqPadding.copyWith(
                      top: mqPadding.top + (big && scrollable ? scrollOffsetTop! : (navBar?.preferredSize.height ?? 0)),
                      bottom: (hasKB ? 0 : mqPadding.bottom) + mq.viewInsets.bottom + bottomBarHeight,
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: scrollable
                        ? MTScrollable(
                            scrollController: scrollController!,
                            scrollOffsetTop: scrollOffsetTop!,
                            onScrolled: onScrolled,
                            bottomShadow: bottomBarHeight > 0,
                            topShadowPadding: mqPadding.top + (navBar?.preferredSize.height ?? 0),
                            child: body,
                          )
                        : body,
                  ),
                ),
                if (navBar != null) navBar!,
                if (bottomBar != null) Align(alignment: Alignment.bottomCenter, child: bottomBar!),
              ],
            ),
          ),
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final mqPadding = mq.padding;

    final hasLeftBar = leftBar != null;
    final hasRightBar = rightBar != null;

    return FocusDroppable(
      Container(
        decoration: BoxDecoration(color: b2Color.resolve(context)),
        child: Stack(
          children: [
            hasLeftBar || hasRightBar
                ? Observer(
                    builder: (_) => MediaQuery(
                      data: mq.copyWith(
                        padding: mqPadding.copyWith(
                          left: mqPadding.left + (leftBar?.preferredSize.width ?? 0),
                          right: mqPadding.right + (rightBar?.preferredSize.width ?? 0),
                        ),
                      ),
                      child: _center,
                    ),
                  )
                : _center,
            if (hasLeftBar) leftBar!,
            if (hasRightBar) Align(alignment: Alignment.centerRight, child: rightBar!)
          ],
        ),
      ),
    );
  }
}
