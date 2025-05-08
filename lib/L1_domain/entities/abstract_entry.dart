import '../utils/dates.dart';
import 'base_entity.dart';

abstract class AbstractEntry extends LocalPersistable {
  const AbstractEntry({required this.created, this.startDate, this.endDate});
  final DateTime created;
  final DateTime? startDate;
  final DateTime? endDate;

  DateTime get end => endDate ?? created;
  DateTime get start => startDate ?? created;

  bool get endIsToday => end.date == today;
}
