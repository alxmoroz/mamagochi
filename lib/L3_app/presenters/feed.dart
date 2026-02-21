import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '/../L3_app/presenters/baby.dart';
import '/../L3_app/presenters/duration.dart';
import '../../L1_domain/entities/baby.dart';
import '../../L1_domain/entities/feed.dart';
import '../components/images.dart';
import '../views/app/services.dart';

Baby get _baby => mainController.selectedBabyController!.baby;

extension FeedPresenter on Feed {
  String get actionAddFeedTitle => Intl.message('action_add_feed_title_${_baby.sex}');
  String get addFeedTitle {
    final baseTitle = '$actionAddFeedTitle $whatToEatTitle';
    return type.isBottle && shouldShowCount ? '$baseTitle $feedCount' : baseTitle;
  }

  String get editFeedTitle {
    if (type.isBreast) {
      if (endDate == null || duration.inSeconds < 10) {
        return loc.edit_feed_breast_title;
      }
      final durationStr = duration.strInHoursMinutesAndSeconds;
      return _baby.isBoy ? loc.how_much_fed_boy(durationStr) : loc.how_much_fed_girl(durationStr);
    }
    return type.isBabyFormula
        ? loc.edit_feed_baby_formula_title
        : loc.edit_feed_milk_bottle_title;
  }

  /// Заголовок снэкбара при завершении кормления грудью: без длительности если < 10 с, иначе «Покушал/Покушала левую (правую) грудь {duration}».
  String get finishedBreastFeedSnackbarTitle {
    if (duration.inSeconds < 10) return addFeedTitle;
    final durationStr = duration.strInHoursMinutesAndSeconds;
    return _baby.isBoy
        ? loc.how_much_fed_past_with_type_boy(whatToEatTitle, durationStr)
        : loc.how_much_fed_past_with_type_girl(whatToEatTitle, durationStr);
  }

  String get editFeedDateTimeTitle => Intl.message('edit_feed_end_date_title_${_baby.sex}');
  String get editFeedStartDateTitle => Intl.message('edit_feed_start_date_title_${_baby.sex}');
  String get feedJustNowTitle => Intl.message('feed_just_now_title_${_baby.sex}');
  String get stopFeedActionTitle => Intl.message('action_stop_feed_title_${_baby.sex}');

  String get feedCount => shouldShowCount ? '$count\u00A0${loc.milliliters}' : '';

  Widget feedImage({double? size}) => MTImage(feedImageName, height: size, width: size);

  String get feedImageName => type.isRightBreast == true
      ? 'right_breast'
      : type.isLeftBreast == true
      ? 'left_breast'
      : type.isMilkBottle == true
      ? 'bottle_milk'
      : 'bottle_baby_formula';

  String get feedTypeName => type.isRightBreast == true
      ? loc.feed_type_right_breast
      : type.isLeftBreast == true
      ? loc.feed_type_left_breast
      : type.isBabyFormula == true
      ? loc.feed_type_baby_formula
      : loc.feed_type_milk;

  String get feedName => 'Кормление $type, $endDate, $count';

  /// Длительность кормления грудью для истории (с секундами). Как у сна — для завершённого или текущего кормления.
  String get historyBreastFeedDuration => type.isBreast
      ? (endDate == null ? durationFromStartToNow : duration).strInHoursMinutesAndSeconds
      : '';

  bool get shouldShowCount => count != null && count! > 0;
  String get whatToEatTitle => Intl.message('what_to_eat_${type.name}');
}
