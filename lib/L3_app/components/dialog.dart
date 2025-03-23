// Copyright (c) 2024. Alexandr Moroz

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../navigation/router.dart';
import 'adaptive.dart';
import 'colors.dart';
import 'constants.dart';
import 'gesture.dart';
import 'material_wrapper.dart';
import 'scrollable.dart';
import 'toolbar.dart';

BoxConstraints _dialogConstrains(BuildContext context, double? maxWidth) {
  final mq = MediaQuery.of(context);
  final big = isBigScreen(context);
  return BoxConstraints(
    maxWidth: big ? min(mq.size.width - P6, maxWidth ?? SCR_S_WIDTH) : double.infinity,
    maxHeight: big ? mq.size.height - (max(mq.padding.vertical, mq.viewPadding.vertical)) - P6 : double.infinity,
  );
}

Widget _constrainedDialog(BuildContext context, Widget child, {double? maxWidth}) {
  return UnconstrainedBox(
    child: ConstrainedBox(
      constraints: _dialogConstrains(context, maxWidth),
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: material(child),
      ),
    ),
  );
}

class MTDialogPage<T> extends Page<T> {
  const MTDialogPage({required this.child, super.name, super.arguments, this.maxWidth, super.key, super.restorationId});

  final Widget child;
  final double? maxWidth;

  @override
  Route<T> createRoute(BuildContext context) => isBigScreen(context)
      ? DialogRoute(
          context: context,
          useSafeArea: false,
          barrierColor: defaultBarrierColor.resolve(context),
          settings: this,
          builder: (_) => _constrainedDialog(context, child, maxWidth: maxWidth),
        )
      : ModalBottomSheetRoute(
          useSafeArea: true,
          constraints: _dialogConstrains(context, maxWidth),
          modalBarrierColor: defaultBarrierColor.resolve(context),
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          settings: this,
          builder: (_) => child,
        );
}

Future<T?> showMTDialog<T>(
  Widget child, {
  double? maxWidth,
  bool forceBottomSheet = false,
  Color? barrierColor,
}) async {
  return !forceBottomSheet && isBigScreen(globalContext)
      ? await showDialog<T?>(
          context: globalContext,
          barrierColor: (barrierColor ?? defaultBarrierColor).resolve(globalContext),
          useRootNavigator: false,
          useSafeArea: false,
          builder: (_) => _constrainedDialog(globalContext, child, maxWidth: maxWidth),
        )
      : await showModalBottomSheet<T?>(
          context: globalContext,
          barrierColor: (barrierColor ?? defaultBarrierColor).resolve(globalContext),
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          useRootNavigator: false,
          useSafeArea: true,
          constraints: _dialogConstrains(globalContext, maxWidth),
          builder: (_) => child,
        );
}

class MTDialog extends StatelessWidget {
  const MTDialog({
    super.key,
    required this.body,
    this.topBar = const MTTopBar(),
    this.bottomBar,
    this.forceBottomPadding = false,
    this.hasKBInput = false,
    this.bottomBarColor,
    this.rightBar,
    this.bgColor,
    this.scrollController,
    this.scrollOffsetTop,
    this.onScrolled,
    this.borderRadius,
  });

  final Widget body;

  final PreferredSizeWidget? topBar;
  final PreferredSizeWidget? rightBar;
  final PreferredSizeWidget? bottomBar;
  final bool forceBottomPadding;
  final bool hasKBInput;
  final Color? bottomBarColor;
  final Color? bgColor;
  final BorderRadiusGeometry? borderRadius;

  final ScrollController? scrollController;
  final double? scrollOffsetTop;
  final Function(bool)? onScrolled;

  Widget get _center {
    return Builder(builder: (context) {
      final mq = MediaQuery.of(context);
      final big = isBigScreen(context);
      final mqPaddingBottom = max(mq.padding.bottom, big ? 0.0 : mq.viewPadding.bottom);
      final bottomBarHeight = bottomBar?.preferredSize.height ?? 0;
      final hasBottomBar = bottomBar != null;
      final needBottomPadding = forceBottomPadding || bottomBarHeight > 0 || (mqPaddingBottom == 0 && !big);
      final minBottomPadding = needBottomPadding ? DEF_DIALOG_BOTTOM_PADDING : 0.0;
      final mqPadding = mq.padding.copyWith(bottom: max(mqPaddingBottom, minBottomPadding));

      return MediaQuery(
        data: mq.copyWith(padding: mqPadding),
        child: Stack(
          children: [
            MediaQuery(
              data: mq.copyWith(
                padding: mqPadding.copyWith(
                  top: (topBar?.preferredSize.height ?? 0),
                  bottom: mqPadding.bottom + bottomBarHeight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: scrollOffsetTop != null && scrollController != null
                    ? MTScrollable(
                        scrollController: scrollController!,
                        scrollOffsetTop: scrollOffsetTop!,
                        onScrolled: onScrolled,
                        bottomShadow: bottomBarHeight > 0,
                        child: body,
                      )
                    : body,
              ),
            ),
            if (topBar != null) topBar!,
            if (hasBottomBar) Positioned(left: 0, right: 0, bottom: 0, child: bottomBar!),
          ],
        ),
      );
    });
  }

  static const _radius = Radius.circular(DEF_BORDER_RADIUS);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final mqPadding = mq.padding;

    final big = isBigScreen(context);

    return FocusDroppable(
      Padding(
        padding: EdgeInsets.only(bottom: hasKBInput ? mq.viewInsets.bottom : 0),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: (bgColor ?? b2Color).resolve(context),
            borderRadius: borderRadius ??
                BorderRadius.only(
                  topLeft: _radius,
                  topRight: _radius,
                  bottomLeft: big ? _radius : Radius.zero,
                  bottomRight: big ? _radius : Radius.zero,
                ),
            boxShadow: [BoxShadow(blurRadius: P, offset: Offset(0, big ? P_2 : -P_2), color: b0Color.resolve(context).withValues(alpha: 0.42))],
          ),
          child: Stack(
            children: [
              rightBar != null
                  ? Observer(
                      builder: (_) => MediaQuery(
                        data: mq.copyWith(
                          padding: mq.padding.copyWith(
                            right: mqPadding.right + (rightBar?.preferredSize.width ?? 0),
                          ),
                        ),
                        child: _center,
                      ),
                    )
                  : _center,
              if (rightBar != null) Align(alignment: Alignment.centerRight, child: rightBar!),
            ],
          ),
        ),
      ),
    );
  }
}
