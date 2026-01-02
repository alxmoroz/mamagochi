// Copyright (c) 2025. Xenia Moroz

import 'package:hive/hive.dart';

import '../../L1_domain/entities/sleep.dart';
import '../../L1_domain/utils/dates.dart';
import '../services/db.dart';
import 'base.dart';

part 'sleep.g.dart';

@HiveType(typeId: HType.SLEEP)
class SleepHO extends BaseModel<Sleep> {
  @HiveField(0)
  DateTime? created;

  @HiveField(1)
  DateTime? start;

  @HiveField(2)
  DateTime? end;

  @HiveField(3)
  DateTime? babyCreatedTime;

  @override
  Sleep toEntity() => Sleep(created: created ?? now, startDate: start, endDate: end, babyCreatedTime: babyCreatedTime ?? now);

  @override
  Future<SleepHO> update(Sleep entity) async {
    created = entity.created;
    start = entity.startDate;
    end = entity.endDate;
    babyCreatedTime = entity.babyCreatedTime;
    await save();
    return this;
  }
}
