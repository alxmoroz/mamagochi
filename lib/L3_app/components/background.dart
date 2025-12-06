// Copyright (c) 2023. Alexandr Moroz

import 'package:flutter/cupertino.dart';

import 'colors.dart';

Decoration? backgroundDecoration(BuildContext context, {Color? bg1Color, Color? bg2Color}) {
  final brightness = MediaQuery.platformBrightnessOf(context);
  final isDark = brightness == Brightness.dark;

  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        (bg1Color ?? (isDark ? b2Color : b2GradientColor)).resolve(context),
        (bg2Color ?? (isDark ? b2GradientColor : b2Color)).resolve(context),
      ],
    ),
  );
}

class MTBackgroundWrapper extends StatelessWidget {
  const MTBackgroundWrapper(this.child, {super.key, this.bg1Color, this.bg2Color, this.background});
  final Color? bg1Color;
  final Color? bg2Color;
  final Widget? background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundDecoration(context, bg1Color: bg1Color, bg2Color: bg2Color),
      child: Stack(alignment: Alignment.topLeft, children: [?background, child]),
    );
  }
}
