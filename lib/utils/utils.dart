import 'package:flutter/material.dart';


const Kontaku = {
  'color': [0xFF202226, 0xFFFFBB58, 0xFFE8E6D7, 0xFFF4F2E3]
};
double vw(int value, BuildContext context) {
  return MediaQuery.of(context).size.width * (value / 100);
}
double vh(int value, BuildContext context) {
  return MediaQuery.of(context).size.height * (value / 100);
}
