// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

import '../../L2_data/services/platform.dart';
import '../components/adaptive.dart';
import '../components/colors.dart';
import '../components/constants.dart';
import '../components/dialog.dart';
import '../views/_base/loadable.dart';
import '../views/_base/loader_screen.dart';
import '../views/app/services.dart';

class MTRoute extends GoRoute {
  MTRoute({
    required this.baseName,
    this.parent,
    this.controller,
    this.noTransition = false,
    super.routes,
    super.redirect,
    String? path,
    GoRouterWidgetBuilder? builder,
  }) : super(
          path: path ?? '/',
          builder: builder ?? (_, __) => Container(),
        );

  final String baseName;
  final MTRoute? parent;
  final Loadable? controller;
  final bool noTransition;

  bool get parentLoading => parent?.controller?.loading == true;

  @override
  String get name => '${parent?.name ?? ''}/$baseName';

  double get dialogMaxWidth => SCR_S_WIDTH;

  bool isDialog(BuildContext context) => false;

  String title(GoRouterState state) => '';

  @override
  GoRouterPageBuilder? get pageBuilder => (BuildContext context, GoRouterState state) {
        mainController.setRoute(this);

        if (isWeb) {
          final pageTitle = title(state);
          SystemChrome.setApplicationSwitcherDescription(ApplicationSwitcherDescription(
            label: '${loc.app_title}${pageTitle.isNotEmpty ? ' | $pageTitle' : ''}',
            primaryColor: mainColor.resolve(context).toARGB32(),
          ));
        }

        final dialog = isDialog(context);

        Widget child = parent?.controller != null
            ? Observer(builder: (_) => parentLoading ? LoaderScreen(parent!.controller!, isDialog: dialog) : builder!(context, state))
            : builder!(context, state);

        return dialog
            ? MTDialogPage(
                name: state.name,
                arguments: state.extra,
                maxWidth: dialogMaxWidth,
                key: state.pageKey,
                child: child,
              )
            : isBigScreen(context) || noTransition
                ? NoTransitionPage(
                    name: state.name,
                    arguments: state.extra,
                    key: state.pageKey,
                    child: child,
                  )
                : MaterialPage(
                    name: state.name,
                    arguments: state.extra,
                    key: state.pageKey,
                    child: child,
                  );
      };
}
