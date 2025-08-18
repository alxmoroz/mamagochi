import 'abstract_entry.dart';

class Sleep extends AbstractEntry {
  Sleep({required super.created, super.startDate, super.endDate, required super.babyCreatedTime});

  // TODO: Это лучше в презентер перенести
  @override
  String toString() => 'Сон $startDate - $endDate';

  @override
  Sleep copyWith({DateTime? startDate, DateTime? endDate}) => Sleep(
        created: created,
        babyCreatedTime: babyCreatedTime,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
      );
}
