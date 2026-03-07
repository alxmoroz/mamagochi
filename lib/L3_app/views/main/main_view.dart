// Copyright (c) 2024. Alexandr Moroz

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:mamagochi/L3_app/presenters/feed.dart';

import '../../../L2_data/services/platform.dart';
import '../../components/adaptive.dart';
import '../../components/button.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/datetime_picker.dart';
import '../../components/icons.dart';
import '../../components/images.dart';
import '../../components/page.dart';
import '../../navigation/route.dart';
import '../../navigation/router.dart';
import '../../presenters/baby.dart';
import '../_base/loader_screen.dart';
import '../app/services.dart';
import '../history/history_controller.dart';
import '../history/history_view.dart';
import 'widgets/baby_profile_dialog.dart';
import 'widgets/bottom_menu.dart';
import 'widgets/main_header_timers.dart';

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
  List<RouteBase> get routes => [HistoryRoute(parent: this)];
}

final mainRoute = MainRoute();

class _MainView extends StatefulWidget {
  const _MainView({super.key});

  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<_MainView> {
  AppLifecycleListener? _appstateListener;
  AppLifecycleState? _currentLifecycleState;

  void _lifecycleChanged(AppLifecycleState state) {
    if (_currentLifecycleState != state) {
      _currentLifecycleState = state;
      if (state == AppLifecycleState.resumed) {
        mainController.startup();
      } else {
        mainController.onInactive();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _lifecycleChanged(AppLifecycleState.resumed);

    if (!isWeb) {
      _appstateListener = AppLifecycleListener(onStateChange: _lifecycleChanged);
    }
  }

  @override
  void dispose() {
    _appstateListener?.dispose();
    super.dispose();
  }

  Future _tapEditStartSleep(HistoryController hc) async {
    final startDate = hc.lastSleep?.startDate;
    final baby = mainController.selectedBabyController?.baby;
    final date =
        await MTDateTimePicker.show(
          baby!.isBoy ? loc.edit_sleep_start_date_title_boy : loc.edit_sleep_start_date_title_girl,
          initialDate: startDate,
        ) ??
        startDate;
    await hc.editLastSleep(startDate: date);
  }

  Future _tapEditStartBreastFeed(HistoryController hc) async {
    final feed = hc.lastOngoingBreastFeed!;
    final startDate = feed.startDate ?? feed.created;
    final date = await MTDateTimePicker.show(feed.editFeedStartDateTitle, initialDate: startDate) ?? startDate;
    await hc.editFeed(feed.copyWith(startDate: date));
  }

  Widget get backgroundImage {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return isDark
        ? const Positioned(top: 0, left: 0, right: 0, height: 194, child: MTImage('stars', height: 194, width: 390))
        : const Positioned(right: 0, width: 218, height: 252, child: MTImage('sun', height: 252, width: 218));
  }

  Widget _page(BuildContext context) {
    final hc = mainController.selectedBabyController?.historyController;
    final baby = mainController.selectedBabyController?.baby;
    final screen = screenSize(context);
    final buttonSize = min(270.0, min(screen.width, screen.height) - 90 - 3 * P2);

    return MTPage(
      bg1Color: hc!.babyIsSleeping || hc.babyIsEating ? b1StartGradientColor : null,
      bg2Color: hc.babyIsSleeping || hc.babyIsEating ? b1EndGradientColor : null,
      background: backgroundImage,
      key: widget.key,
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: P5),
        child: Stack(
          children: [
            /// Кнопка меню
            Align(
              alignment: Alignment.topLeft,
              child: MTButton(
                minSize: const Size(90, 90),
                constrained: false,
                color: b3Color,
                margin: const EdgeInsets.symmetric(horizontal: P2),
                type: MTButtonType.main,
                middle: const MTSvgIcon('menu', size: 60),
                onTap: () => router.goHistory(hc),
              ),
            ),

            /// Таймер сна или кормления в заголовке
            MainHeaderTimer(
              hc: hc,
              buttonSize: buttonSize,
              onEditStartSleep: () => _tapEditStartSleep(hc),
              onEditStartBreastFeed: () => _tapEditStartBreastFeed(hc),
            ),

            /// Картинка малыша
            Align(
              child: GestureDetector(
                onTap: () => BabyProfileDialog.show(),
                child: hc.babyIsSleeping
                    ? baby!.imageSleep(size: 300)
                    : hc.babyIsEating
                    ? baby!.imageBreastFeed(hc.lastOngoingBreastFeed!.type.isLeftBreast, size: 300)
                    : baby!.image(size: 300),
              ),
            ),

            /// Картинка груди слева или справа при кормлении
            /// На смартфоне только в портрете, на планшете — в любой ориентации.
            if (hc.babyIsEating && (isBigScreen(context) || MediaQuery.orientationOf(context) == Orientation.portrait))
              Positioned(
                left: hc.lastOngoingBreastFeed!.type.isLeftBreast ? -100 : null,
                right: hc.lastOngoingBreastFeed!.type.isLeftBreast ? null : -100,
                top: 0,
                bottom: 0,
                child: const Center(child: IgnorePointer(child: MTImage('breast', height: 200))),
              ),

            /// Кнопки сна и кормления
            const Align(alignment: Alignment.bottomCenter, child: BottomMenu()),
          ],
        ),
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
