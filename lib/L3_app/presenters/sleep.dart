import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '/../L3_app/presenters/baby.dart';
import '/../L3_app/presenters/duration.dart';
import '/../L3_app/presenters/entry.dart';
import '../../L1_domain/entities/baby.dart';
import '../../L1_domain/entities/sleep.dart';
import '../components/images.dart';
import '../views/app/services.dart';

Baby get _baby => mainController.selectedBabyController!.baby;

extension SleepPresenter on Sleep {
  String get editSleepStartTitle => Intl.message('edit_sleep_start_date_title_${_baby.sex}');
  String get editSleepEndTitle => Intl.message('edit_sleep_end_date_title_${_baby.sex}');
  String get howMuchSleptTitle => Intl.message('how_much_slept_${_baby.sex}', args: [duration.strInHoursAndMinutes]);

  String get sleepDuration => isMoreMinute ? duration.strInHoursAndMinutes : '';

  Widget sleepImage({double? size}) => MTImage(
        'bed',
        height: size,
        width: size,
      );

  String get sleepName => '${loc.history_sleep_title} $startDate - $endDate';

  String get startSleepActionTitle => Intl.message('action_start_sleep_title_${_baby.sex}');
  String get stopSleepActionTitle => Intl.message('action_stop_sleep_title_${_baby.sex}');
}
