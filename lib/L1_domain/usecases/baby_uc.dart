// Copyright (c) 2022. Alexandr Moroz

import '../entities/baby.dart';
import '../repositories/abs_db_repo.dart';

class BabyUC {
  BabyUC(this.repo);

  final AbstractLocalStorageRepo<AbstractDBModel, Baby> repo;

  Future<Iterable<Baby>> babies() async => await repo.getAll();

  Future editBaby(Baby notEditedBaby, Baby baby) async {
    await repo.update(
      (saved) => saved.isBoy == notEditedBaby.isBoy && saved.name == notEditedBaby.name && saved.dateOfBirth == notEditedBaby.dateOfBirth,
      baby,
    );
  }
}
