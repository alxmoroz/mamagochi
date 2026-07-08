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
  late Timer _closingTimer;

  @override
  void initState() {
    _closingTimer = Timer(const Duration(milliseconds: 3000), () {
      if (context.mounted) Navigator.of(context).pop();
    });
    super.initState();
  }

  @override
  void dispose() {
    _closingTimer.cancel();
    super.dispose();
  }

  Future _onTap() async {
    _closingTimer.cancel();
    if (context.mounted) Navigator.of(context).pop();
    if (widget.onTap != null) {
      widget.onTap!();
    }
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
