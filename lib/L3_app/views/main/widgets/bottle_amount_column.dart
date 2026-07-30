// Copyright (c) 2026. Xenia Moroz

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../components/colors.dart';
import '../../../components/constants.dart';
import '../../../components/mt_slider.dart';
import '../../../components/text.dart';

/// Визуальный максимум столбца (мл). Значения выше показываются как полное заполнение.
const bottleColumnMaxMl = 260;

/// Шаг свайпа / подписей без текста.
const bottleColumnStepMl = 10;

/// Подписи на шкале (последняя с текстом — 220; 260 — край без подписи).
const bottleColumnLabelMls = [20, 60, 100, 140, 180, 220];

/// Вертикальный «столб» объёма (как диспенсер AquaLife): свайп и тап, заполнение снизу вверх.
class BottleAmountColumn extends StatefulWidget {
  const BottleAmountColumn({
    super.key,
    required this.valueMl,
    required this.onChanged,
    required this.onChangeEnd,
  });

  /// Фактическое количество (может быть > [bottleColumnMaxMl]).
  final int valueMl;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onChangeEnd;

  @override
  State<BottleAmountColumn> createState() => _BottleAmountColumnState();
}

class _BottleAmountColumnState extends State<BottleAmountColumn> {
  late int _localMl;
  bool _dragging = false;
  int? _lastHapticMl;

  @override
  void initState() {
    super.initState();
    _localMl = widget.valueMl.clamp(0, bottleColumnMaxMl);
    _lastHapticMl = _localMl;
  }

  @override
  void didUpdateWidget(covariant BottleAmountColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Не затирать позицию пальца: внешние изменения (+/−, поле) — только вне жеста.
    if (!_dragging && oldWidget.valueMl != widget.valueMl) {
      _localMl = widget.valueMl.clamp(0, bottleColumnMaxMl);
      _lastHapticMl = _localMl;
    }
  }

  int _mlFromSlider(dynamic lowerValue) {
    final raw = lowerValue is num ? lowerValue.toDouble() : 0.0;
    final stepped = (raw / bottleColumnStepMl).round() * bottleColumnStepMl;
    return stepped.clamp(0, bottleColumnMaxMl);
  }

  void _hapticIfStepChanged(int ml) {
    if (_lastHapticMl == ml) return;
    _lastHapticMl = ml;
    HapticFeedback.selectionClick();
  }

  void _onDragUpdate(dynamic lowerValue) {
    final ml = _mlFromSlider(lowerValue);
    _hapticIfStepChanged(ml);
    if (_localMl != ml) {
      setState(() => _localMl = ml);
    }
    widget.onChanged(ml);
  }

  void _onDragEnd(dynamic lowerValue) {
    final ml = _mlFromSlider(lowerValue);
    _hapticIfStepChanged(ml);
    setState(() {
      _dragging = false;
      _localMl = ml;
    });
    widget.onChangeEnd(ml);
  }

  Color _labelColor(BuildContext context, int ml, {required bool numbered}) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    // В тёмной теме жидкость светлая — подписи в заполненной зоне как F2/F3 светлой темы.
    if (isDark && _localMl >= ml) {
      return numbered ? f2Color.color : f3Color.color;
    }
    return numbered ? f2Color : f3Color;
  }

  int _percentForMl(int ml) => ((ml / bottleColumnMaxMl) * 100).round().clamp(0, 100);

  List<MTSliderHatchMarkLabel> _labels(BuildContext context) {
    final labels = <MTSliderHatchMarkLabel>[];

    // Промежуточные чёрточки каждые 10 мл (без цифр). Числовые — поверх, чтобы не перекрывались.
    for (var ml = bottleColumnStepMl; ml < bottleColumnMaxMl; ml += bottleColumnStepMl) {
      if (bottleColumnLabelMls.contains(ml)) continue;
      labels.add(
        MTSliderHatchMarkLabel(
          percent: _percentForMl(ml),
          label: SmallText(
            '—',
            color: _labelColor(context, ml, numbered: false),
            align: TextAlign.center,
          ),
        ),
      );
    }

    for (final ml in bottleColumnLabelMls) {
      labels.add(
        MTSliderHatchMarkLabel(
          percent: _percentForMl(ml),
          label: SmallText(
            '—  $ml  —',
            color: _labelColor(context, ml, numbered: true),
          ),
        ),
      );
    }

    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final liquid = bottleLiquidColor.resolve(context);
    final trackWidth = MediaQuery.sizeOf(context).shortestSide;
    const borderWidth = 5.0;
    const outerRadius = DEF_BORDER_RADIUS * 2;
    // Скругление жидкости по внутреннему краю обводки, иначе «выпирает» из-за clip по внешнему радиусу.
    final innerRadius = (outerRadius - borderWidth).clamp(0.0, outerRadius);

    return Container(
      decoration: BoxDecoration(
        color: bottleColor.resolve(context),
        border: Border.all(color: b3Color.resolve(context), width: borderWidth),
        borderRadius: BorderRadius.circular(outerRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: MTSlider(
          min: 0,
          max: bottleColumnMaxMl.toDouble(),
          step: MTSliderStep(step: bottleColumnStepMl.toDouble()),
          rtl: true,
          jump: true,
          selectByTap: true,
          tooltip: MTSliderTooltip(disabled: true),
          handlerHeight: 0,
          handler: MTSliderHandler(child: const SizedBox.shrink()),
          trackBar: MTSliderTrackBar(
            activeTrackBarHeight: trackWidth,
            activeTrackBar: BoxDecoration(
              color: liquid,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(innerRadius)),
            ),
            inactiveTrackBar: const BoxDecoration(color: Colors.transparent),
          ),
          hatchMark: MTSliderHatchMark(
            // Риски через labels: displayLines уезжают за клип при полной ширине трека.
            displayLines: false,
            // Компактный бокс, чтобы чёрточки каждые 10 мл не разъезжались по вертикали.
            labelBox: const MTSliderSizedBox(height: 18, width: 50),
            labels: _labels(context),
          ),
          values: [_localMl.toDouble()],
          axis: Axis.vertical,
          onDragStarted: (handlerIndex, lowerValue, upperValue) {
            _dragging = true;
          },
          onDragging: (handlerIndex, lowerValue, upperValue) => _onDragUpdate(lowerValue),
          onDragCompleted: (handlerIndex, lowerValue, upperValue) => _onDragEnd(lowerValue),
        ),
      ),
    );
  }
}
