// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';

import 'colors.dart';
import 'constants.dart';

class MTCircle extends StatelessWidget {
  const MTCircle({
    super.key,
    this.color,
    this.size,
    this.border,
    this.child,
  });

  final Color? color;
  final double? size;
  final Border? border;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? P2,
      height: size ?? P2,
      decoration: BoxDecoration(
        color: (color ?? f2Color).resolve(context),
        shape: BoxShape.circle,
        border: border ?? const Border(),
      ),
      child: child,
    );
  }
}
