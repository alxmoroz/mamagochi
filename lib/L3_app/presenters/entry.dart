import '/../L3_app/presenters/date.dart';
import '../../L1_domain/entities/abstract_entry.dart';

extension EntryPresenter on AbstractEntry {
  String get endDateTime => '${end.strMedium}, ${end.strTime}';

  String get historyTrailingDateTime => isMoreMinute ? startEnd : end.strTime;
  bool get isMoreMinute => duration.inMinutes > 0;

  String get startDateTime => '${start.strMedium}, ${start.strTime}';
  String get startEnd => '${start.strTime}\n${end.strTime}';
}
