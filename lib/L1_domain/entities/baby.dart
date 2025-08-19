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

  bool get defined => named && hasDateOfBirth;
  bool get named => name?.isNotEmpty == true;
  bool get hasDateOfBirth => dateOfBirth != null;
  bool get wasBorn => hasDateOfBirth && daysSinceBirth! > 0;
}
