import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '/../L1_domain/entities/baby.dart';
import '../components/images.dart';
import '../views/app/services.dart';
import '../views/baby_face/baby_face_config.dart';
import '../views/baby_face/baby_face_mode.dart';
import '../views/baby_face/baby_face_widget.dart';
import '../views/history/history_controller.dart';

extension BabyPresenter on Baby? {
  String get sex => this?.isBoy == true ? 'boy' : 'girl';

  Widget face({double? size, BabyFaceMode mode = BabyFaceMode.awake, bool enableBlink = true}) {
    final baby = this;
    if (baby == null) return MTSvgImage('no_info', height: size, width: size);
    return BabyFaceWidget(config: BabyFaceConfig.forBaby(baby, mode), size: size, enableBlink: enableBlink);
  }

  Widget faceSleep({double? size}) => face(size: size, mode: BabyFaceMode.sleep);

  Widget faceBreastFeed(bool isLeftBreast, {double? size}) =>
      face(size: size, mode: isLeftBreast ? BabyFaceMode.feedingLeft : BabyFaceMode.feedingRight);

  Widget faceForHistory(HistoryController hc, {double? size}) {
    final baby = this;
    if (baby == null) return MTSvgImage('no_info', height: size, width: size);

    final mode = hc.babyIsSleeping
        ? BabyFaceMode.sleep
        : hc.babyIsEating
        ? (hc.lastOngoingBreastFeed!.type.isLeftBreast ? BabyFaceMode.feedingLeft : BabyFaceMode.feedingRight)
        : BabyFaceMode.awake;

    return BabyFaceWidget(config: BabyFaceConfig.forBaby(baby, mode), size: size, enableBlink: true);
  }

  String? get formattedDateOfBirth => this?.dateOfBirth != null ? DateFormat.yMMMMd().format(this!.dateOfBirth!) : null;
}

extension BabyAgePresenter on BabyAge {
  bool get _isNotBornYet => daysUntilBirth != null;
  bool get _isBirthdayToday => years == 0 && months == 0 && days == 0 && !_isNotBornYet;

  String format() {
    /// Если ещё не родился
    if (_isNotBornYet) {
      return loc.baby_profile_awaiting_birth(loc.days_count(daysUntilBirth!));
    }

    /// Если день рождения сегодня
    if (_isBirthdayToday) {
      return loc.baby_profile_birthday_today;
    }

    /// Обычный возраст
    final parts = <String>[];
    if (years > 0) parts.add(loc.years_count(years));
    if (months > 0) parts.add(loc.months_count(months));
    if (days > 0) parts.add(loc.days_count(days));

    return parts.join(', ');
  }
}
