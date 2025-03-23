// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/main/main_view.dart';
import '../views/onboarding/onboarding_view.dart';
import 'route.dart';

final router = GoRouter(
    // debugLogDiagnostics: true,
    routes: [
      mainRoute,
      onboardingRoute,
    ],
    initialLocation: '/',
    initialExtra: 'local',
    onException: (_, state, r) {
      if (kDebugMode) print('GoRouter onException -> ${state.uri}');
      r.goMain();
    });

BuildContext get globalContext => router.routerDelegate.navigatorKey.currentContext!;

extension MTPathParametersHelper on GoRouterState {
  int? pathParamInt(String param) => int.tryParse(pathParameters[param] ?? '');
}

extension MTRouterHelper on GoRouter {
  RouteMatchList get _currentConfig => routerDelegate.currentConfiguration;
  MTRoute get currentRoute => _currentConfig.last.route as MTRoute;

  bool get isDeepLink => _currentConfig.extra == null;

  void _go(String location, {Object? extra = 'local'}) => go(location, extra: extra);

  void _goNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      goNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra ?? 'local',
      );

  // Главная и вход
  void goMain() => _goNamed(mainRoute.name);

  // главный онбординг
  Future pushOnboarding() async => await pushNamed(onboardingRoute.name, extra: 'local');

  Future goInner(Uri uri) async {
    String location = uri.path;
    if (uri.hasQuery) {
      location += '/?${uri.query}';
    }
    _go(location);
  }
}
