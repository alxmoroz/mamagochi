// Copyright (c) 2026. Xenia Moroz

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../L1_domain/entities/feed.dart';
import '../../../components/button.dart';
import '../../../components/card.dart';
import '../../../components/colors.dart';
import '../../../components/constants.dart';
import '../../../components/dialog.dart';
import '../../../components/field_data.dart';
import '../../../components/gesture.dart';
import '../../../components/icons.dart';
import '../../../components/text.dart';
import '../../../components/text_field.dart';
import '../../_base/edit_controller.dart';
import '../../_base/loader_screen.dart';
import '../../app/services.dart';
import '../../history/edit_feed_controller.dart';
import '../../history/food_count_editor.dart';
import 'bottle_amount_column.dart';

/// Полноэкранный шаг выбора количества для бутылочки.
/// Возвращает `true`, если нажали «Сохранить»; иначе запись остаётся без снэкбара.
class BottleCountStep extends StatefulWidget {
  const BottleCountStep._(this._fec);

  final EditFeedController _fec;

  static Future<bool?> show(Feed feed) async => await showMTDialog(BottleCountStep._(EditFeedController(feed)), forceCenter: true);

  @override
  State<BottleCountStep> createState() => _BottleCountStepState();
}

class _BottleCountStepState extends State<BottleCountStep> {
  late final _BottleCountStepController _controller;

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

  static const _iconEdgePadding = 24.0;

  Widget _sideButton({required String icon, required bool isLeft, required double size, required VoidCallback? onTap}) {
    final iconAlign = isLeft ? Alignment.centerRight : Alignment.centerLeft;
    final iconPadding = EdgeInsets.only(left: isLeft ? 0 : _iconEdgePadding, right: isLeft ? _iconEdgePadding : 0);

    return MTButton(
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
    );
  }

  Widget _textField(BuildContext context) => MTCard(
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

  Widget _columnWithSideButtons({required double columnWidth, required double columnHeight, required int current}) {
    final buttonSize = columnHeight;

    return SizedBox(
      height: columnHeight,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnLeft = (constraints.maxWidth - columnWidth) / 2;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              /// минус слева — круглая, уезжает за край
              Positioned(
                left: columnLeft - P3 - buttonSize,
                top: 0,
                child: _sideButton(icon: 'minus', isLeft: true, size: buttonSize, onTap: current > 0 ? _decrement : null),
              ),

              /// столбец по центру
              Positioned(
                left: columnLeft,
                top: 0,
                width: columnWidth,
                height: columnHeight,
                child: BottleAmountColumn(valueMl: current, onChanged: _onColumnChanged, onChangeEnd: _onColumnChangeEnd),
              ),

              /// плюс справа — круглая, уезжает за край
              Positioned(
                left: columnLeft + columnWidth + P3,
                top: 0,
                child: _sideButton(icon: 'plus', isLeft: false, size: buttonSize, onTap: current < foodCountMax ? _increment : null),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hc = mainController.selectedBabyController!.historyController;
    final screen = MediaQuery.sizeOf(context);
    final columnWidth = min(180.0, screen.width * 0.36);
    final columnHeight = min(360.0, screen.height * 0.48);
    final current = _controller.currentCountFromField;

    return Observer(
      builder: (_) {
        if (hc.loading) return LoaderScreen(hc);

        return SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(false),
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {}, // не закрывать по тапу внутри содержимого
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _columnWithSideButtons(columnWidth: columnWidth, columnHeight: columnHeight, current: current),
                          const SizedBox(height: P2),
                          SizedBox(width: columnWidth, child: _textField(context)),
                        ],
                      ),
                    ),
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
      },
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
