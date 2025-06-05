import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mamagochi/L3_app/components/card.dart';
import 'package:mamagochi/L3_app/components/constants.dart';
import 'package:mamagochi/L3_app/components/datetime_picker.dart';
import 'package:mamagochi/L3_app/components/dialog.dart';
import 'package:mamagochi/L3_app/components/images.dart';
import 'package:mamagochi/L3_app/components/list_tile.dart';
import 'package:mamagochi/L3_app/components/text.dart';
import 'package:mamagochi/L3_app/components/toolbar.dart';
import 'package:mamagochi/L3_app/presenters/baby.dart';
import 'package:mamagochi/L3_app/presenters/date.dart';
import 'package:mamagochi/L3_app/presenters/duration.dart';
import 'package:mamagochi/L3_app/views/_base/loader_screen.dart';
import 'package:mobx/mobx.dart';

import '../../../L1_domain/entities/baby.dart';
import '../../../L1_domain/entities/sleep.dart';
import '../app/services.dart';
import 'history_controller.dart';

part 'edit_sleep_dialog.g.dart';

class _EditSleepController extends _Base with _$_EditSleepController {
  _EditSleepController(Sleep sleepIn) {
    sleep = sleepIn;
  }
}

abstract class _Base with Store {
  @observable
  late Sleep sleep;

  @action
  void setStart(DateTime value) => sleep = sleep.copyWith(startDate: value);

  @action
  void setEnd(DateTime value) => sleep = sleep.copyWith(endDate: value);
}

class EditSleepDialog extends StatelessWidget {
  const EditSleepDialog._(this._sc);
  final _EditSleepController _sc;

  static Future show(Sleep sleep) async => await showMTDialog(EditSleepDialog._(_EditSleepController(sleep)));

  HistoryController get _hc => mainController.selectedBabyController!.historyController;
  Baby get _baby => mainController.selectedBabyController!.baby;

  Future _editStart() async {
    final start = await MTDateTimePicker.show(Intl.message('edit_sleep_start_date_title_${_baby.sex}'), initialDate: _sc.sleep.start);
    if (start != null) {
      await _hc.editSleep(_sc.sleep, startDate: start);
      _sc.setStart(start);
    }
  }

  Future _editEnd() async {
    final end = await MTDateTimePicker.show(Intl.message('edit_sleep_end_date_title_${_baby.sex}'), initialDate: _sc.sleep.end);
    if (end != null) {
      await _hc.editSleep(_sc.sleep, endDate: end);
      _sc.setEnd(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return _hc.loading
          ? LoaderScreen(_hc)
          : MTDialog(
              topBar: MTTopBar(middle: H1(Intl.message('how_much_slept_${_baby.sex}', args: [_sc.sleep.duration.strInHoursAndMinutes]))),
              body: ListView(
                shrinkWrap: true,
                children: [
                  MTCard(
                    margin: const EdgeInsets.symmetric(vertical: P, horizontal: P3),
                    radius: 40,
                    elevation: 0,
                    child: MTListTile(
                      leading: const MTImage('eye_closed', height: 60),
                      middle: BaseText(Intl.message('action_start_sleep_title_${_baby.sex}')),
                      subtitle: H2('${_sc.sleep.start.strMedium}, ${_sc.sleep.start.strTime}'),
                      bottomDivider: false,
                      onTap: _editStart,
                    ),
                  ),
                  MTCard(
                    margin: const EdgeInsets.symmetric(vertical: P, horizontal: P3),
                    radius: 40,
                    elevation: 0,
                    child: MTListTile(
                      leading: const MTImage('eye', height: 60),
                      middle: BaseText(Intl.message('action_stop_sleep_title_${_baby.sex}')),
                      subtitle: H2('${_sc.sleep.end.strMedium}, ${_sc.sleep.end.strTime}'),
                      bottomDivider: false,
                      onTap: _editEnd,
                    ),
                  ),
                ],
              ),
              forceBottomPadding: true,
            );
    });
  }
}
