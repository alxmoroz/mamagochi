// Copyright (c) 2022. Alexandr Moroz

import 'package:collection/collection.dart';

import 'errors.dart';

abstract class LocalPersistable {}

abstract class RPersistable {
  RPersistable({this.id, this.createdOn, this.updatedOn});

  int? id;
  bool filled = false;

  // TODO: убрать этот механизм (см. как в задачах сделано)
  bool removed = false;

  MTError? error;
  bool loading = false;

  bool get isNew => id == null;

  final DateTime? createdOn;
  final DateTime? updatedOn;
}

abstract class WSBounded extends RPersistable {
  WSBounded({super.id, super.createdOn, super.updatedOn, required this.wsId});

  final int wsId;
}

abstract class Codable extends RPersistable {
  Codable({super.id, super.createdOn, super.updatedOn, required this.code});

  String code;

  @override
  String toString() => code;
}

abstract class Titleable extends RPersistable implements Comparable {
  Titleable({
    super.id,
    super.createdOn,
    super.updatedOn,
    required this.title,
    this.description = '',
  });

  String title;
  String description;

  @override
  String toString() => title;

  @override
  int compareTo(t2) => compareNatural(title, (t2 as Titleable).title);
}
