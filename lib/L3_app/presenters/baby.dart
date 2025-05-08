import 'package:flutter/cupertino.dart';
import 'package:mamagochi/L1_domain/entities/baby.dart';

import '../components/images.dart';

extension BabyPresenter on Baby? {
  Widget image({double? size}) => MTImage(
        this?.isBoy == true ? 'baby' : 'baby_girl',
        height: size,
        width: size,
      );
}
