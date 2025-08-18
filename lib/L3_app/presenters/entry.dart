import 'package:flutter/cupertino.dart';

import '../../L1_domain/entities/abstract_entry.dart';
import '../../L1_domain/entities/sleep.dart';
import '../components/images.dart';

extension EntryPresenter on AbstractEntry? {
  Widget image({double? size}) => MTImage(
        this is Sleep == true ? 'bed' : 'bottle_baby_formula',
        height: size,
        width: size,
      );
}
