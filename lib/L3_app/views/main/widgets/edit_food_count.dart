import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

import '../../../../L1_domain/entities/feed.dart';
import '../../../components/adaptive.dart';
import '../../../components/dialog.dart';
import '../../../components/field_data.dart';
import '../../../components/text.dart';
import '../../../components/text_field.dart';
import '../../../components/toolbar.dart';
import '../../_base/edit_controller.dart';
import '../../_base/loader_screen.dart';
import '../../app/services.dart';
import '../../history/history_controller.dart';

part 'edit_food_count.g.dart';

class _EditFoodCountController extends _Base with _$_EditFoodCountController {
  late final _ConcreteEditController _editController;

  _EditFoodCountController(Feed feedIn) {
    feed = feedIn;
    _editController = _ConcreteEditController();
    _editController.initState(fds: [MTFieldData(0, text: feedIn.count?.toString() ?? '')]);
  }

  TextEditingController? teController(int code) => _editController.teController(code);
  MTFieldData fData(int code) => _editController.fData(code);
  bool get validated => _editController.validated;

  void dispose() => _editController.dispose();
}

class _ConcreteEditController extends EditController {}

abstract class _Base with Store {
  @observable
  late Feed feed;

  @action
  void setCount(int? value) => feed = feed.copyWith(count: value);
}

class EditFoodCount extends StatelessWidget {
  const EditFoodCount._(this._fc);
  final _EditFoodCountController _fc;

  static Future show(Feed feed) async => await showMTDialog(EditFoodCount._(_EditFoodCountController(feed)));

  HistoryController get _hc => mainController.selectedBabyController!.historyController;

  Future _editFoodCount() async {
    final countText = _fc.fData(0).text;
    int? count;
    if (countText.isNotEmpty) {
      count = int.tryParse(countText);
    }
    await _hc.editFeed(_fc.feed.copyWith(count: count));
    _fc.setCount(count);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return _hc.loading
          ? LoaderScreen(_hc)
          : MTDialog(
              topBar: const MTTopBar(middle: H1('Редактирование количества еды')),
              body: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    MTAdaptive.s(
                      child: MTTextField(
                        controller: _fc.teController(0),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        label: 'Количество мл',
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        onSubmitted: (_) => _fc.validated ? _editFoodCount() : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
    });
  }
}
