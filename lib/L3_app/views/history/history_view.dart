import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mamagochi/L3_app/components/images.dart';
import 'package:mamagochi/L3_app/components/list_tile.dart';
import 'package:mamagochi/L3_app/components/text.dart';
import 'package:mamagochi/L3_app/components/toolbar.dart';
import 'package:mamagochi/L3_app/presenters/date.dart';
import 'package:mamagochi/L3_app/views/app/services.dart';

import '../../../L1_domain/entities/abstract_entry.dart';
import '../../components/constants.dart';
import '../../components/page.dart';
import '../../navigation/route.dart';

class HistoryRoute extends MTRoute {
  static const staticBaseName = 'history';

  HistoryRoute({super.parent})
      : super(
          path: staticBaseName,
          baseName: staticBaseName,
          builder: (_, state) => HistoryView(key: state.pageKey),
        );

  //это нужно только для веба
  //@override
  //String title(GoRouterState state) => loc.project_list_title;
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

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
                leading: MTImage(
                  '$entry',
                  height: P10,
                ),
                trailing: BaseText(entry.end.strTimeAgo),
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
        body: historyController.hasEntries
            ? ListView.builder(
                itemCount: historyController.groupedEntries.keys.length,
                itemBuilder: (_, index) {
                  final date = historyController.groupedEntries.keys.elementAt(index);
                  final group = historyController.groupedEntries[date];
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
                    H2(loc.history_empty_title, align: TextAlign.center),
                  ],
                ),
              ),
      ),
    );
  }
}
