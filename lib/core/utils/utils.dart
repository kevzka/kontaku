import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class Kontaku {
  Kontaku._();

  static OverlayEntry? _activeSnackBar;

  static const int dark = 0xFF202226;
  static const int accent = 0xFFFFBB58;
  static const int sand = 0xFFE8E6D7;
  static const int cream = 0xFFF4F2E3;
  static const int lightBeige = 0xFFE2DEC1;

  static const List<int> colors = [dark, accent, sand, cream, lightBeige];

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

  static String normalizePhoneNumber(
    String phone, {
    IsoCode callerCountry = IsoCode.ID,
  }) {
    final parsedPhone = PhoneNumber.parse(phone, callerCountry: callerCountry);
    return parsedPhone.international
        .replaceAll('+', '')
        .replaceAll(RegExp(r'[^0-9]'), '');
  }

  static Future<void> snackbarNotification(
    BuildContext context,
    String message, {
    int snackBarDurationSeconds = 3,
  }) async {
    if (!context.mounted) return;

    _activeSnackBar?.remove();

    final overlay = Overlay.of(context, rootOverlay: true);

    _activeSnackBar = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: Kontaku.vw(100, context),
              height: 60,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Color(Kontaku.dark),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(seconds: snackBarDurationSeconds),
                      builder: (context, value, child) {
                        return FractionallySizedBox(
                          widthFactor: value,
                          child: child,
                        );
                      },
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Color(Kontaku.sand),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(Kontaku.cream),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_activeSnackBar!);
    await Future.delayed(Duration(seconds: snackBarDurationSeconds));

    if (!context.mounted) return;
    _activeSnackBar?.remove();
    _activeSnackBar = null;
  }
}
