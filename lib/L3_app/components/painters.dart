// Copyright (c) 2022. Alexandr Moroz

import 'package:flutter/cupertino.dart';

class TrianglePainter extends CustomPainter {
  TrianglePainter({required this.color})
      : _paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
  final Paint _paint;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
        Path()
          ..moveTo(0, size.height)
          ..lineTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..close(),
        _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
