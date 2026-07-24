// Copyright (c) 2026. Xenia Moroz

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../L1_domain/entities/feed.dart';
import '../../../components/adaptive.dart';
import '../../../components/button.dart';
import '../../../components/card.dart';
import '../../../components/colors.dart';
import '../../../components/constants.dart';
import '../../../components/dialog.dart';
import '../../../components/field_data.dart';
import '../../../components/gesture.dart';
import '../../../components/icons.dart';
import '../../../components/images.dart';
import '../../../components/text.dart';
import '../../../components/text_field.dart';
import '../../_base/edit_controller.dart';
import '../../app/services.dart';
import '../../history/edit_feed_controller.dart';
import '../../history/food_count_editor.dart';
import 'bottle_amount_column.dart';

/// Полноэкранный шаг выбора количества для бутылочки.
/// Возвращает `true` при «Сохранить» или тапе по свободной области (снэкбар);
/// `null`/`false` — шаг закрыт иначе (без снэкбара).
class BottleCountStep extends StatefulWidget {
  const BottleCountStep._(this._fec);

  final EditFeedController _fec;

  static Future<bool?> show(Feed feed) async => await showMTDialog(BottleCountStep._(EditFeedController(feed)), forceCenter: true);

  @override
  State<BottleCountStep> createState() => _BottleCountStepState();
}

class _BottleCountStepState extends State<BottleCountStep> {
  late final _BottleCountStepController _controller;

  /// Сохраняет Element поля при смене раскладки (ландшафт + клавиатура), чтобы не терять фокус.
  final GlobalKey _mlFieldKey = GlobalKey();

  EditFeedController get _fec => widget._fec;

  @override
  void initState() {
    super.initState();
    _controller = _BottleCountStepController(fec: _fec);
    _controller.teController(0)?.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _controller.teController(0)?.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  Future _persistCount(int count) async {
    await _controller.applyCount(count);
    if (mounted) setState(() {});
  }

  void _onColumnChanged(int ml) {
    _controller.syncField(ml);
    setState(() {});
  }

  Future _onColumnChangeEnd(int ml) async {
    await _persistCount(ml);
  }

  Future _increment() async {
    await _controller.incrementCount();
    if (mounted) setState(() {});
  }

  Future _decrement() async {
    await _controller.decrementCount();
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    unfocusAll();
    await _controller.flushPendingText();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  /// Свободная область: при открытой клавиатуре — только закрыть её;
  /// иначе — как «Сохранить» (снэкбар).
  void _onBackgroundTap() {
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      unfocusAll();
      return;
    }
    _save();
  }

  static const _iconEdgePadding = 24.0;

  Widget _sideButton({
    required String icon,
    required bool isLeft,
    required double size,
    required bool iconCentered,
    required VoidCallback? onTap,
  }) {
    final iconAlign = iconCentered
        ? Alignment.center
        : (isLeft ? Alignment.centerRight : Alignment.centerLeft);
    final iconPadding = iconCentered
        ? EdgeInsets.zero
        : EdgeInsets.only(left: isLeft ? 0 : _iconEdgePadding, right: isLeft ? _iconEdgePadding : 0);

    // ExcludeFocus: OutlinedButton иначе забирает фокус у поля и закрывает клавиатуру.
    return ExcludeFocus(
      child: MTButton(
        minSize: Size.square(size),
        color: b3Color,
        type: MTButtonType.main,
        uf: false,
        constrained: false,
        middle: SizedBox(
          width: size,
          height: size,
          child: Align(
            alignment: iconAlign,
            child: Padding(padding: iconPadding, child: MTSvgIcon(icon, size: 48)),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _textField(BuildContext context) => MTCard(
    key: _mlFieldKey,
    margin: const EdgeInsets.symmetric(vertical: P),
    radius: 40,
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, P3, 0, 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MTTextField(
            controller: _controller.teController(0),
            focusNode: _controller.focusNode(0),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            autofocus: false,
            style: const H1('', color: f1Color).style(context),
            margin: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            inputFormatters: foodCountInputFormatters,
            onChanged: _controller.updateCountFromText,
          ),
          SmallText(loc.milliliters, align: TextAlign.center, color: f2Color),
        ],
      ),
    ),
  );

  /// Соска над столбцом: только портрет или большой экран; скрыта при клавиатуре. SVG 156×121.
  static const _pacifierAspect = 121 / 156;

  String get _pacifierAssetName =>
      _fec.feed.type.isMilkBottle ? 'bottle_pacifier_milk' : 'bottle_pacifier_baby_formula';

  bool _shouldShowPacifier(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom == 0 &&
      (isBigScreen(context) || MediaQuery.orientationOf(context) == Orientation.portrait);

  Widget _columnWithSideButtons({
    required BuildContext context,
    required double columnWidth,
    required double columnHeight,
    required int current,
  }) {
    final buttonSize = columnHeight;
    final showPacifier = _shouldShowPacifier(context);
    final pacifierHeight = showPacifier ? columnWidth * _pacifierAspect : 0.0;
    final totalHeight = columnHeight + pacifierHeight;

    return SizedBox(
      height: totalHeight,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnLeft = (constraints.maxWidth - columnWidth) / 2;
          final minusLeft = columnLeft - P3 - buttonSize;
          final plusLeft = columnLeft + columnWidth + P3;
          // Иконка по центру, если кнопка целиком на экране; иначе прижата к внутреннему краю.
          final minusFits = minusLeft >= 0;
          final plusFits = plusLeft + buttonSize <= constraints.maxWidth;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              /// минус слева — круглая, уезжает за край (на уровне столбца, не соски)
              Positioned(
                left: minusLeft,
                top: pacifierHeight,
                child: _sideButton(
                  icon: 'minus',
                  isLeft: true,
                  size: buttonSize,
                  iconCentered: minusFits,
                  onTap: current > 0 ? _decrement : null,
                ),
              ),

              /// соска + столбец по центру, вплотную
              Positioned(
                left: columnLeft,
                top: 0,
                width: columnWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showPacifier)
                      MTSvgImage(_pacifierAssetName, width: columnWidth, height: pacifierHeight),
                    SizedBox(
                      width: columnWidth,
                      height: columnHeight,
                      child: BottleAmountColumn(
                        valueMl: current,
                        onChanged: _onColumnChanged,
                        onChangeEnd: _onColumnChangeEnd,
                      ),
                    ),
                  ],
                ),
              ),

              /// плюс справа — круглая, уезжает за край
              Positioned(
                left: plusLeft,
                top: pacifierHeight,
                child: _sideButton(
                  icon: 'plus',
                  isLeft: false,
                  size: buttonSize,
                  iconCentered: plusFits,
                  onTap: current < foodCountMax ? _increment : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Поле мл; при [showSteppers] — − и + по бокам (ландшафт + клавиатура + не big screen).
  /// Слот поля в дереве фиксирован (Expanded всегда в центре Row) — иначе теряется фокус.
  Widget _countFieldRow({
    required BuildContext context,
    required int current,
    required bool showSteppers,
    required double fieldWidth,
  }) {
    const buttonSize = 56.0;

    Widget? sideButton({required String icon, required bool isLeft, required VoidCallback? onTap}) {
      if (!showSteppers) return null;
      return _sideButton(
        icon: icon,
        isLeft: isLeft,
        size: buttonSize,
        iconCentered: true,
        onTap: onTap,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: showSteppers ? P3 : 0),
      child: Row(
        children: [
          SizedBox(
            width: showSteppers ? buttonSize : 0,
            height: showSteppers ? buttonSize : 0,
            child: sideButton(icon: 'minus', isLeft: true, onTap: current > 0 ? _decrement : null),
          ),
          SizedBox(width: showSteppers ? P2 : 0),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: showSteppers ? double.infinity : fieldWidth),
                child: _textField(context),
              ),
            ),
          ),
          SizedBox(width: showSteppers ? P2 : 0),
          SizedBox(
            width: showSteppers ? buttonSize : 0,
            height: showSteppers ? buttonSize : 0,
            child: sideButton(
              icon: 'plus',
              isLeft: false,
              onTap: current < foodCountMax ? _increment : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final keyboardInset = mq.viewInsets.bottom;
    final keyboardOpen = keyboardInset > 0;
    final isLandscape = mq.orientation == Orientation.landscape;
    final big = isBigScreen(context);
    // Только по факту клавиатуры — не по фокусу, иначе первый тап сбрасывает фокус при rebuild.
    final hideColumn = isLandscape && keyboardOpen;
    final showInlineSteppers = hideColumn && !big;
    final availableHeight = mq.size.height - mq.padding.vertical - keyboardInset;
    final columnWidth = min(180.0, mq.size.width * 0.36);
    final columnHeight = min(360.0, availableHeight * 0.48);
    final current = _controller.currentCountFromField;

    // Не Observer + LoaderScreen: setCount → editFeed → load() иначе сносит дерево и закрывает клавиатуру.
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!hideColumn) ...[
          _columnWithSideButtons(
            context: context,
            columnWidth: columnWidth,
            columnHeight: columnHeight,
            current: current,
          ),
          const SizedBox(height: P2),
        ],
        _countFieldRow(
          context: context,
          current: current,
          showSteppers: showInlineSteppers,
          fieldWidth: columnWidth,
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              // Фон ловит тапы по пустым местам; контент по shrinkWrap — только свою область.
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _onBackgroundTap,
                        ),
                      ),
                      Align(
                        alignment: keyboardOpen ? Alignment.bottomCenter : Alignment.center,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                          child: ListView(
                            shrinkWrap: true,
                            reverse: keyboardOpen,
                            padding: EdgeInsets.zero,
                            children: [body],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: P3),
              child: MTButton.main(titleText: loc.action_save_title, onTap: _save),
            ),
            const SizedBox(height: P2),
          ],
        ),
      ),
    );
  }
}

class _BottleCountStepController extends EditController {
  _BottleCountStepController({required EditFeedController fec}) : _fec = fec {
    final initial = fec.feed.count ?? 0;
    initState(fds: [MTFieldData(0, text: initial == 0 ? '' : initial.toString())]);
  }

  final EditFeedController _fec;
  Timer? _debounceTimer;

  int get currentCountFromField {
    final text = teController(0)?.text.trim() ?? '';
    if (text.isEmpty) return 0;
    return clampFoodCount(int.tryParse(text) ?? 0);
  }

  void syncField(int count) {
    final c = clampFoodCount(count);
    if (c == 0) {
      teController(0)?.text = '';
    } else {
      teController(0)?.text = c.toString();
    }
  }

  Future applyCount(int count) async {
    final c = clampFoodCount(count);
    syncField(c);
    await _fec.setCount(c);
  }

  void updateCountFromText(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(TEXT_SAVE_DELAY_DURATION, () async {
      final countText = value.trim();
      final count = countText.isEmpty ? 0 : (int.tryParse(countText) ?? 0);
      await applyCount(count);
    });
  }

  /// Сохраняет текст поля сразу (перед «Сохранить», не дожидаясь debounce).
  Future<void> flushPendingText() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    await applyCount(currentCountFromField);
  }

  Future incrementCount() async {
    final next = clampFoodCount(nextFoodCount(currentCountFromField, increment: true));
    await applyCount(next);
  }

  Future decrementCount() async {
    final next = clampFoodCount(nextFoodCount(currentCountFromField, increment: false));
    await applyCount(next);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
