// Copyright (c) 2022. Alexandr Moroz

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import '../../components/field_data.dart';

part 'edit_controller.g.dart';

abstract class EditController extends _EditControllerBase with _$EditController {}

abstract class _EditControllerBase with Store {
  @observable
  ObservableMap<int, MTFieldData> _fdMap = ObservableMap();

  @observable
  Map<int, TextEditingController> _teControllers = {};
  TextEditingController? teController(int code) => _teControllers[code];

  @observable
  Map<int, FocusNode> _focusNodes = {};
  FocusNode? focusNode(int code) => _focusNodes[code];

  TextEditingController _makeTEController(int code) {
    final fd = fData(code);
    final teController = TextEditingController(text: '$fd');
    teController.addListener(() => _updateData(code, teController));
    return teController;
  }

  FocusNode _makeFocusNode(int code) => FocusNode()..addListener(() => updateField(code));

  @mustCallSuper
  @action
  void initState({List<MTFieldData>? fds}) {
    _fdMap = ObservableMap.of({for (var fd in fds ?? <MTFieldData>[]) fd.code: fd});
    _teControllers = {for (var fd in _fdMap.values) fd.code: _makeTEController(fd.code)};
    _focusNodes = {for (var fd in _fdMap.values) fd.code: _makeFocusNode(fd.code)};
  }

  @mustCallSuper
  @action
  void dispose() {
    _loadingTimers.forEach((_, lt) => lt.cancel());
    _loadingTimers.clear();

    _teControllers.forEach((_, tec) => tec.dispose());
    _teControllers.clear();

    _focusNodes.forEach((_, node) => node.dispose());
    _focusNodes.clear();

    _fdMap.clear();
  }

  @action
  void _updateData(int code, TextEditingController te) {
    final fd = fData(code);
    final skip = !fd.edited && (fd.text.isEmpty && te.text.isEmpty);
    if (!skip) {
      _fdMap[code] = fd.copyWith(text: te.text);
    }
  }

  @computed
  Iterable<MTFieldData> get _fds => _fdMap.values;

  @computed
  Iterable<MTFieldData> get _validatableFD => _fds.where((fd) => fd.validate);

  @computed
  bool get _fieldsFilled => _validatableFD.every((fd) => fd.text.isNotEmpty);

  @computed
  bool get validated => _fieldsFilled && !_validatableFD.any((fd) => fd.errorText != null);

  MTFieldData fData(int code) {
    try {
      return _fdMap[code]!;
    } catch (e) {
      if (kDebugMode) print('ERROR\n_fdMap = $_fdMap\ncode = $code\n');
      return MTFieldData(code);
    }
  }

  final Map<int, Timer> _loadingTimers = {};

  @action
  void _setLoading(int code, bool loading) {
    if (_fdMap.isNotEmpty) {
      _fdMap[code] = _fdMap[code]!.copyWith(loading: loading);
    }
  }

  @action
  void updateField(int code, {String? text, bool? loading}) {
    final fd = _fdMap[code];
    if (fd != null) {
      _fdMap[code] = fd.copyWith(text: text);

      if (loading != null) {
        if (_loadingTimers[code] != null) {
          _loadingTimers[code]!.cancel();
        }
        _loadingTimers[code] = Timer(Duration(milliseconds: loading ? 750 : 0), () => _setLoading(code, loading));
      }
    }
  }
}
