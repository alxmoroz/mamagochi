// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';

import 'colors.dart';
import 'constants.dart';

class MTCircularProgress extends StatelessWidget {
  const MTCircularProgress({super.key, this.size = P6, this.color = mainColor, this.strokeWidth = 4, this.unbound = false});
  final double size;
  final Color? color;
  final double strokeWidth;
  final bool unbound;

  @override
  Widget build(BuildContext context) {
    final ci = CircularProgressIndicator(
      color: color?.resolve(context),
      strokeWidth: strokeWidth,
      strokeCap: StrokeCap.round,
    );
    return unbound
        ? ci
        : SizedBox(
            height: size,
            width: size,
            child: ci,
          );
  }
}
