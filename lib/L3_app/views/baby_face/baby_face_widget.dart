import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import 'baby_face_assets.dart';
import 'baby_face_config.dart';

class BabyFaceWidget extends StatefulWidget {
  const BabyFaceWidget({required this.config, this.size, this.enableBlink = true, super.key});

  /// Размер холста SVG (viewBox). Совпадает с бывшими PNG малыша.
  static const viewBoxSize = 200.0;

  final BabyFaceConfig config;
  final double? size;
  final bool enableBlink;

  @override
  State<BabyFaceWidget> createState() => _BabyFaceWidgetState();
}

class _BabyFaceWidgetState extends State<BabyFaceWidget> with SingleTickerProviderStateMixin {
  static const _blinkInterval = Duration(seconds: 10);
  static const _blinkCloseDuration = Duration(milliseconds: 110);
  static const _blinkHoldDuration = Duration(milliseconds: 40);
  static const _blinkOpenDuration = Duration(milliseconds: 140);

  static const _openEyes = {
    BabyFaceAssets.eyesBlueOpen,
    BabyFaceAssets.eyesBlueOpenLeft,
    BabyFaceAssets.eyesBlueOpenRight,
  };

  late final AnimationController _blinkController;
  Timer? _blinkTimer;

  bool get _canBlink => widget.enableBlink && widget.config.layers.any(_openEyes.contains);

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(vsync: this);
    _scheduleBlink();
  }

  @override
  void didUpdateWidget(covariant BabyFaceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_canBlink && _blinkController.value != 0) {
      _blinkController.value = 0;
    }
    if (oldWidget.enableBlink != widget.enableBlink) {
      _scheduleBlink();
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _blinkController.dispose();
    super.dispose();
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = null;
    if (!widget.enableBlink) return;
    _blinkTimer = Timer.periodic(_blinkInterval, (_) => _blink());
  }

  Future<void> _blink() async {
    if (!mounted || !_canBlink || _blinkController.isAnimating) return;

    _blinkController.duration = _blinkCloseDuration;
    await _blinkController.forward();
    if (!mounted) return;

    await Future.delayed(_blinkHoldDuration);
    if (!mounted) return;

    if (!_canBlink) {
      _blinkController.value = 0;
      return;
    }

    _blinkController.duration = _blinkOpenDuration;
    await _blinkController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final side = widget.size ?? _defaultSize(context);

    return SizedBox(
      width: side,
      height: side,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: BabyFaceWidget.viewBoxSize,
          height: BabyFaceWidget.viewBoxSize,
          child: Stack(
            alignment: Alignment.center,
            children: [for (final layer in widget.config.layers) _buildLayer(layer)],
          ),
        ),
      ),
    );
  }

  Widget _buildLayer(String name) {
    if (!_openEyes.contains(name)) return _svg(name);

    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, _) {
        final t = _blinkController.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(opacity: 1 - t, child: _svg(name)),
            Opacity(opacity: t, child: _svg(BabyFaceAssets.eyesClosed)),
          ],
        );
      },
    );
  }

  Widget _svg(String name) => SvgPicture.asset(
    BabyFaceAssets.assetPath(name),
    width: BabyFaceWidget.viewBoxSize,
    height: BabyFaceWidget.viewBoxSize,
    fit: BoxFit.contain,
  );

  double _defaultSize(BuildContext context) => min(200, max(120, MediaQuery.sizeOf(context).height / 3.5));
}
