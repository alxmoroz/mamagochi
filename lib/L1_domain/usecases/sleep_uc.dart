// Copyright (c) 2022. Alexandr Moroz

import '../entities/sleep.dart';
import '../repositories/abs_db_repo.dart';

class SleepUC {
  SleepUC(this.repo);

  final AbstractLocalStorageRepo<AbstractDBModel, Sleep> repo;

  Future<Iterable<Sleep>> entries() async => await repo.getAll();

  Future addEntry(Sleep entry) async {
    await repo.update((_) => false, entry);
  }
}
