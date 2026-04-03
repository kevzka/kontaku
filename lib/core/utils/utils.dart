import 'package:flutter/material.dart';

class Kontaku {
  Kontaku._();

  static const int dark = 0xFF202226;
  static const int accent = 0xFFFFBB58;
  static const int sand = 0xFFE8E6D7;
  static const int cream = 0xFFF4F2E3;

  static const List<int> colors = [
    dark,
    accent,
    sand,
    cream,
  ];

  static double vw(int value, BuildContext context) {
    return MediaQuery.of(context).size.width * (value / 100);
  }

  static double vh(int value, BuildContext context) {
    return MediaQuery.of(context).size.height * (value / 100);
  }
}
