import '../../L3_app/views/app/services.dart';
import 'base_entity.dart';

class Baby extends LocalPersistable {
  Baby({required this.isBoy, this.name, this.dateOfBirth});
  final bool isBoy;
  String? name;
  DateTime? dateOfBirth;

  @override
  String toString() => '$boyOrGirlStr $name $dateOfBirth';

  String get boyOrGirlStr => isBoy ? loc.sex_man : loc.sex_woman;
  int? get daysSinceBirth => (babyController.firstBaby?.dateOfBirth?.difference(DateTime.now()))?.inDays;

  bool get defined => named && hasDateOfBirth;
  bool get named => name?.isNotEmpty == true;
  bool get hasDateOfBirth => dateOfBirth != null;

  Baby copyWith({bool? isBoy, String? name, DateTime? dateOfBirth}) => Baby(
        isBoy: isBoy ?? this.isBoy,
        name: name ?? this.name,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      );
}
