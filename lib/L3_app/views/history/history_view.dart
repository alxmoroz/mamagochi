import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mamagochi/L3_app/presenters/duration.dart';
import 'package:mamagochi/L3_app/presenters/entry.dart';

import '../../../L1_domain/entities/abstract_entry.dart';
import '../../../L1_domain/entities/sleep.dart';
import '../../components/constants.dart';
import '../../components/images.dart';
import '../../components/list_tile.dart';
import '../../components/page.dart';
import '../../components/text.dart';
import '../../components/toolbar.dart';
import '../../navigation/route.dart';
import '../../presenters/date.dart';
import '../app/services.dart';
import 'history_controller.dart';

class HistoryRoute extends MTRoute {
  static const staticBaseName = 'history';

  HistoryRoute({super.parent})
      : super(
          path: staticBaseName,
          baseName: staticBaseName,
          builder: (_, state) => _HistoryView(state.extra as HistoryController),
        );
}

class _HistoryView extends StatelessWidget {
  const _HistoryView(this._hc);
  final HistoryController _hc;

  Widget _dayEntries(DateTime date, Iterable<AbstractEntry> group) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        MTListGroupTitle(titleText: date.strMedium),
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: group.length,
            itemBuilder: (_, index) {
              final entry = group.elementAt(index);
              return MTListTile(
                leading: entry.image(size: P10),
                titleText: entry is Sleep && entry.duration.inMinutes > 0 ? '${loc.history_sleep_title} ${entry.duration.strInHoursAndMinutes}' : '',
                trailing: SmallText(entry.end.strTimeAgo),
                bottomDivider: index < group.length - 1,
              );
            })
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MTPage(
        navBar: MTNavBar(
          pageTitle: loc.history_title,
        ),
        body: _hc.hasEntries
            ? ListView.builder(
                itemCount: _hc.groupedEntries.keys.length,
                itemBuilder: (_, index) {
                  final date = _hc.groupedEntries.keys.elementAt(index);
                  final group = _hc.groupedEntries[date];
                  return group != null ? _dayEntries(date, group) : const SizedBox();
                })
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MTImage(
                      'no_info',
                      height: P10 * 5,
                      width: P10 * 5,
                    ),
                    H1(loc.history_empty_title, align: TextAlign.center),
                  ],
                ),
              ),
      ),
    );
  }
}
