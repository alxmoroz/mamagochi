// Copyright (c) 2022. Alexandr Moroz

import 'package:flutter/material.dart';

import 'colors.dart';
import 'constants.dart';
import 'divider.dart';
import 'gesture.dart';
import 'loader.dart';
import 'material_wrapper.dart';
import 'text.dart';

class MTListTile extends StatelessWidget with GestureManaging {
  const MTListTile({
    super.key,
    this.leading,
    this.middle,
    this.subtitle,
    this.titleText,
    this.trailing,
    this.onTap,
    this.onHover,
    this.color,
    this.padding,
    this.margin,
    this.dividerIndent,
    this.dividerEndIndent,
    this.topDivider = false,
    this.bottomDivider = true,
    this.crossAxisAlignment,
    this.uf = true,
    this.loading,
    this.minHeight,
    this.decoration,
  });
  final Widget? leading;
  final Widget? middle;
  final Widget? subtitle;
  final String? titleText;
  final Widget? trailing;
  final Function()? onTap;
  final Function(bool)? onHover;

  final Color? color;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? dividerIndent;
  final double? dividerEndIndent;
  final bool topDivider;
  final bool bottomDivider;
  final CrossAxisAlignment? crossAxisAlignment;
  final bool uf;
  final bool? loading;
  final double? minHeight;
  final BoxDecoration? decoration;

  static const _defaultIndent = P3;

  Widget get _divider => MTDivider(
        indent: dividerIndent ?? padding?.left ?? _defaultIndent,
        endIndent: dividerEndIndent ?? padding?.right ?? _defaultIndent,
      );

  EdgeInsets get _defaultPadding => const EdgeInsets.symmetric(horizontal: _defaultIndent, vertical: P2);

  @override
  Widget build(BuildContext context) {
    final splashColor = mainColor.resolve(context).withAlpha(15);
    final hoverColor = mainColor.resolve(context).withAlpha(7);

    final hasMiddle = middle != null || titleText != null;
    final hasSubtitle = subtitle != null;
    final bgColor = (color ?? b3Color).resolve(context);
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        Container(
          margin: margin ?? EdgeInsets.zero,
          decoration: decoration ??
              BoxDecoration(
                color: bgColor,
                // gradient: LinearGradient(
                //   colors: [bgColor, bgColor],
                //   stops: const [0.5, 1],
                // ),
              ),
          child: material(
            InkWell(
              onTap: onTap != null ? () => tapAction(uf, onTap!) : null,
              onHover: onHover,
              hoverColor: hoverColor,
              highlightColor: hoverColor,
              splashColor: splashColor,
              canRequestFocus: false,
              focusColor: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (topDivider) _divider,
                  Padding(
                    padding: padding ?? _defaultPadding,
                    child: Row(
                      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: minHeight ?? DEF_TAPPABLE_ICON_SIZE),
                        if (leading != null) ...[
                          leading!,
                          if (hasMiddle || hasSubtitle) const SizedBox(width: P2),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (hasMiddle) middle ?? BaseText(titleText!, maxLines: 1),
                              if (hasSubtitle) ...[
                                if (hasMiddle) const SizedBox(height: P),
                                subtitle!,
                              ],
                            ],
                          ),
                        ),
                        if (trailing != null) trailing!,
                      ],
                    ),
                  ),
                  if (bottomDivider) _divider,
                ],
              ),
            ),
          ),
        ),
        if (loading == true) const MTLoader(),
      ],
    );
  }
}

class MTListGroupTitle extends StatelessWidget {
  const MTListGroupTitle({
    super.key,
    this.leading,
    this.middle,
    this.titleText,
    this.trailing,
    this.color,
    this.padding,
    this.margin,
    this.topMargin,
    this.onTap,
  });

  final Widget? leading;
  final Widget? middle;
  final String? titleText;
  final Widget? trailing;
  final Color? color;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? topMargin;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return MTListTile(
      minHeight: 0,
      leading: leading,
      middle: middle ?? BaseText.f2(titleText ?? '', maxLines: 1),
      trailing: trailing,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: P3, vertical: P),
      margin: margin ?? EdgeInsets.only(top: topMargin ?? P2),
      color: color ?? Colors.transparent,
      bottomDivider: false,
      onTap: onTap,
    );
  }
}
