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

  bool get defined => named && hasDateOfBirth;
  bool get named => name?.isNotEmpty == true;
  bool get hasDateOfBirth => dateOfBirth != null;
}
