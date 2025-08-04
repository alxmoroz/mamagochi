// Copyright (c) 2022. Alexandr Moroz

import '../entities/baby.dart';
import '../entities/feed.dart';
import '../repositories/abs_db_repo.dart';

class FeedUC {
  FeedUC(this.repo);

  final AbstractLocalStorageRepo<AbstractDBModel, Feed> repo;

  Future<Iterable<Feed>> entries(Baby baby) async => await repo.getAll((e) => e.babyCreatedTime.isAtSameMomentAs(baby.created));

  Future edit(Feed feed) async {
    await repo.update(
      (saved) => saved.created.isAtSameMomentAs(feed.created),
      feed,
    );
  }

  Future delete(Feed feed) async {
    await repo.delete(
      (saved) => saved.created.isAtSameMomentAs(feed.created),
      feed,
    );
  }
}
