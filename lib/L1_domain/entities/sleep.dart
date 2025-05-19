import 'abstract_entry.dart';

class Sleep extends AbstractEntry {
  const Sleep({required super.created, super.startDate, super.endDate, required super.babyCreatedTime});

  @override
  String toString() => 'bed';
}
