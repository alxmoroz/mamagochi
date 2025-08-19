import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '/../L3_app/presenters/baby.dart';
import '../../L1_domain/entities/baby.dart';
import '../../L1_domain/entities/feed.dart';
import '../components/images.dart';
import '../views/app/services.dart';

Baby get _baby => mainController.selectedBabyController!.baby;

extension FeedPresenter on Feed {
  String get addFeedTitle => Intl.message('action_add_feed_title_${_baby.sex}');

  String get editFeedTitle => type.isBreast == true
      ? loc.edit_feed_breast_title
      : type.isBabyFormula
          ? loc.edit_feed_baby_formula_title
          : loc.edit_feed_milk_bottle_title;

  String get editFeedDateTimeTitle => Intl.message('edit_feed_date_title_${_baby.sex}');

  Widget feedImage({double? size}) => MTImage(
        type.isBreast == true
            ? 'breast'
            : type.isMilkBottle == true
                ? 'bottle_milk'
                : 'bottle_baby_formula',
        height: size,
        width: size,
      );

  String get feedTypeName => type.isRightBreast == true
      ? loc.feed_type_right_breast
      : type.isLeftBreast == true
          ? loc.feed_type_left_breast
          : type.isBabyFormula == true
              ? loc.feed_type_baby_formula
              : loc.feed_type_milk;

  String get feedName => 'Кормление $type, $endDate, $count';
}
