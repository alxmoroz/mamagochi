// Copyright (c) 2022. Alexandr Moroz

import '../entities/baby.dart';
import '../repositories/abs_db_repo.dart';

class BabyUC {
  BabyUC(this.repo);

  final AbstractLocalStorageRepo<AbstractDBModel, Baby> repo;

  Future<Iterable<Baby>> babies() async => await repo.getAll();

  Future editBaby(Baby baby) async {
    await repo.update(
      (saved) => saved.created.isAtSameMomentAs(baby.created),
      baby,
    );
  }
}
