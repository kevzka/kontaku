import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'dart:io' show Platform, File;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Kontaku {
  Kontaku._();

  static OverlayEntry? _activeSnackBar;

  static const int _lightDark = 0xFF202226;
  static const int _lightAccent = 0xFFFFBB58;
  static const int _lightSand = 0xFFE8E6D7;
  static const int _lightCream = 0xFFF4F2E3;
  static const int _lightBeige = 0xFFE2DEC1;

  static const List<int> _lightThemeColors = [
    _lightDark,
    _lightAccent,
    _lightSand,
    _lightCream,
    _lightBeige,
    0xFFE5D7A9,
    0xFFF5F0DD,
  ];

  static const List<int> _darkThemeColors = [
    _lightCream,
    0xFF171A20,
    0xFF232831,
    0xFF2D3340,
    0xFF404A5B,
    0xFF4B5768,
    0xFF5C677D,
  ];

  static int dark = _lightDark;
  static int accent = _lightAccent;
  static int sand = _lightSand;
  static int cream = _lightCream;
  static int lightBeige = _lightBeige;
  static List<int> colors = List<int>.from(_lightThemeColors);

  static final ValueNotifier<bool> darkModeNotifier = ValueNotifier(false);

  static bool get isDarkMode => darkModeNotifier.value;
  static List<int> get darkThemeColors => _darkThemeColors;

  static void setDarkMode(bool isDark) {
    final palette = themeColors(isDark: isDark);
    dark = palette[0];
    accent = palette[1];
    sand = palette[2];
    cream = palette[3];
    lightBeige = palette[4];
    colors = List<int>.from(palette);
    darkModeNotifier.value = isDark;
  }

  static void toggleDarkMode() {
    setDarkMode(!isDarkMode);
  }

  static List<int> themeColors({required bool isDark}) {
    return isDark ? _darkThemeColors : _lightThemeColors;
  }

  // Dark mode hex codes (string form) for easy reference in UI/theme logic
  static const String darkHex = '#202226'; // Background utama aplikasi
  static const String accentHex = '#C88B3A'; // Highlight / aksi
  static const String sandHex = '#E8E6D7'; // Teks utama / krem
  static const String creamHex = '#F4F2E3'; // Teks sekunder
  static const String lightBeigeHex =
      '#E8E6D7'; // Alternate name mapped to same as sand

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

  static bool checkPlatform() {
    if (kIsWeb) {
      print("Running on the Web"); // Must check this first!
    } else if (Platform.isAndroid) {
      print("Running on Android");
      return true;
    } else if (Platform.isIOS) {
      print("Running on iOS");
      return true;
    } else if (Platform.isMacOS) {
      print("Running on macOS");
    } else if (Platform.isWindows) {
      print("Running on Windows");
    } else if (Platform.isLinux) {
      print("Running on Linux");
    }
    return false;
  }
}

Future<Uint8List?> pickAndCompressImage(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  final XFile? picked = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );
  if (picked == null) return null;

  final XFile? compressedFile = await testCompressAndGetFile(picked);
  if (compressedFile == null) return null;
  return await compressedFile.readAsBytes();
}

Future<XFile?> testCompressAndGetFile(XFile? file) async {
  if (file == null) return null;

  final File imageFile = File(file.path);
  final String targetPath = '${imageFile.parent.path}/compressed_${file.name}';

  try {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 80,
    );

    if (result == null) return null;

    final String filePath = result.path;
    return XFile(filePath);
  } catch (e) {
    print('Error compressing image: $e');
    return null;
  }
}
