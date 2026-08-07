import 'package:jiffy/jiffy.dart';

import '../../L3_app/views/app/services.dart';
import '../utils/dates.dart';
import 'base_entity.dart';

class Baby extends LocalPersistable {
  Baby({required this.created, this.isBoy = true, this.name, this.dateOfBirth});
  final DateTime created;
  bool isBoy;
  String? name;
  DateTime? dateOfBirth;

  @override
  String toString() => '$created $boyOrGirlStr $name $dateOfBirth';

  String get boyOrGirlStr => isBoy == true ? loc.sex_man : loc.sex_woman;
  int? get daysSinceBirth => now.difference(dateOfBirth ?? now).inDays;

  bool get isOlderNineMonths => hasDateOfBirth && Jiffy.parseFromDateTime(dateOfBirth!).add(months: 9).isBefore(Jiffy.now());

  bool get isMonthlyAnniversaryToday {
    final age = fullAge;
    return age != null && age.daysUntilBirth == null && age.days == 0;
  }

  bool get defined => named && hasDateOfBirth;
  bool get named => name?.isNotEmpty == true;
  bool get hasDateOfBirth => dateOfBirth != null;
  bool get wasBorn => hasDateOfBirth && daysSinceBirth! > 0;

  int? get ageInWeeks => hasDateOfBirth ? (daysSinceBirth! / 7).floor() : null;

  BabyAge? get fullAge {
    if (!hasDateOfBirth) return null;

    // Если ещё не родился
    if (dateOfBirth!.isAfter(now)) {
      final daysUntilBirth = dateOfBirth!.difference(now).inDays;
      return BabyAge(years: 0, months: 0, days: 0, daysUntilBirth: daysUntilBirth);
    }

    // Если уже родился
    final nowJiffy = Jiffy.now();
    final birthJiffy = Jiffy.parseFromDateTime(dateOfBirth!);

    final years = nowJiffy.diff(birthJiffy, unit: Unit.year).floor();
    final months = nowJiffy.diff(birthJiffy.add(years: years), unit: Unit.month).floor();
    final days = nowJiffy
        .diff(
          birthJiffy.add(years: years, months: months),
          unit: Unit.day,
        )
        .floor();

    return BabyAge(years: years, months: months, days: days);
  }
}

class BabyAge {
  final int years;
  final int months;
  final int days;
  final int? daysUntilBirth;

  BabyAge({required this.years, required this.months, required this.days, this.daysUntilBirth});
}
