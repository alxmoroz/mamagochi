// Copyright (c) 2026. Xenia Moroz

import 'package:flutter/material.dart';

import '../views/app/services.dart';
import 'colors.dart';
import 'constants.dart';
import 'text.dart';

/// Пузырёк-подсказка: текст и кнопка «Понятно». Родитель позиционирует виджет (например, над кнопкой в Overlay).
/// [title] — заголовок H2; если задан, под ним идёт [message] (основной текст).
/// [width] — фиксированная ширина пузырька; если не задана, используется [maxWidth] как верхняя граница.
///
/// [tailOffset] — сдвиг треугольника по горизонтали от центра пузырька (положительное — вправо).
/// Чтобы задать позицию от левого края: передайте (позиция_от_левого - width/2).

class HintBubble extends StatelessWidget {
  const HintBubble({super.key, required this.message, required this.onDismiss, this.title, this.maxWidth = 320, this.width, this.tailOffset = 0});

  final String message;
  final VoidCallback onDismiss;
  final String? title;
  final double maxWidth;
  final double? width;
  final double tailOffset;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = b3Color.resolve(context);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(P3),
          decoration: BoxDecoration(color: bubbleColor, borderRadius: BorderRadius.circular(DEF_BORDER_RADIUS)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[H2(title!, color: f2Color, align: TextAlign.center, maxLines: 2), const SizedBox(height: P2)],
              SmallText(message, color: f2Color, align: TextAlign.center, maxLines: 5),
              const SizedBox(height: P2),
              GestureDetector(
                onTap: onDismiss,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: P2),
                  child: BaseText(loc.ok, color: mainColor, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: Offset(tailOffset, 0),
          child: CustomPaint(size: const Size(20, 10), painter: _BubbleTailPainter(bubbleColor)),
        ),
      ],
    );
    if (width != null) {
      return SizedBox(width: width!, child: content);
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: content,
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  _BubbleTailPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
