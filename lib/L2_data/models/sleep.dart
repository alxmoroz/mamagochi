// Copyright (c) 2025. Xenia Moroz

import 'package:hive/hive.dart';
import 'package:mamagochi/L1_domain/entities/sleep.dart';

import '../services/db.dart';
import 'base.dart';

part 'sleep.g.dart';

@HiveType(typeId: HType.SLEEP)
class SleepHO extends BaseModel<Sleep> {
  @HiveField(0)
  DateTime created = DateTime.now();

  @HiveField(1)
  DateTime? start;

  @HiveField(2)
  DateTime? end;

  @override
  Sleep toEntity() => Sleep(
        created: created,
        startDate: start,
        endDate: end,
      );

  @override
  Future<SleepHO> update(Sleep entity) async {
    start = entity.startDate;
    end = entity.endDate;
    await save();
    return this;
  }
}
