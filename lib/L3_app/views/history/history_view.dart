import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mamagochi/L3_app/components/images.dart';
import 'package:mamagochi/L3_app/components/list_tile.dart';
import 'package:mamagochi/L3_app/components/text.dart';
import 'package:mamagochi/L3_app/components/toolbar.dart';
import 'package:mamagochi/L3_app/presenters/date.dart';
import 'package:mamagochi/L3_app/views/app/services.dart';

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

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MTPage(
        navBar: const MTNavBar(),
        body: historyController.hasSleepEntries
            ? ListView.builder(
                itemBuilder: (_, index) {
                  final sleep = historyController.sortedSleepEntries.elementAt(index);
                  return MTListTile(
                    titleText: '${sleep.end.strMedium} ${sleep.end.strTime}',
                    trailing: BaseText(sleep.end.strTimeAgo),
                  );
                },
                itemCount: historyController.sleepEntries.length,
              )
            : const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MTImage(
                      'no_info',
                      height: 300,
                      width: 300,
                    ),
                    H2(
                      'Записей пока нет',
                      align: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
