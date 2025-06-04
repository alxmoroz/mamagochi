import 'package:flutter/cupertino.dart';
import 'package:mamagochi/L1_domain/entities/baby.dart';

import '../components/images.dart';

extension BabyPresenter on Baby? {
  String get sex => this?.isBoy == true ? 'boy' : 'girl';

  Widget image({double? size}) => MTImage(
        sex,
        height: size,
        width: size,
      );

  Widget imageSleep({double? size}) => MTImage(
        '${sex}_sleep',
        height: size,
        width: size,
      );
}
