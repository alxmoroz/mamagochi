// Copyright (c) 2022. Alexandr Moroz

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

const P = 6.0;
const P2 = P * 2.0; // 12
const P3 = P * 3.0; // 18
const P4 = P * 4.0; // 24
const P5 = P * 5.0; // 30
const P6 = P * 6.0; // 36
const P7 = P * 7.0; // 42
const P8 = P * 8.0; // 48
const P9 = P * 9.0; // 54
const P10 = P * 10.0; // 60
const P11 = P * 11.0; // 66
const P12 = P * 12.0; // 72

const P_2 = P / 2; // 3
const P_3 = P / 3; // 2

const DEF_PAGE_TOP_PADDING = P3;
const DEF_PAGE_BOTTOM_PADDING = P5;
const DEF_DIALOG_BOTTOM_PADDING = P3;

const DEF_HP = P3;
const DEF_VP = P2;
const DEF_PADDING = EdgeInsets.symmetric(horizontal: DEF_HP, vertical: DEF_VP);
const DEF_MARGIN = EdgeInsets.fromLTRB(DEF_HP, DEF_VP, DEF_HP, 0);

const DEF_BORDER_RADIUS = P2;
const DEF_BTN_BORDER_RADIUS = MIN_BTN_HEIGHT / 2;
const DEF_BORDER_WIDTH = P_3;
const DEF_BAR_HEIGHT = P8;
const MIN_BTN_HEIGHT = P8;
const DEF_TAPPABLE_ICON_SIZE = kIsWeb ? P5 : P6;

const double SCR_XXS_WIDTH = 290;
const double SCR_XS_WIDTH = 364;
const double SCR_XS_HEIGHT = 480;

const double SCR_S_WIDTH = 480;
const double SCR_S_HEIGHT = 640;

const double SCR_M_WIDTH = 640;
const double SCR_M_HEIGHT = 860;

const double SCR_L_WIDTH = 760;
const double SCR_XL_WIDTH = 960;
const double SCR_XXL_WIDTH = 1280;

const TEXT_SAVE_DELAY_DURATION = Duration(milliseconds: 500);
const KB_RELATED_ANIMATION_DURATION = Duration(milliseconds: 300);

double get cardElevation => kIsWeb ? 3 : 1;
double get buttonElevation => kIsWeb ? 3 : 1;
