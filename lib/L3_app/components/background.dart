// Copyright (c) 2023. Alexandr Moroz

import 'package:flutter/cupertino.dart';

import 'adaptive.dart';
import 'colors.dart';

Decoration? backgroundDecoration(BuildContext context, {Color? bg1Color, Color? bg2Color}) => BoxDecoration(
      gradient: LinearGradient(
        colors: [
          (bg1Color ?? b2Color).resolve(context),
          (bg2Color ?? (isBigScreen(context) ? b1Color : b2Color)).resolve(context),
        ],
      ),
    );

class MTBackgroundWrapper extends StatelessWidget {
  const MTBackgroundWrapper(this.child, {super.key, this.bg1Color, this.bg2Color});
  final Color? bg1Color;
  final Color? bg2Color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundDecoration(context, bg1Color: bg1Color, bg2Color: bg2Color),
      child: child,
    );
  }
}
