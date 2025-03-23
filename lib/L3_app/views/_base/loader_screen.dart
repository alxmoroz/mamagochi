// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../components/adaptive.dart';
import '../../components/circular_progress.dart';
import '../../components/constants.dart';
import '../../components/dialog.dart';
import '../../components/images.dart';
import '../../components/page.dart';
import '../../components/text.dart';
import 'loadable.dart';

class LoaderScreen extends StatelessWidget {
  const LoaderScreen(this._l, {super.key, this.isDialog = false});
  final bool isDialog;
  final Loadable _l;
  LoadableState get _ls => _l.loaderState;

  Widget get _title => H3(
        _ls.titleText!,
        align: TextAlign.center,
        padding: const EdgeInsets.symmetric(horizontal: P3).copyWith(top: P3),
      );

  Widget get _description => BaseText(
        _ls.descriptionText!,
        align: TextAlign.center,
        padding: const EdgeInsets.symmetric(horizontal: P5).copyWith(top: P3),
        maxLines: 5,
      );

  Widget get _image => MTImage(_ls.imageName!);

  Widget get _child => ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(height: P6),
          if (_ls.imageName != null) _image,
          if (_ls.titleText != null) _title,
          if (_ls.descriptionText != null) _description,
          if (_ls.actionWidget == null) ...[
            const SizedBox(height: P6),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [MTCircularProgress(size: P10)]),
          ],
          if (_ls.actionWidget != null) ...[
            const SizedBox(height: P6),
            MTAdaptive.xs(child: _ls.actionWidget),
          ],
          const SizedBox(height: P6),
        ],
      );

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) => isDialog
            ? MTDialog(body: _child)
            : MTPage(key: const ValueKey('LoaderScreen'), body: SafeArea(top: false, bottom: false, child: Center(child: _child))),
      );
}
