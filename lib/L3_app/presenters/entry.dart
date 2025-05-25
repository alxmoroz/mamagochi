import 'package:flutter/cupertino.dart';
import 'package:mamagochi/L1_domain/entities/abstract_entry.dart';
import 'package:mamagochi/L1_domain/entities/sleep.dart';

import '../components/images.dart';

extension EntryPresenter on AbstractEntry? {
  Widget image({double? size}) => MTImage(
        this is Sleep == true ? 'bed' : 'babybottle',
        height: size,
        width: size,
      );
}
