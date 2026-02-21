// Copyright (c) 2024. Alexandr Moroz

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:mamagochi/L3_app/presenters/feed.dart';
import 'package:mamagochi/L3_app/presenters/sleep.dart';

import '../../../L2_data/services/platform.dart';
import '../../components/adaptive.dart';
import '../../components/button.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/datetime_picker.dart';
import '../../components/images.dart';
import '../../components/page.dart';
import '../../components/text.dart';
import '../../navigation/route.dart';
import '../../navigation/router.dart';
import '../../presenters/baby.dart';
import '../../presenters/duration.dart';
import '../_base/loader_screen.dart';
import '../app/services.dart';
import '../history/history_controller.dart';
import '../history/history_view.dart';
import 'widgets/baby_profile_dialog.dart';
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
    final date =
        await MTDateTimePicker.show(
          feed.editFeedStartDateTitle,
          initialDate: startDate,
        ) ??
        startDate;
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
    final sleepDuration = hc?.lastSleep?.durationFromStartToNow;
    final sleepDurationStr = sleepDuration?.strInHoursAndMinutes;
    final feedDuration = hc?.lastOngoingBreastFeed?.durationFromStartToNow;
    final feedDurationStr = feedDuration?.strInHoursAndMinutes;

    final screen = screenSize(context);
    final buttonSize = min(270.0, min(screen.width, screen.height) - 90 - 3 * P2);

    return MTPage(
      bg1Color: hc!.babyIsSleeping ? b1StartGradientColor : null,
      bg2Color: hc.babyIsSleeping ? b1EndGradientColor : null,
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
                middle: const MTImage('menu', height: 60),
                onTap: () => router.goHistory(hc),
              ),
            ),

            /// Кнопка таймера сна или кормления в заголовке (одна из двух)
            hc.babyIsSleeping
                ? Align(
                    alignment: Alignment.topRight,
                    child: MTButton(
                      minSize: Size(buttonSize, 90),
                      constrained: false,
                      color: b3Color,
                      margin: const EdgeInsets.symmetric(horizontal: P2),
                      type: MTButtonType.main,
                      leading: const MTImage('time', height: 60),
                      trailing: H2(
                        sleepDuration!.inMinutes > 1 ? loc.how_much_sleep(sleepDurationStr!) : hc.lastSleep?.sleepJustNowTitle ?? '',
                        maxLines: 2,
                        color: f2Color,
                      ),
                      onTap: () => _tapEditStartSleep(hc),
                    ),
                  )
                : hc.babyIsEating
                    ? Align(
                        alignment: Alignment.topRight,
                        child: MTButton(
                          minSize: Size(buttonSize, 90),
                          constrained: false,
                          color: b3Color,
                          margin: const EdgeInsets.symmetric(horizontal: P2),
                          type: MTButtonType.main,
                          leading: const MTImage('time', height: 60),
                          trailing: H2(
                            feedDuration != null && feedDuration.inMinutes > 1
                                ? loc.how_much_feeding(feedDurationStr!)
                                : hc.lastOngoingBreastFeed?.feedJustNowTitle ?? '',
                            maxLines: 2,
                            color: f2Color,
                          ),
                          onTap: () => _tapEditStartBreastFeed(hc),
                        ),
                      )
                    : const SizedBox(),

            /// Картинка малыша
            Align(
              child: GestureDetector(
                onTap: () => BabyProfileDialog.show(),
                child: hc.babyIsSleeping ? baby!.imageSleep(size: 300) : baby!.image(size: 300),
              ),
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
