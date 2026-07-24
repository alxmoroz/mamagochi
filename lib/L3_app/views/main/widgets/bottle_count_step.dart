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

  static Future<bool?> show(Feed feed) async =>
      await showMTDialog(BottleCountStep._(EditFeedController(feed)), forceCenter: true);

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

  Widget _sideButton({required String icon, required VoidCallback? onTap}) => MTButton(
        type: MTButtonType.main,
        color: b3Color,
        uf: false,
        constrained: false,
        middle: MTSvgIcon(icon, size: 40),
        onTap: onTap,
      );

  Widget _textField(BuildContext context) => MTCard(
        margin: const EdgeInsets.symmetric(vertical: P),
        radius: 40,
        elevation: 0,
        child: MTTextField(
          controller: _controller.teController(0),
          focusNode: _controller.focusNode(0),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          autofocus: false,
          style: const H1('', color: f1Color).style(context),
          margin: EdgeInsets.zero,
          inputFormatters: foodCountInputFormatters,
          onChanged: _controller.updateCountFromText,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hc = mainController.selectedBabyController!.historyController;
    final screen = MediaQuery.sizeOf(context);
    final columnWidth = min(140.0, screen.width * 0.36);
    final columnHeight = min(420.0, screen.height * 0.48);
    final current = _controller.currentCountFromField;

    return Observer(
      builder: (_) {
        if (hc.loading) return LoaderScreen(hc);

        return SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(false),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: P3, vertical: P3),
              child: GestureDetector(
                onTap: () {}, // не закрывать по тапу внутри содержимого
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: columnHeight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    width: 72,
                                    child: _sideButton(
                                      icon: 'minus',
                                      onTap: current > 0 ? _decrement : null,
                                    ),
                                  ),
                                  const SizedBox(width: P2),
                                  SizedBox(
                                    width: columnWidth,
                                    child: BottleAmountColumn(
                                      valueMl: current,
                                      onChanged: _onColumnChanged,
                                      onChangeEnd: _onColumnChangeEnd,
                                    ),
                                  ),
                                  const SizedBox(width: P2),
                                  SizedBox(
                                    width: 72,
                                    child: _sideButton(
                                      icon: 'plus',
                                      onTap: current < foodCountMax ? _increment : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: P2),
                            SizedBox(width: columnWidth, child: _textField(context)),
                          ],
                        ),
                      ),
                    ),
                    MTButton.main(
                      titleText: loc.action_save_title,
                      onTap: _save,
                    ),
                    const SizedBox(height: P2),
                  ],
                ),
              ),
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
