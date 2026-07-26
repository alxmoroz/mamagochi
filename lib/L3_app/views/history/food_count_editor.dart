import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/adaptive.dart';
import '../../components/button.dart';
import '../../components/card.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/field_data.dart';
import '../../components/icons.dart';
import '../../components/text.dart';
import '../../components/text_field.dart';
import '../_base/edit_controller.dart';
import '../app/services.dart';
import 'edit_feed_controller.dart';

const int foodCountStep = 10;
const int foodCountMax = 9999;

int roundFoodCountUpToTen(int value) => ((value + 9) ~/ 10) * 10;
int roundFoodCountDownToTen(int value) => (value ~/ 10) * 10;
int clampFoodCount(int value) => value.clamp(0, foodCountMax);

/// Шаг +/- с «умным» округлением до 10 (как в редакторе количества).
int nextFoodCount(int currentCount, {required bool increment}) {
  final rounded = increment ? roundFoodCountUpToTen(currentCount) : roundFoodCountDownToTen(currentCount);
  if (currentCount == rounded) {
    return currentCount + (increment ? foodCountStep : -foodCountStep);
  }
  return rounded;
}

/// Удаление ведущих нулей из поля ввода мл.
class FoodCountLeadingZerosFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    final cleanedText = text.replaceFirst(RegExp(r'^0+'), '');
    final finalText = cleanedText.isEmpty ? '' : cleanedText;

    return TextEditingValue(
      text: finalText,
      selection: TextSelection.collapsed(offset: finalText.length),
    );
  }
}

final foodCountInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.digitsOnly,
  FoodCountLeadingZerosFormatter(),
  LengthLimitingTextInputFormatter(4),
];

class _FoodCountEditorController extends EditController {
  /// [fec] — единый источник записи; нельзя сохранять [Feed] на момент открытия диалога.
  _FoodCountEditorController({required EditFeedController fec}) : _fec = fec {
    initState(fds: [MTFieldData(0, text: fec.feed.count?.toString() ?? '')]);
  }

  final EditFeedController _fec;
  Timer? _debounceTimer;

  // Обновляет количество с задержкой (debounce)
  void updateCount(String value) {
    if (_debounceTimer != null) _debounceTimer!.cancel();
    _debounceTimer = Timer(TEXT_SAVE_DELAY_DURATION, () => _saveCount(value));
  }

  void _saveCount(String value) {
    final countText = value.trim();
    final count = countText.isEmpty ? 0 : (int.tryParse(countText) ?? 0);
    _fec.setCount(clampFoodCount(count));
  }

  void incrementCount() {
    final currentCount = currentCountFromField;
    if (currentCount < foodCountMax) _updateCount(clampFoodCount(nextFoodCount(currentCount, increment: true)));
  }

  void decrementCount() {
    final currentCount = currentCountFromField;
    if (currentCount > 0) _updateCount(clampFoodCount(nextFoodCount(currentCount, increment: false)));
  }

  int get currentCountFromField {
    final text = teController(0)?.text.trim() ?? '';
    if (text.isEmpty) {
      return 0;
    } else {
      return clampFoodCount(int.tryParse(text) ?? 0);
    }
  }

  // Обновляет количество кормления и синхронизирует с полем ввода
  void _updateCount(int newCount) {
    _fec.setCount(newCount);
    if (newCount == 0) {
      teController(0)?.text = '';
    } else {
      teController(0)?.text = newCount.toString();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

class FoodCountEditor extends StatefulWidget {
  const FoodCountEditor(this._fec, {super.key});
  final EditFeedController _fec;

  @override
  State<FoodCountEditor> createState() => _FoodCountEditorState();
}

class _FoodCountEditorState extends State<FoodCountEditor> {
  late _FoodCountEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _FoodCountEditorController(fec: widget._fec);
    _controller.teController(0)?.addListener(_onTextChanged);
  }

  // Обработчик изменения текста в поле ввода. Обновляет состояние виджета для перерисовки кнопок
  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _controller.teController(0)?.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  Widget _buildButton(String icon, VoidCallback? onTap) =>
      MTButton(type: MTButtonType.main, color: b3Color, middle: MTSvgIcon(icon, size: 30), minSize: const Size.square(60), uf: false, onTap: onTap);

  Widget _buildTextField(BuildContext context) {
    final showMlLabel = _controller.currentCountFromField > 0;

    return Expanded(
      child: MTCard(
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
                style: const H1('', color: f1Color).style(context),
                hint: loc.food_count_hint,
                hintStyle: const SmallText('', color: f3Color).style(context),
                margin: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                inputFormatters: foodCountInputFormatters,
                onChanged: _controller.updateCount,
              ),
              Visibility(
                visible: showMlLabel,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: SmallText(loc.milliliters, align: TextAlign.center, color: f2Color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCount = _controller.currentCountFromField;

    // Та же колонка, что у MTButton.main: min(SCR_XXS_WIDTH, ширина экрана).
    return MTAdaptive.xxs(
      child: Row(
        children: [
          _buildButton('minus', currentCount > 0 ? _controller.decrementCount : null),
          const SizedBox(width: P2),
          _buildTextField(context),
          const SizedBox(width: P2),
          _buildButton('plus', currentCount < foodCountMax ? _controller.incrementCount : null),
        ],
      ),
    );
  }
}
