// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import 'constants.dart';

part 'toolbar_controller.g.dart';

class MTToolbarController extends _Base with _$MTToolbarController {
  MTToolbarController({
    bool isCompact = false,
    double wideWidth = 278.0,
    double height = P10,
  }) {
    compact = isCompact;
    _height = height;
    _wideWidth = wideWidth;
    _compactWidth = kIsWeb ? P11 : P12;
  }

  void setupAnimation(TickerProvider vsync, VoidCallback animationListener) {
    if (_ac == null) {
      _ac = AnimationController(
        value: 1.0,
        vsync: vsync,
        duration: KB_RELATED_ANIMATION_DURATION,
        reverseDuration: KB_RELATED_ANIMATION_DURATION,
      );

      _ac!.addListener(() {
        _updateAnimationValue();
        animationListener();
      });
    }
  }

  void setHidden(bool hide) {
    _setHidden(hide);
    if (_ac != null) {
      if (hide) {
        _ac!.reverse();
      } else {
        _ac!.forward();
      }
    }
  }

  void dispose() => _ac?.dispose();
}

abstract class _Base with Store {
  late final double _wideWidth;
  late final double _compactWidth;

  AnimationController? _ac;

  @observable
  double? _animationValue;
  @action
  void _updateAnimationValue() => _animationValue = _ac?.value;

  @observable
  bool compact = false;
  @action
  void setCompact(bool value) => compact = value;

  @observable
  bool hidden = false;
  @action
  void _setHidden(bool value) => hidden = value;

  @observable
  double _height = 0;
  @action
  void setHeight(double value) => _height = value;

  @computed
  double get width => hidden
      ? 0
      : compact
          ? _compactWidth
          : _wideWidth;

  @computed
  double get height => _height * (_animationValue ?? 1);

  @mustCallSuper
  @action
  void toggleWidth() => compact = !compact;
}
