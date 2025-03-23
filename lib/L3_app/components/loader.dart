// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';

import 'circular_progress.dart';
import 'colors.dart';

class MTLoader extends StatelessWidget {
  const MTLoader({super.key, this.radius});
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: b2Color.resolve(context).withAlpha(210),
              borderRadius: BorderRadius.circular(radius ?? 0),
            ),
          ),
          const MTCircularProgress(unbound: true),
        ],
      ),
    );
  }
}
