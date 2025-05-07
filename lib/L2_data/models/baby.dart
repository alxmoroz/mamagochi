// Copyright (c) 2025. Xenia Moroz

import 'package:hive/hive.dart';

import '../../L1_domain/entities/baby.dart';
import '../services/db.dart';
import 'base.dart';

part 'baby.g.dart';

@HiveType(typeId: HType.BABY)
class BabyHO extends BaseModel<Baby> {
  @HiveField(0, defaultValue: true)
  bool isBoy = true;

  @HiveField(1)
  String? name;

  @HiveField(2)
  DateTime? dateOfBirth;

  @override
  Baby toEntity() => Baby(
        isBoy: isBoy,
        name: name,
        dateOfBirth: dateOfBirth,
      );

  @override
  Future<BabyHO> update(Baby entity) async {
    isBoy = entity.isBoy;
    name = entity.name;
    dateOfBirth = entity.dateOfBirth;
    await save();
    return this;
  }
}
