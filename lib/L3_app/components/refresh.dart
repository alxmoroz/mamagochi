// Copyright (c) 2023. Alexandr Moroz

import 'package:flutter/material.dart';

import 'constants.dart';
import 'gesture.dart';

class MTRefresh extends StatelessWidget with GestureManaging {
  const MTRefresh({super.key, required this.onRefresh, required this.child});

  final Widget child;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => tapAction(true, onRefresh, fbType: FeedbackType.light),
      edgeOffset: MediaQuery.of(context).padding.top,
      displacement: P2,
      child: child,
    );
  }
}
