// Copyright (c) 2022. Alexandr Moroz

import 'package:hive/hive.dart';
import 'package:mamagochi/L1_domain/entities/sleep.dart';

import '../services/db.dart';
import 'base.dart';

part 'sleep.g.dart';

@HiveType(typeId: HType.SLEEP)
class SleepHO extends BaseModel<Sleep> {
  @HiveField(0)
  DateTime? start;

  @HiveField(1)
  DateTime end = DateTime.now();

  @override
  Sleep toEntity() => Sleep(
        start: start,
        end: end,
      );

  @override
  Future<SleepHO> update(Sleep entity) async {
    start = entity.start;
    end = entity.end;
    await save();
    return this;
  }
}
