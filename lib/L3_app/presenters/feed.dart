import 'package:flutter/cupertino.dart';

import '../../L1_domain/entities/feed.dart';
import '../components/images.dart';
import '../views/app/services.dart';

extension FeedPresenter on Feed {
  String get feedTypeName => type.isRightBreast == true
      ? loc.feed_type_right_breast
      : type.isLeftBreast == true
          ? loc.feed_type_left_breast
          : type.isBabyFormula == true
              ? loc.feed_type_baby_formula
              : loc.feed_type_milk;

  Widget feedImage({double? size}) => MTImage(
        type.isBreast == true
            ? 'breast'
            : type.isMilkBottle == true
                ? 'bottle_milk'
                : 'bottle_baby_formula',
        height: size,
        width: size,
      );
}
