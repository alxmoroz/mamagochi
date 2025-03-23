// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../components/adaptive.dart';
import '../../../components/colors.dart';
import '../../../components/constants.dart';
import '../../../components/icons.dart';
import '../../../components/list_tile.dart';
import '../../../components/text.dart';
import '../../../components/toolbar_controller.dart';
import '../../../components/vertical_toolbar.dart';
import '../../../navigation/router.dart';
import '../../app/services.dart';
import '../main_view.dart';

class LeftMenu extends StatelessWidget implements PreferredSizeWidget {
  const LeftMenu(this._tbc, {super.key});
  final MTToolbarController _tbc;

  bool get _compact => _tbc.compact;

  @override
  Size get preferredSize => Size.fromWidth(_tbc.width);

  BoxDecoration _selectedDecoration(BuildContext context) {
    final topShadowColor = b1Color.resolve(context);
    final selectedColor = b2Color.resolve(context);
    return BoxDecoration(
      color: b2Color.resolve(context),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topShadowColor, selectedColor.withAlpha(42), selectedColor],
        stops: const [0, 0.1, 1],
      ),
    );
  }

  static const _selectedSize = P5;
  static const _unselectedSize = P4;

  Widget _menuButton(BuildContext context, Widget icon, String title, bool selected, Function()? onTap) => MTListTile(
        middle: Row(
          mainAxisAlignment: _compact ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (!_compact && !selected) const SizedBox(width: (_selectedSize - _unselectedSize) / 2),
            icon,
            if (!_compact)
              BaseText(
                title,
                weight: selected ? null : FontWeight.w300,
                color: f2Color,
                maxLines: 1,
                padding: const EdgeInsets.only(left: P2),
              ),
          ],
        ),
        decoration: selected ? _selectedDecoration(context) : null,
        bottomDivider: false,
        onTap: onTap,
      );

  Widget _homeButton(BuildContext context, bool selected) => _menuButton(
        context,
        HomeIcon(size: selected ? _selectedSize : _unselectedSize),
        'loc.main_page_title',
        selected,
        router.goMain,
      );

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final route = mainController.currentRoute;
      return _tbc.hidden
          ? const SizedBox()
          : VerticalToolbar(
              _tbc,
              rightSide: false,
              child: Column(
                children: [
                  if (isBigScreen(context)) _homeButton(context, route is MainRoute),
                  // const Spacer(),
                ],
              ),
            );
    });
  }
}
