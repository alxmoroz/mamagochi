// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';

import 'colors.dart';
import 'constants.dart';
import 'icons.dart';
import 'list_tile.dart';
import 'text.dart';

class MTGridButtonItem {
  MTGridButtonItem(this.value, this.title, {this.iconData});
  final String value;
  final String title;
  final IconData? iconData;
}

class MTGridButton extends StatelessWidget {
  const MTGridButton(
    this.items, {
    this.onChanged,
    this.value,
    this.padding,
    super.key,
  });
  final List<MTGridButtonItem> items;
  final Function(String?)? onChanged;
  final String? value;
  final EdgeInsets? padding;

  Widget _content(BuildContext context, MTGridButtonItem item, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (item.iconData != null) ...[
          MTIcon(item.iconData, color: color),
          const SizedBox(width: P),
        ],
        BaseText(item.title, maxLines: 1, align: TextAlign.center, color: color),
      ],
    );
  }

  Widget _segment(BuildContext context, MTGridButtonItem item, double width) {
    return Flexible(
      child: MTListTile(
        middle: _content(context, item, f2Color),
        minHeight: MIN_BTN_HEIGHT,
        padding: EdgeInsets.zero,
        color: f3Color.withOpacity(0.2),
        bottomDivider: false,
        onTap: onChanged != null ? () => onChanged!(item.value) : null,
      ),
    );
  }

  Widget _activeSegment(BuildContext context, double width) {
    int index = 0;
    MTGridButtonItem? item;

    for (; index < items.length; index++) {
      item = items[index];
      if (item.value == value) {
        break;
      }
    }

    const innerBorderW = P_2;
    const extraW = P2;

    return item != null
        ? AnimatedPositioned(
            top: innerBorderW,
            left: index < items.length - 1 ? (index == 0 ? innerBorderW : -extraW / 2) + index * width : null,
            right: index == items.length - 1 ? innerBorderW : null,
            width: width + P2,
            height: MIN_BTN_HEIGHT - 2 * innerBorderW,
            duration: const Duration(milliseconds: 150),
            child: Container(
              alignment: Alignment.center,
              height: MIN_BTN_HEIGHT,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(MIN_BTN_HEIGHT / 2)),
                color: b3Color.resolve(context),
              ),
              child: _content(context, item, mainColor),
            ),
          )
        : const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (_, size) {
          final btnWidth = size.maxWidth / items.length;
          return Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(MIN_BTN_HEIGHT / 2))),
            child: Stack(
              children: [
                Row(children: [for (MTGridButtonItem i in items) _segment(context, i, btnWidth)]),
                _activeSegment(context, btnWidth),
              ],
            ),
          );
        },
      ),
    );
  }
}
