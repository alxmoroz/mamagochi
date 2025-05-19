import 'abstract_entry.dart';

class Feed extends AbstractEntry {
  const Feed({required super.created, super.startDate, super.endDate, required super.babyCreatedTime});
  @override
  String toString() => 'babybottle';
}
