import 'package:flutter/cupertino.dart';

import '/../L1_domain/entities/baby.dart';
import '../components/images.dart';
import '../views/app/services.dart';

extension BabyPresenter on Baby? {
  String get sex => this?.isBoy == true ? 'boy' : 'girl';

  Widget image({double? size}) => MTImage(
        this?.isOlderNineMonths == true ? '${sex}_with_teeth' : sex,
        height: size,
        width: size,
      );

  Widget imageSleep({double? size}) => MTImage(
        '${sex}_sleep',
        height: size,
        width: size,
      );
}

extension BabyAgePresenter on BabyAge {
  bool get _isNotBornYet => daysUntilBirth != null;
  bool get _isBirthdayToday => years == 0 && months == 0 && days == 0 && !_isNotBornYet;

  String format() {
    // Если ещё не родился
    if (_isNotBornYet) {
      return loc.baby_profile_awaiting_birth(loc.days_count(daysUntilBirth!));
    }

    // Если день рождения сегодня
    if (_isBirthdayToday) {
      return loc.baby_profile_birthday_today;
    }

    // Обычный возраст
    final parts = <String>[];
    if (years > 0) parts.add(loc.years_count(years));
    if (months > 0) parts.add(loc.months_count(months));
    if (days > 0) parts.add(loc.days_count(days));

    return parts.join(', ');
  }
}
