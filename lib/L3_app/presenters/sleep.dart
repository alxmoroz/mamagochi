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

  String get historyStillSleepTimeTitle => isMoreMinute ? '$startTitle\n$stillSleepTitle' : stillSleepTitle;
  String get howMuchSleptTitle => Intl.message('how_much_slept_${_baby.sex}', args: [duration.strInHoursAndMinutes]);

  Widget sleepImage({double? size}) => MTSvgImage('bed', height: size, width: size);

  String get sleepName => '${loc.history_sleep_title} $startDate - $endDate';
  String get sleepDuration => isStillSleeping ? durationFromStartToNow.strInHoursAndMinutes : duration.strInHoursAndMinutes;
  String get sleepDurationTitle => isMoreMinute ? sleepDuration : '';

  // /// Подзаголовок сна в истории: длительность, и при наличии — число кормлений внутри сна.
  // String historySleepSubtitle(int feedsDuringSleepCount) {
  //   if (!isMoreMinute) return '';
  //   if (feedsDuringSleepCount <= 0) return sleepDuration;
  //   return '$sleepDuration • ${loc.feeds_count(feedsDuringSleepCount)}';
  // }

  String get startSleepActionTitle => Intl.message('action_start_sleep_title_${_baby.sex}');
  String get stopSleepActionTitle => Intl.message('action_stop_sleep_title_${_baby.sex}');
  String get ateAndFellAsleepTitle => Intl.message('action_ate_and_fell_asleep_title_${_baby.sex}');

  String get sleepJustNowTitle => Intl.message('sleep_just_now_title_${_baby.sex}');
  String get stillSleepTitle => Intl.message('history_sleep_trailing_still_sleep');
}
