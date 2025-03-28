// Copyright (c) 2025. Alexandr Moroz

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import '../../components/button.dart';
import '../../navigation/router.dart';
import '../app/services.dart';

part 'loadable.g.dart';

mixin Loadable {
  final _l = LoadableState();
  LoadableState get loaderState => _l;
  bool get loading => _l.loading;

  void setLoaderScreen({
    String? titleText,
    String? descriptionText,
    String? imageName,
    String? actionText,
    Widget? actionWidget,
  }) =>
      _l.set(
        titleText: titleText,
        descriptionText: descriptionText,
        imageName: imageName,
        actionText: actionText,
        actionWidget: actionWidget,
      );

  void setLoaderScreenLoading() => _l.set(titleText: loc.loader_refreshing_title, imageName: 'loading');
  void setLoaderScreenSaving() => _l.set(titleText: loc.loader_saving_title, imageName: 'save');

  void startLoading() => _l.start();
  void stopLoading() => _l.stop();

  Future load(Function() function) async {
    startLoading();
    try {
      await function();
      stopLoading();
    } on Exception catch (e) {
      parseError(e);
    }
  }

  void parseError(Exception e) => _l.parseError(e);
}

class LoadableState extends _LoadableBase with _$LoadableState {
  void parseError(Exception e) {
    // if (e is MTOAuthError) {
    // _setAuthError();
    // } else if (e is DioException && e.type == DioExceptionType.badResponse) {
    //   final code = e.response?.statusCode ?? 666;

    // if ([401, 403, 407].contains(code)) {
    // ошибки авторизации
    // if (e.requestOptions.path.startsWith('/v1/auth/password')) {
    // Показываем диалог, если это именно авторизация
    // _setAuthError();
    // } else {
    // в остальных случаях выбрасываем без объяснений
    // authController.signOut();
    // }
    // } else {
    //   программные ошибки сервера
    // if (kDebugMode) print(e);
    // }
    // } else if (kDebugMode) {
    //   print(e);
    // }
    if (kDebugMode) print(e);
  }
}

abstract class _LoadableBase with Store {
  @observable
  bool loading = true;

  @action
  void start() => loading = true;

  @action
  void stop({bool pop = false}) {
    loading = false;
    if (pop) {
      router.pop();
    }
  }

  @observable
  String? imageName;

  @observable
  String? titleText;

  @observable
  String? descriptionText;

  @observable
  Widget? actionWidget;

  Widget _stopActionButton(String actionText) => MTButton.secondary(
        titleText: actionText,
        onTap: () => stop(pop: true),
      );

  @action
  void set({
    String? titleText,
    String? descriptionText,
    String? imageName,
    String? actionText,
    Widget? actionWidget,
  }) {
    actionWidget ??= actionText != null ? _stopActionButton(actionText) : null;
    this.imageName = imageName;
    this.titleText = titleText;
    this.descriptionText = descriptionText;
    this.actionWidget = actionWidget;
  }
}
