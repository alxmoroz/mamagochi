// Copyright (c) 2025. Xenia Moroz

import 'package:hive/hive.dart';

import '../../L1_domain/entities/feed.dart';
import '../services/db.dart';
import 'base.dart';

part 'feed.g.dart';

@HiveType(typeId: HType.FEED)
class FeedHO extends BaseModel<Feed> {
  @HiveField(0)
  DateTime created = DateTime.now();

  @HiveField(1)
  DateTime? start;

  @HiveField(2)
  DateTime? end;

  @override
  Feed toEntity() => Feed(
        created: created,
        startDate: start,
        endDate: end,
      );

  @override
  Future<FeedHO> update(Feed entity) async {
    start = entity.startDate;
    end = entity.endDate;
    await save();
    return this;
  }
}
