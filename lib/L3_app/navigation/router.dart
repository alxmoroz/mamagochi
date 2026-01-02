// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/baby/baby_controller.dart';
import '../views/history/history_controller.dart';
import '../views/history/history_view.dart';
import '../views/main/main_view.dart';
import '../views/onboarding/onboarding_view.dart';
import 'route.dart';

final router = GoRouter(
  // debugLogDiagnostics: true,
  routes: [mainRoute, onboardingRoute],
  initialLocation: '/',
  initialExtra: 'local',
  onException: (_, state, r) {
    if (kDebugMode) print('GoRouter onException -> ${state.uri}');
    r.goMain();
  },
);

BuildContext get globalContext => router.routerDelegate.navigatorKey.currentContext!;

extension MTRouterHelper on GoRouter {
  RouteMatchList get _currentConfig => routerDelegate.currentConfiguration;
  MTRoute get currentRoute => _currentConfig.last.route as MTRoute;

  bool get isDeepLink => _currentConfig.extra == null;

  void _goNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) => goNamed(name, pathParameters: pathParameters, queryParameters: queryParameters, extra: extra ?? 'local');

  // Главная и вход
  void goMain() => _goNamed(mainRoute.name);
  void goHistory(HistoryController hc) => _goNamed('${mainRoute.name}/${HistoryRoute.staticBaseName}', extra: hc);

  // главный онбординг
  Future pushOnboarding(BabyController bc) async => await pushNamed(onboardingRoute.name, extra: bc);
}
