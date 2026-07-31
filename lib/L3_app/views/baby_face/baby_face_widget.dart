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

class _BabyFaceWidgetState extends State<BabyFaceWidget> with TickerProviderStateMixin {
  /// 0 = глаза открыты, 1 = закрыты. И для моргания, и для сна/пробуждения.
  static const _blinkInterval = Duration(seconds: 10);
  static const _blinkCloseDuration = Duration(milliseconds: 110);
  static const _blinkHoldDuration = Duration(milliseconds: 40);
  static const _blinkOpenDuration = Duration(milliseconds: 140);

  /// Засыпание: веки тяжелеют медленно; пробуждение — чуть быстрее, но всё ещё плавно.
  static const _fallAsleepDuration = Duration(milliseconds: 1400);
  static const _wakeUpDuration = Duration(milliseconds: 1100);

  /// Zzz во сне: дыхание прозрачности + лёгкое увеличение/уменьшение.
  static const _zzzPeriod = Duration(milliseconds: 2200);
  static const _zzzMinOpacity = 0.5;
  static const _zzzMaxOpacity = 1.0;
  static const _zzzMinScale = 0.92;
  static const _zzzMaxScale = 1.06;

  static const _openEyes = {
    BabyFaceAssets.eyesBlueOpen,
    BabyFaceAssets.eyesBlueOpenLeft,
    BabyFaceAssets.eyesBlueOpenRight,
  };

  late final AnimationController _lidController;
  late final AnimationController _zzzController;
  Timer? _blinkTimer;

  /// Последние открытые глаза — нужны, пока в конфиге уже sleep (только closed).
  String _lastOpenEyes = BabyFaceAssets.eyesBlueOpen;

  /// Zzz остаются на время пробуждения, пока веки открываются.
  bool _lingeringZzz = false;

  bool get _canBlink =>
      widget.enableBlink && !widget.config.isSleep && !_lidController.isAnimating && _lidController.value < 0.01;

  @override
  void initState() {
    super.initState();
    _lidController = AnimationController(vsync: this);
    _zzzController = AnimationController(vsync: this, duration: _zzzPeriod);
    if (widget.config.isSleep) {
      _lidController.value = 1;
      _startZzzLoop();
    }
    _rememberOpenEyes(widget.config);
    _scheduleBlink();
  }

  @override
  void didUpdateWidget(covariant BabyFaceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final wasSleep = oldWidget.config.isSleep;
    final isSleep = widget.config.isSleep;

    // Сначала запоминаем открытые глаза из предыдущего конфига — при сне в новом их уже нет.
    if (!wasSleep) _rememberOpenEyes(oldWidget.config);
    _rememberOpenEyes(widget.config);

    if (!wasSleep && isSleep) {
      _fallAsleep();
    } else if (wasSleep && !isSleep) {
      _wakeUp();
    }

    if (oldWidget.enableBlink != widget.enableBlink && !isSleep) {
      _scheduleBlink();
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _lidController.dispose();
    _zzzController.dispose();
    super.dispose();
  }

  void _rememberOpenEyes(BabyFaceConfig config) {
    for (final layer in config.layers) {
      if (_openEyes.contains(layer)) {
        _lastOpenEyes = layer;
        return;
      }
    }
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = null;
    if (!widget.enableBlink || widget.config.isSleep) return;
    _blinkTimer = Timer.periodic(_blinkInterval, (_) => _blink());
  }

  void _startZzzLoop() {
    if (!_zzzController.isAnimating) {
      _zzzController.repeat(reverse: true);
    }
  }

  void _stopZzzLoop({bool reset = false}) {
    _zzzController.stop();
    if (reset) _zzzController.value = 0;
  }

  Future<void> _blink() async {
    if (!mounted || !_canBlink) return;

    _lidController.duration = _blinkCloseDuration;
    await _lidController.forward();
    if (!mounted) return;

    await Future.delayed(_blinkHoldDuration);
    if (!mounted) return;

    if (widget.config.isSleep) return;

    _lidController.duration = _blinkOpenDuration;
    await _lidController.reverse();
  }

  Future<void> _fallAsleep() async {
    _blinkTimer?.cancel();
    _blinkTimer = null;
    _lingeringZzz = false;
    _stopZzzLoop(reset: true);

    _lidController.duration = _fallAsleepDuration;
    await _lidController.animateTo(1, curve: Curves.easeIn);
    if (!mounted || !widget.config.isSleep) return;

    _startZzzLoop();
  }

  Future<void> _wakeUp() async {
    // Замираем текущую фазу zzz и гасим вместе с веками — без скачка позиции.
    _stopZzzLoop();
    _lingeringZzz = true;
    _lidController.duration = _wakeUpDuration;
    await _lidController.animateTo(0, curve: Curves.easeOut);
    if (!mounted) return;

    setState(() => _lingeringZzz = false);
    _stopZzzLoop(reset: true);
    _scheduleBlink();
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
          child: AnimatedBuilder(
            animation: Listenable.merge([_lidController, _zzzController]),
            builder: (context, _) => Stack(
              alignment: Alignment.center,
              children: [
                for (final layer in widget.config.layers) _buildLayer(layer),
                if (_lingeringZzz && !widget.config.layers.contains(BabyFaceAssets.sleepZzz)) _buildZzz(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayer(String name) {
    if (_openEyes.contains(name) || name == BabyFaceAssets.eyesClosed) {
      return _buildEyes(name);
    }
    if (name == BabyFaceAssets.sleepZzz) {
      return _buildZzz();
    }
    return _svg(name);
  }

  Widget _buildZzz() {
    final lid = _lidController.value;
    if (lid <= 0) return const SizedBox.shrink();

    final t = Curves.easeInOut.transform(_zzzController.value);
    final opacity = lid * (_zzzMinOpacity + (_zzzMaxOpacity - _zzzMinOpacity) * t);
    final scale = _zzzMinScale + (_zzzMaxScale - _zzzMinScale) * t;

    return Transform.scale(
      scale: scale,
      alignment: const Alignment(0.55, -0.55),
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: _svg(BabyFaceAssets.sleepZzz),
      ),
    );
  }

  Widget _buildEyes(String eyesLayer) {
    final openAsset = _openEyes.contains(eyesLayer) ? eyesLayer : _lastOpenEyes;
    final t = _lidController.value;

    // Без наложения: сначала только веко по открытому глазу, закрытый — когда открытый уже скрыт.
    if (t >= 1) {
      return _svg(BabyFaceAssets.eyesClosed);
    }
    return ClipRect(
      clipper: _UpperEyelidClipper(t),
      child: _svg(openAsset),
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

/// Верхнее веко: видимая область открытых глаз уменьшается сверху вниз.
class _UpperEyelidClipper extends CustomClipper<Rect> {
  _UpperEyelidClipper(this.progress);

  /// 0 — открыто, 1 — закрыто.
  final double progress;

  /// Верх и низ открытых глаз в viewBox 200×200 (круги глаз: y 69…109).
  static const _eyeTop = 69.0;
  static const _eyeBottom = 109.0;

  @override
  Rect getClip(Size size) {
    final scale = size.height / BabyFaceWidget.viewBoxSize;
    final top = (_eyeTop + (_eyeBottom - _eyeTop) * progress) * scale;
    return Rect.fromLTRB(0, top, size.width, size.height);
  }

  @override
  bool shouldReclip(covariant _UpperEyelidClipper old) => old.progress != progress;
}
