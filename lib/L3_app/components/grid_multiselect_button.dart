// Copyright (c) 2024. Alexandr Moroz

import 'dart:math';

import 'package:flutter/material.dart';

import 'colors.dart';
import 'constants.dart';
import 'grid_button.dart';
import 'list_tile.dart';
import 'text.dart';

class MTGridMultiselectButton extends StatelessWidget {
  const MTGridMultiselectButton(
    this.items, {
    this.onChanged,
    this.values,
    this.padding,
    this.segmentsInRow = 1,
    super.key,
  });
  final List<MTGridButtonItem> items;
  final Function(String?)? onChanged;
  final List<String>? values;
  final EdgeInsets? padding;
  final int segmentsInRow;

  bool _topSiblingSelected(int index) => values?.contains(items[index - segmentsInRow].value) == true;
  bool _leftSiblingSelected(int index) => values?.contains(items[index - 1].value) == true;

  Widget _segmentBuilder(BuildContext context, int row, int col) {
    final index = row * segmentsInRow + col;
    final item = items[index];
    final selected = values?.contains(item.value) == true;
    final int rows = max(1, (items.length / segmentsInRow).ceil());

    final lastRow = row == rows - 1;
    final lastCol = col == segmentsInRow - 1 || index == items.length - 1;

    final topLeftRounded = row == 0 && col == 0;
    final topRightRounded = row == 0 && lastCol;
    final bottomLeftRounded = lastRow && col == 0;
    final bottomRightRounded = lastRow && lastCol;

    final borderSide = BorderSide(color: (selected ? mainColor : b1Color).resolve(context));

    return Flexible(
      child: MTListTile(
        middle: BaseText(
          item.title,
          maxLines: 1,
          align: TextAlign.center,
          color: selected ? mainColor : f2Color,
        ),
        decoration: BoxDecoration(
          color: (selected ? b3Color : f3Color.withOpacity(0.2)).resolve(context),
          border: Border(
            top: (row == 0 || (selected && !_topSiblingSelected(index))) ? borderSide : BorderSide.none,
            bottom: borderSide,
            left: (col == 0 || (selected && !_leftSiblingSelected(index))) ? borderSide : BorderSide.none,
            right: borderSide,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeftRounded ? DEF_BORDER_RADIUS : 0),
            topRight: Radius.circular(topRightRounded ? DEF_BORDER_RADIUS : 0),
            bottomLeft: Radius.circular(bottomLeftRounded ? DEF_BORDER_RADIUS : 0),
            bottomRight: Radius.circular(bottomRightRounded ? DEF_BORDER_RADIUS : 0),
          ),
        ),
        minHeight: MIN_BTN_HEIGHT,
        padding: EdgeInsets.zero,
        bottomDivider: false,
        onTap: onChanged != null ? () => onChanged!(item.value) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        children: [
          for (int row = 0; row < max(1, (items.length / segmentsInRow).ceil()); row++)
            Row(children: [
              for (int col = 0; col < segmentsInRow && row * segmentsInRow + col < items.length; col++) _segmentBuilder(context, row, col)
            ])
        ],
      ),
    );
  }
}
