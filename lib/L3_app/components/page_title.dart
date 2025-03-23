// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/cupertino.dart';

import 'colors.dart';
import 'constants.dart';
import 'text.dart';

class PageTitle extends StatelessWidget {
  const PageTitle(this.pageTitle, {super.key, this.parentPageTitle});

  final String? parentPageTitle;
  final String pageTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: P8,
      padding: const EdgeInsets.symmetric(horizontal: P6),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (parentPageTitle != null)
            SmallText(
              parentPageTitle!,
              align: TextAlign.center,
              maxLines: 1,
              color: f3Color,
              padding: const EdgeInsets.only(bottom: P_2),
            ),
          BaseText.medium(pageTitle, align: TextAlign.center, color: f2Color, maxLines: 1),
        ],
      ),
    );
  }
}
