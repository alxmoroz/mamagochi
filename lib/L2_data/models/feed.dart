// Copyright (c) 2025. Xenia Moroz

import 'package:hive/hive.dart';

import '../../L1_domain/entities/feed.dart';
import '../../L1_domain/utils/dates.dart';
import '../services/db.dart';
import 'base.dart';

part 'feed.g.dart';

@HiveType(typeId: HType.FEED)
class FeedHO extends BaseModel<Feed> {
  @HiveField(0)
  DateTime? created;

  @HiveField(1)
  DateTime? start;

  @HiveField(2)
  DateTime? end;

  @HiveField(3)
  DateTime? babyCreatedTime;

  @HiveField(4)
  String? type;

  @HiveField(5)
  int? count;

  @override
  Feed toEntity() => Feed(
        created: created ?? now,
        startDate: start,
        endDate: end,
        babyCreatedTime: babyCreatedTime ?? now,
        type: FeedingType.fromString(type),
        count: count,
      );

  @override
  Future<FeedHO> update(Feed entity) async {
    created = entity.created;
    start = entity.startDate;
    end = entity.endDate;
    babyCreatedTime = entity.babyCreatedTime;
    type = entity.type.name;
    count = entity.count;
    await save();
    return this;
  }
}
