// Copyright (c) 2022. Alexandr Moroz

import '../entities/base_entity.dart';

abstract class AbstractDBModel<E extends LocalPersistable> {
  Future<AbstractDBModel> update(E entity);
  E toEntity();
}

typedef Filter<E extends LocalPersistable> = bool Function(E e);

abstract class AbstractLocalStorageRepo<M extends AbstractDBModel, E extends LocalPersistable> {
  Future<Iterable<E>> getAll([Filter<E>? filter]);
  Future<E?> getOne([Filter<E>? filter]);
  Future update(Filter<E> filter, E entity);
  Future delete(Filter<E> filter, E entity);
}
