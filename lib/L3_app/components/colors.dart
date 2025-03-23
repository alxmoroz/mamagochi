// Copyright (c) 2022. Alexandr Moroz

import 'package:flutter/cupertino.dart';

/// Цвета фона

/// светлая тема
const _b3R = 255;
const _b3G = 254;
const _b3B = 253;

const _b2R = 239;
const _b2G = 242;
const _b2B = 251;

const _b1R = 210;
const _b1G = 216;
const _b1B = 238;

const _b0R = 130;
const _b0G = 140;
const _b0B = 190;

/// темная тема
const _b3R_d = 54;
const _b3G_d = 60;
const _b3B_d = 86;

const _b2R_d = 43;
const _b2G_d = 48;
const _b2B_d = 73;

const _b1R_d = 24;
const _b1G_d = 30;
const _b1B_d = 56;

const _b0R_d = 2;
const _b0G_d = 6;
const _b0B_d = 24;

/// Цвета текста и элементов

// контраст между соседними цветами текста или элементами
const _fDC = 58;

/// светлая тема
const _f3R = _b1R - 38;
const _f3G = _b1G - 38;
const _f3B = _b1R - 22;

const _f2R = _f3R - _fDC;
const _f2G = _f3G - _fDC;
const _f2B = _f3B - _fDC;

const _f1R = _f2R - _fDC;
const _f1G = _f2G - _fDC;
const _f1B = _f2B - _fDC;

/// темная тема
const _f3R_d = _b3R_d + 38;
const _f3G_d = _b3G_d + 38;
const _f3B_d = _b3B_d + 26;

const _f2R_d = _f3R_d + _fDC;
const _f2G_d = _f3G_d + _fDC;
const _f2B_d = _f3B_d + _fDC;

const _f1R_d = _f2R_d + _fDC;
const _f1G_d = _f2G_d + _fDC;
const _f1B_d = _f2B_d + _fDC;

/// Белый - черный
const bwColor = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(255, _b3R, _b3G, _b3B),
  darkColor: Color.fromARGB(255, _b0R_d, _b0G_d, _b0B_d),
);

/// самый яркий фон (выпирающий цвет)
const b3Color = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(255, _b3R, _b3G, _b3B),
  darkColor: Color.fromARGB(255, _b3R_d, _b3G_d, _b3B_d),
);

/// основной фон
const b2Color = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(255, _b2R, _b2G, _b2B),
  darkColor: Color.fromARGB(255, _b2R_d, _b2G_d, _b2B_d),
);

/// второстепенный фон (нижний уровень)
const b1Color = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(255, _b1R, _b1G, _b1B),
  darkColor: Color.fromARGB(255, _b1R_d, _b1G_d, _b1B_d),
);

/// фон барьера диалогов
const defaultBarrierColor = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(240, _b1R, _b1G, _b1B),
  darkColor: Color.fromARGB(240, _b1R_d, _b1G_d, _b1B_d),
);

/// фон барьера клавиатуры

const b1BarrierColor = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(200, _b1R, _b1G, _b1B),
  darkColor: Color.fromARGB(200, _b1R_d, _b1G_d, _b1B_d),
);

const b2BarrierColor = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(200, _b2R, _b2G, _b2B),
  darkColor: Color.fromARGB(200, _b2R_d, _b2G_d, _b2B_d),
);

/// тень фона
const b0Color = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(255, _b0R, _b0G, _b0B),
  darkColor: Color.fromARGB(255, _b0R_d, _b0G_d, _b0B_d),
);

/// Цвета текста
///
/// основной цвет
const f1Color = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(255, _f1R, _f1G, _f1B),
  darkColor: Color.fromARGB(255, _f1R_d, _f1G_d, _f1B_d),
);

/// дополнительный цвет
const f2Color = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(255, _f2R, _f2G, _f2B),
  darkColor: Color.fromARGB(255, _f2R_d, _f2G_d, _f2B_d),
);

/// незаметный цвет
const f3Color = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(255, _f3R, _f3G, _f3B),
  darkColor: Color.fromARGB(255, _f3R_d, _f3G_d, _f3B_d),
);

/// Цвета элементов UI
///
const mainColor = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(255, 90, 111, 228),
  darkColor: Color.fromARGB(255, 100, 170, 255),
);

const greenColor = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(255, 31, 188, 180),
  darkColor: Color.fromARGB(255, 44, 197, 189),
);

const greenLightColor = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(42, 31, 188, 180),
  darkColor: Color.fromARGB(42, 44, 197, 189),
);

const dangerColor = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(255, 255, 140, 80),
  darkColor: Color.fromARGB(255, 255, 142, 90),
);

const warningColor = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(255, 255, 192, 8),
  darkColor: Color.fromARGB(255, 255, 200, 20),
);

// цвет текста на основной кнопке
const mainBtnTitleColor = b2Color;

// цвет для "прозрачного" апп-бара
const navbarColor = CupertinoDynamicColor.withBrightness(
  color: Color.fromARGB(0, 255, 255, 255),
  darkColor: Color.fromARGB(0, 0, 0, 0),
);

extension ResolvedColor on Color {
  Color resolve(BuildContext context) => CupertinoDynamicColor.resolve(this, context);
}
