// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'colors.dart';

const _baseFontSize = kIsWeb ? 17.0 : 18.0;

class BaseText extends StatelessWidget {
  const BaseText(
    this.text, {
    super.key,
    this.sizeScale,
    this.color,
    this.weight,
    this.maxLines,
    this.align,
    this.padding,
    this.height,
    this.decoration,
  });

  const BaseText.f2(
    this.text, {
    super.key,
    this.sizeScale,
    this.weight,
    this.maxLines,
    this.align,
    this.padding,
    this.height,
    this.decoration,
  }) : color = f2Color;

  const BaseText.f3(
    this.text, {
    super.key,
    this.sizeScale,
    this.weight,
    this.maxLines,
    this.align,
    this.padding,
    this.height,
    this.decoration,
  }) : color = f3Color;

  const BaseText.medium(
    this.text, {
    super.key,
    this.sizeScale,
    this.maxLines,
    this.align,
    this.padding,
    this.height,
    this.color,
    this.decoration,
  }) : weight = FontWeight.w500;

  final String text;
  final double? sizeScale;
  final Color? color;
  final FontWeight? weight;
  final int? maxLines;
  final TextAlign? align;
  final EdgeInsets? padding;
  final double? height;
  final TextDecoration? decoration;

  TextStyle style(BuildContext context) {
    final cupertinoTS = CupertinoTheme.of(context).textTheme.textStyle;
    // если указан явно межстрочный интервал, то оставляем его.
    final double h = height ?? {1: 1.0, 2: 1.1, 3: 1.15, 4: 1.2}[maxLines] ?? 1.3;
    final double fs = _baseFontSize * (sizeScale ?? 1);
    final rColor = CupertinoDynamicColor.maybeResolve(color ?? f1Color, context);

    return cupertinoTS.copyWith(
      fontFamily: 'MontserratMamagochi',
      color: rColor,
      decorationColor: rColor,
      fontWeight: weight ?? FontWeight.w400,
      fontSize: fs,
      height: h,
      inherit: true,
      decoration: decoration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Text(
        text,
        style: style(context),
        textAlign: align,
        maxLines: maxLines ?? 1000,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class H1 extends BaseText {
  const H1(
    super.text, {
    super.key,
    super.color = f2Color,
    super.maxLines = 2,
    super.height = 1.1,
    super.align,
    super.padding,
  }) : super(weight: FontWeight.w700, sizeScale: 24 / _baseFontSize);
}

class H2 extends BaseText {
  const H2(
    super.text, {
    super.key,
    super.color,
    super.maxLines = 3,
    super.height = 1.1,
    super.align,
    super.padding,
  }) : super(weight: FontWeight.w500, sizeScale: 24 / _baseFontSize);
}

class SmallText extends BaseText {
  static const _scale = 15 / _baseFontSize;

  const SmallText(
    super.text, {
    super.key,
    super.maxLines = 9,
    super.height,
    super.color = f2Color,
    super.align,
    super.padding,
    super.weight,
  }) : super(sizeScale: _scale);

  const SmallText.medium(
    super.text, {
    super.key,
    super.maxLines = 9,
    super.height,
    super.color = f2Color,
    super.align,
    super.padding,
  }) : super(sizeScale: _scale, weight: FontWeight.w500);
}
