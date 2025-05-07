// Copyright (c) 2022. Alexandr Moroz

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:mamagochi/L1_domain/entities/baby.dart';
import 'package:mamagochi/L1_domain/entities/sleep.dart';
import 'package:mamagochi/L2_data/models/sleep.dart';

import '../../../L1_domain/entities/app_local_settings.dart';
import '../../../L1_domain/entities/base_entity.dart';
import '../../../L1_domain/repositories/abs_db_repo.dart';
import '../../L1_domain/entities/feed.dart';
import '../models/app_local_settings.dart';
import '../models/baby.dart';
import '../models/base.dart';
import '../models/feed.dart';

typedef ModelCreator<T> = T Function();

abstract class DBRepo<M extends BaseModel, E extends LocalPersistable> extends AbstractLocalStorageRepo<M, E> {
  DBRepo(this.boxName, this.modelCreator);

  final String boxName;
  ModelCreator<M> modelCreator;

  Box<M>? _box;

  Future<Box<M>> get box async {
    _box ??= await Hive.openBox<M>(boxName);
    return _box!;
  }

  Future<M> _getOrCreateModel(Filter<E> filter) async {
    M model;
    try {
      final values = (await box).values;
      model = values.firstWhere((m) => filter(m.toEntity() as E));
    } catch (e) {
      model = modelCreator();
      await (await box).add(model);
    }
    return model;
  }

  @override
  Future<Iterable<E>> getAll([Filter<E>? filter]) async {
    var entities = (await box).values.map((model) => model.toEntity() as E);
    if (filter != null) {
      entities = entities.where(filter);
    }
    return entities;
  }

  @override
  Future<E?> getOne([Filter<E>? filter]) async {
    final entities = await getAll(filter);
    return entities.isNotEmpty ? entities.first : null;
  }

  @override
  Future update(Filter<E> filter, E entity) async {
    try {
      final model = await _getOrCreateModel(filter);
      await model.update(entity);
    } catch (e) {
      if (kDebugMode) {
        print('update error $e\n$entity');
      }
    }
  }

  @override
  Future delete(Filter<E> filter, E entity) async {
    try {
      final model = await _getOrCreateModel(filter);
      await model.delete();
    } catch (e) {
      if (kDebugMode) {
        print('delete error $e\n$entity');
      }
    }
  }
}

class LocalSettingsRepo extends DBRepo<AppLocalSettingsHO, AppLocalSettings> {
  LocalSettingsRepo() : super('LocalSettings', () => AppLocalSettingsHO());
}

class SleepRepo extends DBRepo<SleepHO, Sleep> {
  SleepRepo() : super('Sleep', () => SleepHO());
}

class FeedRepo extends DBRepo<FeedHO, Feed> {
  FeedRepo() : super('Feed', () => FeedHO());
}

class BabyRepo extends DBRepo<BabyHO, Baby> {
  BabyRepo() : super('Baby', () => BabyHO());
}
