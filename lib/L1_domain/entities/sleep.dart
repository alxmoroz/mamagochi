import 'abstract_entry.dart';

class Sleep extends AbstractEntry {
  Sleep({required super.created, super.startDate, super.endDate, required super.babyCreatedTime});

  bool get isStillSleeping => endDate == null;

  @override
  Sleep copyWith({DateTime? startDate, DateTime? endDate}) => Sleep(
        created: created,
        babyCreatedTime: babyCreatedTime,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
      );
}
