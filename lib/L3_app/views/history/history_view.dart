import 'package:flutter/cupertino.dart';
import 'package:mamagochi/L3_app/components/toolbar.dart';

import '../../components/list_tile.dart';
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
    return MTPage(
      navBar: const MTNavBar(),
      body: ListView(
        children: const [
          MTListTile(
            titleText: 'История событий',
          ),
        ],
      ),
    );
  }
}
