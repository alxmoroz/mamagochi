import 'package:mamagochi/L1_domain/entities/base_entity.dart';

abstract class AbstractEntry extends LocalPersistable {
  const AbstractEntry({this.start, required this.end});
  final DateTime? start;
  final DateTime end;
}
