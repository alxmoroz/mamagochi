// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../L2_data/services/platform.dart';
import '../../components/adaptive.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/page.dart';
import '../../components/refresh.dart';
import '../../components/text.dart';
import '../../components/toolbar.dart';
import '../../components/toolbar_controller.dart';
import '../../navigation/route.dart';
import '../_base/loader_screen.dart';
import '../app/services.dart';
import 'widgets/left_menu.dart';
import 'widgets/right_toolbar.dart';

late MTToolbarController leftMenuController;
late MTToolbarController rightToolbarController;

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

  // @override
  // List<RouteBase> get routes => [];
}

final mainRoute = MainRoute();

class _MainView extends StatefulWidget {
  const _MainView({super.key});

  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<_MainView> with WidgetsBindingObserver {
  late final ScrollController _scrollController;
  bool _hasScrolled = false;

  @override
  void initState() {
    mainController.startup();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();

    rightToolbarController = MTToolbarController(isCompact: true, wideWidth: 220);
    leftMenuController = MTToolbarController(wideWidth: 242.0);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    leftMenuController.setCompact(!isBigScreen(context));
    super.didChangeDependencies();
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
    _scrollController.dispose();
    super.dispose();
  }

  String get _mainPageTitle => 'loc.main_page_title';

  Widget get _bigTitle => MTAdaptive(
        padding: const EdgeInsets.symmetric(horizontal: P3),
        child: Container(
          height: P8,
          alignment: Alignment.centerLeft,
          child: H1(_mainPageTitle, color: f2Color),
        ),
      );

  Widget _page(BuildContext context) {
    final big = isBigScreen(context);
    final canShowVertBars = canShowVerticalBars(context);
    final body = MTRefresh(
      onRefresh: mainController.reload,
      child: ListView(
        controller: isWeb ? _scrollController : null,
        children: const [],
      ),
    );
    return MTPage(
      key: widget.key,
      navBar: big
          ? _hasScrolled
              ? MTTopBar(leading: const SizedBox(), middle: _bigTitle)
              : null
          : MTTopBar(color: navbarColor, pageTitle: _mainPageTitle),
      body: body,
      leftBar: canShowVertBars ? LeftMenu(leftMenuController) : null,
      rightBar: big ? MainRightToolbar(rightToolbarController) : null,
      // bottomBar: canShowVertBars ? null : const BottomMenu(),
      scrollController: _scrollController,
      scrollOffsetTop: big ? P4 : P8,
      onScrolled: (scrolled) => setState(() => _hasScrolled = scrolled),
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
