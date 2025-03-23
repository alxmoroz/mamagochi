// Copyright (c) 2022. Alexandr Moroz

import 'package:flutter/material.dart';

import '../presenters/number.dart';
import 'adaptive.dart';
import 'colors.dart';
import 'constants.dart';
import 'text.dart';

class MTPrice extends StatelessWidget {
  const MTPrice(
    this.value, {
    super.key,
    this.color,
    this.originalValue,
    this.rowAlign = MainAxisAlignment.center,
    this.size = AdaptiveSize.m,
  });

  final num value;
  final num? originalValue;
  final Color? color;
  final AdaptiveSize size;
  final MainAxisAlignment rowAlign;

  Widget get _actualPrice {
    final text = value.currencyRouble;
    return {
          AdaptiveSize.xs: DSmallText(text, color: color),
          AdaptiveSize.s: D3(text, color: color),
          AdaptiveSize.m: D2(text, color: color),
        }[size] ??
        D2(text, color: color);
  }

  Widget get _originalPrice {
    final text = originalValue!.currencyRouble;
    const decoration = TextDecoration.lineThrough;
    return Padding(
      padding: const EdgeInsets.only(left: P, bottom: P_2),
      child: {
            AdaptiveSize.m: D3(text, color: f2Color, decoration: decoration),
          }[size] ??
          DSmallText(text, color: f2Color, decoration: decoration),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: rowAlign,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _actualPrice,
        if (originalValue != null) _originalPrice,
      ],
    );
  }
}
