import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import 'baby_face_assets.dart';
import 'baby_face_config.dart';

class BabyFaceWidget extends StatelessWidget {
  const BabyFaceWidget({required this.config, this.size, super.key});

  /// Размер холста SVG (viewBox). Совпадает с бывшими PNG малыша.
  static const viewBoxSize = 200.0;

  final BabyFaceConfig config;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final side = size ?? _defaultSize(context);

    return SizedBox(
      width: side,
      height: side,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: viewBoxSize,
          height: viewBoxSize,
          child: Stack(
            alignment: Alignment.center,
            children: [for (final layer in config.layers) _layer(layer)],
          ),
        ),
      ),
    );
  }

  Widget _layer(String name) => SvgPicture.asset(
    BabyFaceAssets.assetPath(name),
    width: viewBoxSize,
    height: viewBoxSize,
    fit: BoxFit.contain,
  );

  double _defaultSize(BuildContext context) => min(200, max(120, MediaQuery.sizeOf(context).height / 3.5));
}
