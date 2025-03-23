// Copyright (c) 2022. Alexandr Moroz

import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';

import '../../L2_data/services/platform.dart';

const CURRENCY_SYMBOL_ROUBLE = '₽';

class NumberSeparators {
  final NumberSymbols? _numberFormatSymbols = numberFormatSymbols[languageCode];

  String get decimalSep => RegExp.escape(_numberFormatSymbols?.DECIMAL_SEP ?? ',');
  String get groupSep => RegExp.escape(_numberFormatSymbols?.GROUP_SEP ?? ' ');
}

extension NumberFormatterPresenter on num {
  String get percents => NumberFormat("#%").format(this);
  String get currency => NumberFormat('#,###').format(this);
  String get currencyRouble => '$currency$CURRENCY_SYMBOL_ROUBLE';
  String get currencySharp => NumberFormat('#,###.##').format(this);
  String get financeTransaction => NumberFormat('+#,###.00;-#,###.00').format(this);
}
