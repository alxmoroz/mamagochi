// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:mamagochi/L3_app/components/button.dart';
import 'package:mamagochi/L3_app/components/constants.dart';
import 'package:mamagochi/L3_app/navigation/router.dart';
import 'package:mamagochi/L3_app/views/history/history_view.dart';

import '../../../L2_data/services/platform.dart';
import '../../components/colors.dart';
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
    if (!isWeb) {
      if (state == AppLifecycleState.resumed) {
        mainController.startup();
      } else {
        mainController.onInactive();
      }
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
      body: SafeArea(
        child: Stack(children: [
          Align(
            alignment: Alignment.topLeft,
            child: MTButton(
                minSize: const Size(90, 90),
                constrained: false,
                color: b3Color,
                margin: const EdgeInsets.symmetric(horizontal: P2),
                type: MTButtonType.main,
                middle: const MTImage('menu', height: 60),
                onTap: router.goHistory),
          ),
          const Align(
            child: MTImage(
              'baby',
              height: 300,
              width: 300,
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomMenu(),
          ),
        ]),
      ),
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
