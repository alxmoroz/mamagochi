// Copyright (c) 2024. Alexandr Moroz

import 'dart:async';

import 'package:flutter/material.dart';

import 'colors.dart';
import 'constants.dart';
import 'dialog.dart';
import 'text.dart';

/// Показывает снекбар в виде карточки, выезжающей снизу.
///
/// [title] — основной текст (BaseText.medium, или SmallText.medium при subtitle).
/// [subtitle] — опциональный текст деталей (H1), показывается второй строкой.
/// [trailing] — опциональный виджет справа (например, кнопка «Изменить»).
/// [onTap] — действие при тапе на снекбар.
Future showMTSnackbar(String title, {String? subtitle, Widget? trailing, Function()? onTap, TextAlign? titleAlign}) async {
  await showMTDialog(
    _MTSnackbarDialog(title, subtitle: subtitle, trailing: trailing, onTap: onTap, titleAlign: titleAlign),
    forceBottomSheet: true,
    barrierColor: Colors.transparent,
  );
}

class _MTSnackbarDialog extends StatefulWidget {
  const _MTSnackbarDialog(this._title, {this.subtitle, this.trailing, this.onTap, this.titleAlign});
  final String _title;
  final String? subtitle;
  final Widget? trailing;
  final Function()? onTap;
  final TextAlign? titleAlign;

  @override
  State<_MTSnackbarDialog> createState() => _MTSnackbarState();
}

class _MTSnackbarState extends State<_MTSnackbarDialog> {
  Timer? _closingTimer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _closingTimer = Timer(const Duration(milliseconds: 3000), _close);
  }

  @override
  void dispose() {
    _closingTimer?.cancel();
    super.dispose();
  }

  /// Закрывает только свой роут. Обычный `Navigator.pop` снимает верхний роут —
  /// если сверху уже пикер/диалог, это даёт чёрный экран (пустой стек go_router).
  void _close() {
    if (_closing || !mounted) return;
    _closing = true;
    _closingTimer?.cancel();

    final route = ModalRoute.of(context);
    if (route == null || !route.isActive) return;

    // Уже закрывается (тап по барьеру / свайп) — второй pop не нужен.
    final animation = route.animation;
    if (animation != null && animation.status == AnimationStatus.reverse) return;

    final navigator = Navigator.of(context);
    if (route.isCurrent) {
      navigator.pop();
    } else {
      navigator.removeRoute(route);
    }
  }

  Future _onTap() async {
    _close();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = widget.subtitle != null && widget.subtitle!.isNotEmpty;
    final hasTrailing = widget.trailing != null;
    // Без trailing текст по центру; с trailing — прижато к start.
    final useCenter = !hasTrailing && !hasSubtitle;

    return Padding(
      padding: EdgeInsets.fromLTRB(P2, 0, P2, MediaQuery.of(context).padding.bottom + P2),
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 72, maxWidth: 420),
          decoration: BoxDecoration(
            color: b3Color.resolve(context),
            borderRadius: BorderRadius.circular(DEF_BORDER_RADIUS),
            boxShadow: [
              BoxShadow(
                blurRadius: P,
                offset: const Offset(0, -P_2),
                color: b0Color.resolve(context).withValues(alpha: 0.42),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(P3),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: useCenter ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Expanded(
                  child: hasSubtitle
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SmallText.medium(widget._title, align: widget.titleAlign, color: f2Color, maxLines: 1),
                            const SizedBox(height: P),
                            H1(widget.subtitle!, align: widget.titleAlign, maxLines: 2),
                          ],
                        )
                      : BaseText.medium(widget._title, align: useCenter ? TextAlign.center : widget.titleAlign, color: f2Color, maxLines: 2),
                ),
                if (hasTrailing) ...[
                  const SizedBox(width: P2),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
