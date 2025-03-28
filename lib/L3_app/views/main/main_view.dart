// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:mamagochi/L3_app/components/button.dart';
import 'package:mamagochi/L3_app/navigation/router.dart';
import 'package:mamagochi/L3_app/views/history/history_view.dart';

import '../../../L2_data/services/platform.dart';
import '../../components/icons.dart';
import '../../components/images.dart';
import '../../components/page.dart';
import '../../navigation/route.dart';
import '../_base/loader_screen.dart';
import '../app/services.dart';
import 'widgets/bottom_menu.dart';

class MainRoute extends MTRoute {
  MainRoute()
      : super(
          baseName: 'main',
          path: '/',
          redirect: (_, state) {
            if (state.uri.hasQuery) localSettingsController.parseMainQuery(state.uri);
            return null;
          },
          controller: mainController,
          noTransition: true,
          builder: (_, state) => _MainView(key: state.pageKey),
        );

  @override
  List<RouteBase> get routes => [
        HistoryRoute(parent: this),
      ];
}

final mainRoute = MainRoute();

class _MainView extends StatefulWidget {
  const _MainView({super.key});

  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<_MainView> with WidgetsBindingObserver {
  @override
  void initState() {
    mainController.startup();
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!isWeb && state == AppLifecycleState.resumed) {
      mainController.startup();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _page(BuildContext context) {
    return MTPage(
      key: widget.key,
      body: ListView(children: [
        MTButton.icon(const MenuIcon(), onTap: router.goHistory),
        const MTImage(
          'no_info',
          height: 300,
          width: 300,
        ),
      ]),
      bottomBar: const BottomMenu(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => appController.loading
          ? LoaderScreen(appController)
          : mainController.loading
              ? LoaderScreen(mainController)
              : _page(context),
    );
  }
}
