// Copyright (c) 2022. Alexandr Moroz

import '../entities/baby.dart';
import '../entities/feed.dart';
import '../repositories/abs_db_repo.dart';

class FeedUC {
  FeedUC(this.repo);

  final AbstractLocalStorageRepo<AbstractDBModel, Feed> repo;

  Future<Iterable<Feed>> entries(Baby baby) async => await repo.getAll((e) => e.babyCreatedTime.isAtSameMomentAs(baby.created));

  Future addEntry(Feed entry) async {
    await repo.update((_) => false, entry);
  }
}
