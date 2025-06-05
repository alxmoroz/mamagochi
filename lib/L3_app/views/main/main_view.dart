// Copyright (c) 2024. Alexandr Moroz

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:mamagochi/L3_app/components/button.dart';
import 'package:mamagochi/L3_app/components/constants.dart';
import 'package:mamagochi/L3_app/components/datetime_picker.dart';
import 'package:mamagochi/L3_app/components/text.dart';
import 'package:mamagochi/L3_app/navigation/router.dart';
import 'package:mamagochi/L3_app/presenters/baby.dart';
import 'package:mamagochi/L3_app/presenters/duration.dart';
import 'package:mamagochi/L3_app/views/history/history_view.dart';

import '../../../L2_data/services/platform.dart';
import '../../components/adaptive.dart';
import '../../components/colors.dart';
import '../../components/images.dart';
import '../../components/page.dart';
import '../../navigation/route.dart';
import '../_base/loader_screen.dart';
import '../app/services.dart';
import '../history/history_controller.dart';
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

  Future _tapEditStartSleep(HistoryController hc) async {
    final startDate = hc.lastSleep?.startDate;
    final baby = mainController.selectedBabyController?.baby;
    final date = await MTDateTimePicker.show(baby!.isBoy ? loc.edit_sleep_start_date_title_boy : loc.edit_sleep_start_date_title_girl,
            initialDate: startDate) ??
        startDate;
    await hc.editLastSleep(startDate: date);
  }

  Widget _page(BuildContext context) {
    final hc = mainController.selectedBabyController?.historyController;
    final baby = mainController.selectedBabyController?.baby;
    final sleepDuration = hc?.lastSleep?.durationFromStartToNow;
    final sleepDurationStr = sleepDuration?.strInHoursAndMinutes;

    final screen = screenSize(context);
    final buttonSize = min(270.0, min(screen.width, screen.height) - 90 - 3 * P2);

    return MTPage(
      bg1Color: hc!.babyIsSleeping ? b1Color : b2Color,
      key: widget.key,
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: P5),
        child: Stack(children: [
          Align(
            child: hc.babyIsSleeping ? baby.imageSleep(size: 300) : baby.image(size: 300),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: MTButton(
                minSize: const Size(90, 90),
                constrained: false,
                color: b3Color,
                margin: const EdgeInsets.symmetric(horizontal: P2),
                type: MTButtonType.main,
                middle: const MTImage('menu', height: 60),
                onTap: () => router.goHistory(hc)),
          ),
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
                      sleepDuration!.inMinutes > 1 ? loc.how_much_sleep(sleepDurationStr!) : loc.sleep_process_title,
                      maxLines: 2,
                      color: f2Color,
                    ),
                    onTap: () => _tapEditStartSleep(hc),
                  ),
                )
              : const SizedBox(),
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
