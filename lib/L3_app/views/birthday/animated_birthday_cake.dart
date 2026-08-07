// Copyright (c) 2026. Xenia Moroz

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../components/images.dart';

/// Торт со свечами и тремя независимо мерцающими огоньками.
class AnimatedBirthdayCake extends StatefulWidget {
  const AnimatedBirthdayCake({super.key, this.size = 200});

  final double size;

  @override
  State<AnimatedBirthdayCake> createState() => _AnimatedBirthdayCakeState();
}

class _AnimatedBirthdayCakeState extends State<AnimatedBirthdayCake> with SingleTickerProviderStateMixin {
  static const _cakeAsset = 'birthday_cake/cake_without_flames';
  static const _flames = [
    _FlameSpec(
      asset: 'birthday_cake/cake_left_flame',
      // Основание левого огонька в viewBox 200×200.
      anchor: Alignment(-0.41, -0.63),
      freq1: 7.2,
      freq2: 11.5,
      phase1: 0.4,
      phase2: 1.8,
    ),
    _FlameSpec(
      asset: 'birthday_cake/cake_center_flame',
      anchor: Alignment(0.01, -0.52),
      freq1: 6.1,
      freq2: 13.2,
      phase1: 2.1,
      phase2: 0.7,
    ),
    _FlameSpec(
      asset: 'birthday_cake/cake_right_flame',
      anchor: Alignment(0.41, -0.63),
      freq1: 8.0,
      freq2: 10.3,
      phase1: 1.2,
      phase2: 2.9,
    ),
  ];

  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (!mounted) return;
      setState(() => _elapsed = elapsed);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final t = _elapsed.inMicroseconds / 1e6;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          MTSvgImage(_cakeAsset, height: size, width: size),
          for (final flame in _flames) _buildFlame(flame, size, t),
        ],
      ),
    );
  }

  Widget _buildFlame(_FlameSpec flame, double size, double t) {
    final scaleY = 1 + 0.09 * math.sin(flame.freq1 * t + flame.phase1) + 0.045 * math.sin(flame.freq2 * t + flame.phase2);
    final scaleX = 1 + 0.03 * math.sin(flame.freq2 * t + flame.phase1) + 0.015 * math.sin(flame.freq1 * 0.8 * t + flame.phase2);
    final angle = 0.045 * math.sin(flame.freq1 * 0.75 * t + flame.phase2) + 0.02 * math.sin(flame.freq2 * 1.1 * t + flame.phase1);
    final dy = 1.2 * math.sin(flame.freq1 * 0.55 * t + flame.phase1);
    final opacity = (0.92 + 0.08 * math.sin(flame.freq2 * 0.6 * t + flame.phase2)).clamp(0.85, 1.0);

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Transform.rotate(
          angle: angle,
          alignment: flame.anchor,
          child: Transform.scale(
            scaleX: scaleX,
            scaleY: scaleY,
            alignment: flame.anchor,
            child: MTSvgImage(flame.asset, height: size, width: size),
          ),
        ),
      ),
    );
  }
}

class _FlameSpec {
  const _FlameSpec({
    required this.asset,
    required this.anchor,
    required this.freq1,
    required this.freq2,
    required this.phase1,
    required this.phase2,
  });

  final String asset;
  final Alignment anchor;
  final double freq1;
  final double freq2;
  final double phase1;
  final double phase2;
}
