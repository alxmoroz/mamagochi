import '/../L3_app/presenters/date.dart';
import '../../L1_domain/entities/abstract_entry.dart';

extension EntryPresenter on AbstractEntry {
  String get endDateTime => '${end.strMedium}, $endTitle';

  String get historyStartEndTimeTitle => isMoreMinute ? startEndTitle : endTitle;
  bool get isMoreMinute => duration.inMinutes > 0;

  String get startDateTime => '${start.strMedium}, ${start.strTime}';
  String get startTitle => start.strTime;
  String get endTitle => end.strTime;
  String get startEndTitle => '$startTitle\n$endTitle';
}
