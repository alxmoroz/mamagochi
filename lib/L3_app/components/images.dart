// Copyright (c) 2024. Alexandr Moroz

import 'dart:math';

import 'package:flutter/cupertino.dart';

enum ImageName {
  app_icon,
  delete,
  done,
  empty_sources,
  empty_tasks,
  finance,
  goal,
  goal_done,
  google_calendar,
  hello,
  import,
  loading,
  mail_icon,
  network_error,
  no_info,
  not_found,
  notifications,
  ok,
  ok_blue,
  overdue,
  privacy,
  promo_features,
  purchase,
  relations,
  risk,
  save,
  server_error,
  sync,
  team,
  telegram_icon,
  transfer,
  upgrade,
  vk_icon,
  web_icon,
}

String _assetPath(String name, BuildContext context) {
  final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  return 'assets/images/$name${dark ? '_dark' : ''}.png';
}

double _defaultImageHeight(BuildContext context) => min(200, max(120, MediaQuery.sizeOf(context).height / 3.5));

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
        errorBuilder: (_, __, ___) => Image.asset(
          _assetPath(fallbackName ?? 'no_info', context),
        ),
      ),
    );
  }
}
