// Copyright (c) 2024. Alexandr Moroz

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

String _assetPath(String name, BuildContext context) {
  final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  return 'assets/images/$name${dark ? '_dark' : ''}.png';
}

double _defaultImageHeight(BuildContext context) => min(200, max(120, MediaQuery.sizeOf(context).height / 3.5));

class MTSvgImage extends StatelessWidget {
  const MTSvgImage(this.name, {this.width, this.height, super.key});
  final String name;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/$name.svg',
      width: width,
      height: height,
    );
  }
}

class MTImage extends StatelessWidget {
  const MTImage(this.name, {super.key, this.height, this.width, this.fallbackName});
  final String? name;
  final double? height;
  final double? width;
  final String? fallbackName;

  @override
  Widget build(BuildContext context) {
    final h = height ?? _defaultImageHeight(context);
    final w = width ?? h;

    return SizedBox(
      width: w,
      height: h,
      child: Image.asset(
        _assetPath(name ?? fallbackName ?? 'no_info', context),
        // isAntiAlias: true,
        // filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => Image.asset(_assetPath(fallbackName ?? 'no_info', context)),
      ),
    );
  }
}
