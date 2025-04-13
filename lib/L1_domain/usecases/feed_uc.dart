// Copyright (c) 2022. Alexandr Moroz

import '../entities/feed.dart';
import '../repositories/abs_db_repo.dart';

class FeedUC {
  FeedUC(this.repo);

  final AbstractLocalStorageRepo<AbstractDBModel, Feed> repo;

  Future<Iterable<Feed>> entries() async => await repo.getAll();

  Future addEntry(Feed entry) async {
    await repo.update((saved) => saved.end == entry.end, entry);
  }
}
