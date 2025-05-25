// Copyright (c) 2022. Alexandr Moroz

import '../entities/baby.dart';
import '../entities/sleep.dart';
import '../repositories/abs_db_repo.dart';

class SleepUC {
  SleepUC(this.repo);

  final AbstractLocalStorageRepo<AbstractDBModel, Sleep> repo;

  Future<Iterable<Sleep>> entries(Baby baby) async => await repo.getAll((e) => e.babyCreatedTime.isAtSameMomentAs(baby.created));

  Future edit(Sleep sleep) async {
    await repo.update(
      (saved) => saved.created.isAtSameMomentAs(sleep.created),
      sleep,
    );
  }
}
