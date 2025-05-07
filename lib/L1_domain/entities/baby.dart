import 'base_entity.dart';

class Baby extends LocalPersistable {
  Baby({required this.isBoy, this.name, this.dateOfBirth});
  final bool isBoy;
  String? name;
  DateTime? dateOfBirth;
  @override
  String toString() => '${isBoy ? 'Мальчик' : 'Девочка'} $name $dateOfBirth';

  bool get defined => named && hasDateOfBirth;
  bool get named => name?.isNotEmpty == true;
  bool get hasDateOfBirth => dateOfBirth != null;

  Baby copyWith({bool? isBoy, String? name, DateTime? dateOfBirth}) => Baby(
        isBoy: isBoy ?? this.isBoy,
        name: name ?? this.name,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      );
}
