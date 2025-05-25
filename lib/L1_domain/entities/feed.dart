import 'abstract_entry.dart';

class Feed extends AbstractEntry {
  Feed({required super.created, super.startDate, super.endDate, required super.babyCreatedTime});

  @override
  String toString() => 'Кормление $endDate';

  @override
  Feed copyWith({DateTime? startDate, DateTime? endDate}) => Feed(
        created: created,
        babyCreatedTime: babyCreatedTime,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
      );
}
