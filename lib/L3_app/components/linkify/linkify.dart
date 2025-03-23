// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../navigation/router.dart';
import '../colors.dart';
import '../text.dart';
import 'element.dart';
import 'parser.dart';

class MTLinkify extends StatelessWidget {
  const MTLinkify(
    this.text, {
    this.maxLines,
    this.style,
    this.linkStyle,
    this.textAlign,
    this.paddingLines = 0,
    this.onTap,
    super.key,
  });
  final String text;
  final int? maxLines;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final TextAlign? textAlign;
  final int paddingLines;
  final Function()? onTap;

  Future _openLink(Uri uri) async {
    if (uri.isInner == true) {
      await router.goInner(uri);
    } else {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? BaseText('', maxLines: maxLines).style(context);
    final elements = parse(text);
    return SelectableText.rich(
      TextSpan(
        style: baseStyle,
        children: [
          for (final el in elements)
            el is UriElement && el.hasUri
                ? TextSpan(
                    text: '$el',
                    style: linkStyle ?? baseStyle.copyWith(color: mainColor.resolve(context)),
                    recognizer: TapGestureRecognizer()..onTap = () => _openLink(el.uri!),
                  )
                : TextSpan(text: '$el', style: baseStyle),
          // дополнительная пустая строка, потому что нет свойства пэддинга у SelectableText
          if (elements.isNotEmpty && paddingLines > 0) TextSpan(text: '\n' * paddingLines),
        ],
      ),
      scrollPhysics: const NeverScrollableScrollPhysics(),
      textAlign: textAlign,
      minLines: 1,
      maxLines: maxLines,
      contextMenuBuilder: (_, state) => AdaptiveTextSelectionToolbar.buttonItems(
        anchors: state.contextMenuAnchors,
        buttonItems: state.contextMenuButtonItems,
      ),
      onTap: onTap,
    );
  }
}
