import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Kontaku {
  Kontaku._();

  static const int dark = 0xFF202226;
  static const int accent = 0xFFFFBB58;
  static const int sand = 0xFFE8E6D7;
  static const int cream = 0xFFF4F2E3;

  static const List<int> colors = [dark, accent, sand, cream];

  static double vw(int value, BuildContext context) {
    return MediaQuery.of(context).size.width * (value / 100);
  }

  static double vh(int value, BuildContext context) {
    return MediaQuery.of(context).size.height * (value / 100);
  }

  static String decodeBase64Msg(String encoded) {
    try {
      final decodedBytes = base64.decode(encoded);
      return utf8.decode(decodedBytes);
    } catch (e) {
      print('❌ Gagal decode Base64: $e');
      return '[Pesan tidak bisa ditampilkan]';
    }
  }

  static String encodeBase64Msg(String rawText) {
    return base64.encode(utf8.encode(rawText));
  }

  static String sha256Hash(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  static String buildStablePairHashId(String firstId, String secondId) {
    final ids = [firstId, secondId]..sort();
    return sha256Hash(ids.join('_'));
  }
}
