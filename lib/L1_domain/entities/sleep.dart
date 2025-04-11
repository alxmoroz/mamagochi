import 'abstract_entry.dart';

class Sleep extends AbstractEntry {
  const Sleep({super.start, required super.end});
  @override
  String toString() => 'bed';
}
