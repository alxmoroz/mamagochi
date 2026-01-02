// Copyright (c) 2025. Xenia Moroz

import 'package:hive/hive.dart';

import '../../L1_domain/entities/baby.dart';
import '../../L1_domain/utils/dates.dart';
import '../services/db.dart';
import 'base.dart';

part 'baby.g.dart';

@HiveType(typeId: HType.BABY)
class BabyHO extends BaseModel<Baby> {
  @HiveField(0)
  DateTime? created;

  @HiveField(1, defaultValue: true)
  bool isBoy = true;

  @HiveField(2)
  String? name;

  @HiveField(3)
  DateTime? dateOfBirth;

  @override
  Baby toEntity() => Baby(created: created ?? now, isBoy: isBoy, name: name, dateOfBirth: dateOfBirth);

  @override
  Future<BabyHO> update(Baby entity) async {
    created = entity.created;
    isBoy = entity.isBoy;
    name = entity.name;
    dateOfBirth = entity.dateOfBirth;
    await save();
    return this;
  }
}
