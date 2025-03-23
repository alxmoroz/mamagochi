// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/material.dart';

import 'colors.dart';
import 'linkify/linkify.dart';
import 'text.dart';
import 'text_field.dart';

class MTTextFieldInline extends StatelessWidget {
  const MTTextFieldInline(
    this.controller, {
    super.key,
    this.maxLines,
    this.style,
    this.hintStyle,
    this.hintText,
    required this.fNode,
    this.autofocus = false,
    this.readOnly = false,
    this.paddingLines = 0,
    this.textInputAction,
    this.onTap,
    this.onChanged,
    this.onSubmit,
  });

  final TextEditingController controller;
  final int? maxLines;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final String? hintText;
  final FocusNode? fNode;
  final bool autofocus;
  final bool readOnly;
  final int paddingLines;
  final TextInputAction? textInputAction;
  final Function()? onTap;
  final Function(String str)? onChanged;
  final Function()? onSubmit;

  @override
  Widget build(BuildContext context) {
    final text = controller.text;
    final hasText = text.isNotEmpty;
    final textStyle = style ?? BaseText('', maxLines: maxLines).style(context);
    final hasFocus = fNode?.hasFocus == true;
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // if (!readOnly)
        Opacity(
          opacity: !readOnly && (hasFocus || !hasText) ? 1 : 0,
          child: MTTextField(
            readOnly: readOnly,
            textInputAction: textInputAction,
            controller: controller,
            autofocus: autofocus,
            margin: EdgeInsets.zero,
            maxLines: hasFocus ? maxLines : 2,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: hintText,
              hintStyle: hintStyle ?? textStyle.copyWith(color: f3Color.resolve(context)),
            ),
            style: style,
            onChanged: onChanged,
            onSubmitted: onSubmit != null ? (_) => onSubmit!() : null,
            focusNode: fNode,
          ),
        ),
        if (hasText && !hasFocus)
          MTLinkify(
            text,
            maxLines: maxLines,
            style: textStyle,
            paddingLines: paddingLines,
            onTap: onTap,
          ),
      ],
    );
  }
}
