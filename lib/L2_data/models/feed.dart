// Copyright (c) 2022. Alexandr Moroz

import 'package:hive/hive.dart';

import '../../L1_domain/entities/feed.dart';
import '../services/db.dart';
import 'base.dart';

part 'feed.g.dart';

@HiveType(typeId: HType.FEED)
class FeedHO extends BaseModel<Feed> {
  @HiveField(0)
  DateTime? start;

  @HiveField(1)
  DateTime end = DateTime.now();

  @override
  Feed toEntity() => Feed(
        start: start,
        end: end,
      );

  @override
  Future<FeedHO> update(Feed entity) async {
    start = entity.start;
    end = entity.end;
    await save();
    return this;
  }
}
