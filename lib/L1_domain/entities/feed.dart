import 'package:collection/collection.dart';

import 'abstract_entry.dart';

enum FeedingType {
  right_breast,
  left_breast,
  milk_bottle,
  baby_formula_bottle;

  bool get isRightBreast => this == right_breast;
  bool get isLeftBreast => this == left_breast;
  bool get isBreast => isRightBreast || isLeftBreast;
  bool get isBabyFormula => this == baby_formula_bottle;
  bool get isMilkBottle => this == milk_bottle;
  bool get isBottle => isBabyFormula || isMilkBottle;

  static FeedingType fromString(String? name) => values.firstWhereOrNull((v) => v.name.toLowerCase() == name?.toLowerCase()) ?? right_breast;
}

class Feed extends AbstractEntry {
  Feed({required super.created, super.startDate, super.endDate, required super.babyCreatedTime, required this.type, this.count});
  final FeedingType type;
  int? count;

  @override
  Feed copyWith({DateTime? startDate, DateTime? endDate, FeedingType? type, int? count}) => Feed(
        created: created,
        babyCreatedTime: babyCreatedTime,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        type: type ?? this.type,
        count: count ?? this.count,
      );
}
