import '../utils/dates.dart';
import 'base_entity.dart';

abstract class AbstractEntry extends LocalPersistable {
  AbstractEntry({required this.created, this.startDate, this.endDate, required this.babyCreatedTime});
  final DateTime created;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime babyCreatedTime;

  DateTime get end => endDate ?? created;
  DateTime get start => startDate ?? created;

  bool get endIsToday => end.date == today;

  Duration get duration => end.difference(start);

  AbstractEntry copyWith({DateTime? startDate, DateTime? endDate});
}
