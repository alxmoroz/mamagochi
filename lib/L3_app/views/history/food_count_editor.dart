import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/button.dart';
import '../../components/card.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/field_data.dart';
import '../../components/icons.dart';
import '../../components/text.dart';
import '../../components/text_field.dart';
import '../_base/edit_controller.dart';
import 'edit_feed_controller.dart';

const int _countStep = 10;
const int _maxCount = 9999;

int _roundUpToTen(int value) => ((value + 9) ~/ 10) * 10;
int _roundDownToTen(int value) => (value ~/ 10) * 10;
int _clampCount(int value) => value.clamp(0, _maxCount);

// Удаление ведущих нулей из поля ввода
class _LeadingZerosFormatter extends TextInputFormatter {
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
    _fec.setCount(_clampCount(count));
  }

  void incrementCount() {
    final currentCount = currentCountFromField;
    if (currentCount < _maxCount) _updateCount(_clampCount(_calculateNewCount(currentCount, true)));
  }

  void decrementCount() {
    final currentCount = currentCountFromField;
    if (currentCount > 0) _updateCount(_clampCount(_calculateNewCount(currentCount, false)));
  }

  // Вычисляет новое значение с учетом умного округления
  int _calculateNewCount(int currentCount, bool isIncrement) {
    final rounded = isIncrement ? _roundUpToTen(currentCount) : _roundDownToTen(currentCount);
    if (currentCount == rounded) {
      return currentCount + (isIncrement ? _countStep : -_countStep);
    } else {
      return rounded;
    }
  }

  int get currentCountFromField {
    final text = teController(0)?.text.trim() ?? '';
    if (text.isEmpty) {
      return 0;
    } else {
      return _clampCount(int.tryParse(text) ?? 0);
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

  Widget _buildTextField(BuildContext context) => Expanded(
    child: MTCard(
      margin: const EdgeInsets.symmetric(vertical: P),
      radius: 40,
      elevation: 0,
      child: MTTextField(
        controller: _controller.teController(0),
        focusNode: _controller.focusNode(0),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const H1('', color: f1Color).style(context),
        margin: EdgeInsets.zero,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, _LeadingZerosFormatter(), LengthLimitingTextInputFormatter(4)],
        onChanged: _controller.updateCount,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final currentCount = _controller.currentCountFromField;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: P3),
      child: Row(
        children: [
          _buildButton('minus', currentCount > 0 ? _controller.decrementCount : null),
          const SizedBox(width: P2),
          _buildTextField(context),
          const SizedBox(width: P2),
          _buildButton('plus', currentCount < _maxCount ? _controller.incrementCount : null),
        ],
      ),
    );
  }
}
