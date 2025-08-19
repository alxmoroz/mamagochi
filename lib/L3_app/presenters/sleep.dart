import 'package:flutter/cupertino.dart';

import '../../L1_domain/entities/sleep.dart';
import '../components/images.dart';

extension SleepPresenter on Sleep {
  Widget sleepImage({double? size}) => MTImage(
        'bed',
        height: size,
        width: size,
      );

  String get sleepName => 'Сон $startDate - $endDate';
}
