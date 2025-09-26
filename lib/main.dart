// Copyright (c) 2024. Alexandr Moroz

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // ignore: depend_on_referenced_packages

import 'L2_data/services/platform.dart';
import 'L3_app/components/background.dart';
import 'L3_app/components/circular_progress.dart';
import 'L3_app/components/colors.dart';
import 'L3_app/components/constants.dart';
import 'L3_app/l10n/generated/l10n.dart';
import 'L3_app/navigation/router.dart';
import 'L3_app/views/app/services.dart';

Future main() async {
  setup();
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI for edge-to-edge display
  if (Platform.isAndroid) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }

  usePathUrlStrategy();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt.allReady(),
      builder: (_, snapshot) => snapshot.hasData
          ? MaterialApp.router(
              debugShowCheckedModeBanner: true,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: mainColor.resolve(context),
                  primary: mainColor.resolve(context),
                  brightness: MediaQuery.platformBrightnessOf(context),
                  surfaceTint: b2Color.resolve(context),
                  surface: b2Color.resolve(context),
                ),
                fontFamily: 'MontserratMamagochi',
                useMaterial3: true,
              ),
              scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: {
                if (isWeb) PointerDeviceKind.mouse,
                ...const MaterialScrollBehavior().dragDevices,
              }),
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              supportedLocales: S.delegate.supportedLocales,
              routerConfig: router,
              onGenerateTitle: (_) => loc.app_title,
            )
          : const MTBackgroundWrapper(Center(child: MTCircularProgress(size: P10))),
    );
  }
}
