// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/cupertino.dart';

import 'constants.dart';
import 'text.dart';

class TextDemo extends StatelessWidget {
  const TextDemo({super.key});

  Widget _t(BaseText text, BuildContext context) {
    final style = text.style(context);
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: P6),
            text,
            const Spacer(),
            BaseText('fs: ${style.fontSize?.round()}  w: ${style.fontWeight?.value}'),
            const SizedBox(width: P6),
          ],
        ),
        const SizedBox(height: P3),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // _t(const D1('D1'), context),
        _t(const D2('D2'), context),
        _t(const D3('D3'), context),
        _t(const DText('DText'), context),
        _t(const DSmallText('DSmallText'), context),
        _t(const H1('H1'), context),
        _t(const H2('H2'), context),
        _t(const H3('H3'), context),
        _t(const BaseText.medium('BaseText Medium'), context),
        _t(const BaseText('BaseText'), context),
        _t(const SmallText('SmallText'), context),
      ],
    );
  }
}
