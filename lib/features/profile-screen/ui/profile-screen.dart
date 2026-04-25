import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kontaku/core/models/account_model.dart';
import 'package:kontaku/core/utils/auth-check.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontaku/features/authentication/logic/bloc/authentication.dart';
import 'package:kontaku/features/authentication/logic/event-state/authentication-event-state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'loading...',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'loading...',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'dummypassword123',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: 'loading...',
  );
  Uint8List? _pickedAvatarBytes;
  String? _profileImageUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateProfileData();
  }

  void updateProfileData() async {
    final myProfile = await getMyProfile(
      authenticationBloc: context.read<AuthenticationBloc>(),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _nameController.text = myProfile.username;
      _emailController.text = myProfile.email ?? 'No email';
      _phoneController.text = myProfile.phoneNumber;
      _profileImageUrl = myProfile.imageProfile;
    });

    if (Kontaku.checkPlatform()) {
      final cachedBytes = await _readAvatarFromLocalCache();
      if (!mounted) {
        return;
      }

      if (cachedBytes != null) {
        setState(() {
          _pickedAvatarBytes = cachedBytes;
        });
        return;
      }

      await _cacheRemoteAvatar(myProfile.imageProfile);
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      if (!mounted) {
        return;
      }
      final bytes = await pickAndCompressImage(context);
      if (bytes == null) {
        return;
      }

      setState(() {
        // Tampilkan avatar baru secepat mungkin agar terasa responsif.
        _pickedAvatarBytes = bytes;
      });
      await _writeAvatarToLocalCache(bytes);

      final url = await uploadImage(imageBytes: bytes, context: context);
      if (!mounted) {
        return;
      }
      setState(() {
        _profileImageUrl = url;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
    }
  }

  Future<void> _cacheRemoteAvatar(String? rawUrl) async {
    final url = rawUrl?.trim() ?? '';
    if (url.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') {
      return;
    }

    try {
      final bytes = await _downloadImageBytes(uri);
      if (!mounted || bytes == null) {
        return;
      }

      setState(() {
        _pickedAvatarBytes = bytes;
      });
      await _writeAvatarToLocalCache(bytes);
    } catch (_) {
      // Keep UI usable even if remote avatar can't be downloaded.
    }
  }

  Future<Uint8List?> _downloadImageBytes(Uri uri) async {
    final client = HttpClient();

    if (kDebugMode && uri.host.toLowerCase() == 'i.ibb.co') {
      client.badCertificateCallback = (cert, host, port) {
        return host.toLowerCase() == uri.host.toLowerCase();
      };
    }

    try {
      final request = await client.getUrl(uri);
      final response = await request.close();

      final contentType = response.headers.contentType;
      final isImageContent = contentType?.primaryType == 'image';
      if (!isImageContent) {
        return null;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final bytes = await consolidateHttpClientResponseBytes(
          response,
        ).timeout(const Duration(seconds: 8));
        if (_looksLikeImageBytes(bytes)) {
          return bytes;
        }
      }
      return null;
    } finally {
      client.close(force: true);
    }
  }

  bool _looksLikeImageBytes(Uint8List bytes) {
    if (bytes.length < 12) {
      return false;
    }

    final isJpg = bytes[0] == 0xFF && bytes[1] == 0xD8;
    final isPng =
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
    final isWebp =
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50;

    return isJpg || isPng || isWebp;
  }

  Future<String?> _avatarCachePath() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return null;
    }

    final dir = Directory('${Directory.systemTemp.path}/kontaku_avatar_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return '${dir.path}/avatar_$uid.bin';
  }

  Future<Uint8List?> _readAvatarFromLocalCache() async {
    final path = await _avatarCachePath();
    if (path == null) {
      return null;
    }

    final file = File(path);
    if (!await file.exists()) {
      return null;
    }

    final bytes = await file.readAsBytes();
    if (!_looksLikeImageBytes(bytes)) {
      return null;
    }
    return bytes;
  }

  Future<void> _writeAvatarToLocalCache(Uint8List bytes) async {
    final path = await _avatarCachePath();
    if (path == null || !_looksLikeImageBytes(bytes)) {
      return;
    }

    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }

  ImageProvider<Object>? _resolveAvatarImage() {
    if (_pickedAvatarBytes != null) {
      return MemoryImage(_pickedAvatarBytes!);
    }

    // Hindari NetworkImage langsung, karena beberapa ISP mengarahkan host gambar
    // ke halaman blokir non-image yang menyebabkan exception decode.
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;
    final avatarRadius = isCompact ? 36.0 : 50.0;
    final avatarInnerRadius = isCompact ? 34.0 : 48.0;
    final headerTop = isCompact ? 42.0 : 64.0;
    final sectionTop = isCompact ? 204.0 : 250.0;
    final actionTop = isCompact ? 364.0 : 450.0;
    final formWidth = isCompact
        ? Kontaku.vw(86, context)
        : Kontaku.vw(80, context);
    final actionWidth = isCompact
        ? Kontaku.vw(66, context)
        : Kontaku.vw(60, context);
    final buttonHeight = isCompact ? 36.0 : 42.0;
    final logoutHeight = isCompact ? 40.0 : 44.0;
    final avatarImage = _resolveAvatarImage();

    return Container(
      width: Kontaku.vw(100, context),
      height: Kontaku.vh(100, context),
      color: Color(Kontaku.colors[1]),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            child: Container(
              width: Kontaku.vw(100, context) - (isCompact ? 72 : 80),
              height: Kontaku.vh(100, context),
              decoration: BoxDecoration(
                color: Color(Kontaku.colors[2]),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Kontaku.vw(100, context) * 0.35),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            left: 0,
            top: headerTop,
            child: Column(
              children: [
                Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(avatarRadius),
                      onTap: _pickProfileImage,
                      child: CircleAvatar(
                        radius: avatarRadius,
                        backgroundColor: Color(Kontaku.sand),
                        child: CircleAvatar(
                          radius: avatarInnerRadius,
                          backgroundColor: Color(Kontaku.cream),
                          backgroundImage: avatarImage,
                          child: avatarImage == null
                              ? Icon(
                                  Icons.person,
                                  size: isCompact ? 42 : 50,
                                  color: Color(Kontaku.dark),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isCompact ? 12 : 16),
                Center(
                  child: Container(
                    child: Column(
                      children: [
                        Text(
                          _nameController.text,
                          style: GoogleFonts.montserrat(
                            fontSize: isCompact ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: Color(Kontaku.dark),
                          ),
                        ),
                        Container(
                          height: 4,
                          width: isCompact ? 220 : 300,
                          color: Color(Kontaku.lightBeige),
                        ),
                        Text(
                          "+62 812-3456-7890",
                          style: GoogleFonts.outfit(
                            fontSize: isCompact ? 13 : 16,
                            color: Color(Kontaku.dark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: sectionTop,
            right: 0,
            left: 0,
            child: Center(
              child: SizedBox(
                width: formWidth,
                child: Column(
                  spacing: isCompact ? 10 : 16,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: textFieldProfile(
                            labelText: 'Nama Pengguna',
                            controller: _nameController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: textFieldProfile(
                            labelText: 'Email',
                            controller: _emailController,
                          ),
                        ),
                      ],
                    ),
                    textFieldProfile(
                      labelText: 'Password',
                      controller: _passwordController,
                    ),
                    textFieldProfile(
                      labelText: 'Nomor Telepon',
                      controller: _phoneController,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: actionTop,
            right: 0,
            left: isCompact ? 42 : 64,
            child: Center(
              child: SizedBox(
                width: actionWidth,
                child: Column(
                  spacing: isCompact ? 7 : 8,
                  children: [
                    SizedBox(
                      height: buttonHeight,
                      child: elevatedButtonProfile(
                        text: 'Tema',
                        icon: const Icon(Icons.palette),
                      ),
                    ),
                    SizedBox(
                      height: buttonHeight,
                      child: elevatedButtonProfile(
                        text: 'Bahasa',
                        icon: const Icon(Icons.language),
                      ),
                    ),
                    // SizedBox(
                    //   height: buttonHeight,
                    //   child: elevatedButtonProfile(
                    //     text: 'Notifikasi',
                    //     icon: const Icon(Icons.notifications),
                    //   ),
                    // ),
                    SizedBox(
                      height: buttonHeight,
                      child: elevatedButtonProfile(
                        text: 'Bantuan',
                        icon: const Icon(Icons.help),
                      ),
                    ),
                    SizedBox(
                      height: buttonHeight,
                      child: elevatedButtonProfile(
                        text: 'Tentang Kami',
                        icon: const Icon(Icons.info),
                      ),
                    ),
                    SizedBox(
                      width: Kontaku.vw(80, context),
                      height: logoutHeight,
                      child: elevatedButtonProfileLogout(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          //make an icon that can action when clicked to edit profile
          Positioned(
            top: 18,
            right: 18,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                context.go('/profile-edit');
                debugPrint('Edit profile tapped');
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: SizedBox(
                  child: Icon(
                    Icons.edit,
                    size: isCompact ? 18 : 24,
                    color: Color(Kontaku.dark),
                  ),
                ),
              ),
            ),

            // GestureDetector(
            //   onTap: () {
            //     context.go('/profile-edit');
            //     debugPrint('Edit profile tapped');
            //   },
            //   child: SizedBox(
            //     child: Icon(
            //       Icons.edit,
            //       size: isCompact ? 18 : 24,
            //       color: Color(Kontaku.dark),
            //     ),
            //   ),
            // ),
          ),
        ],
      ),
    );
  }

  ElevatedButton elevatedButtonProfileLogout() {
    return ElevatedButton(
      onPressed: () {
        context.read<AuthenticationBloc>().add(LoggedOut());
        debugPrint('Logout tapped');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE11B1B),
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        'Log Out',
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  ElevatedButton elevatedButtonProfile({
    required String text,
    required Widget icon,
  }) {
    return ElevatedButton(
      onPressed: () {
        debugPrint('$text tapped');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(Kontaku.accent),
        foregroundColor: Color(Kontaku.dark),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: icon,
            ),
          ),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(Kontaku.dark),
            ),
          ),
        ],
      ),
    );
  }

  TextField textFieldProfile({
    double? width,
    required String labelText,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      showCursor: false,
      style: GoogleFonts.outfit(
        color: Color(Kontaku.dark),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.outfit(
          color: Color(Kontaku.dark),
          fontSize: 13,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        filled: true,
        fillColor: Color(Kontaku.sand),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Color(Kontaku.dark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Color(Kontaku.dark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Color(Kontaku.dark)),
        ),
      ),
    );
  }
}

Future<AccountModel> getMyProfile({
  required AuthenticationBloc authenticationBloc,
}) async {
  try {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final currentUserUid = checkAuthenticationStatus(authenticationBloc);
    DocumentSnapshot snapshot = await db
        .collection('userDetails')
        .doc(currentUserUid)
        .get();
    //get email from firebase auth
    String email = FirebaseAuth.instance.currentUser!.email!;

    AccountModel myProfile = AccountModel(
      username: snapshot['username'] ?? 'Unknown',
      email: email,
      uid: currentUserUid,
      imageProfile: snapshot['imageProfile'] ?? '',
      phoneNumber: snapshot['phoneNumber'] ?? '',
    );

    //print myProfile data to console
    print('My Profile:');
    print('Username: ${myProfile.username}');
    print('Email: ${myProfile.email}');
    print('UID: ${myProfile.uid}');
    print('Image Profile: ${myProfile.imageProfile}');
    print('Phone Number: ${myProfile.phoneNumber}');
    // debugPrint('Profile data fetched: ${snapshot.data()}');
    debugPrint('User email: $email');
    return myProfile;
  } catch (e) {
    debugPrint('Error fetching profile data: $e');
    rethrow;
  }
}

Future<String> uploadImage({
  required Uint8List imageBytes,
  required BuildContext context,
}) async {
  try {
    const String IMGBB_API_KEY = "aced5b107ad1946e43cc4880c1d114fc";
    final String IMGBB_API_URL =
        "https://api.imgbb.com/1/upload?key=$IMGBB_API_KEY";

    final request = http.MultipartRequest('POST', Uri.parse(IMGBB_API_URL));
    request.files.add(
      http.MultipartFile.fromBytes('image', imageBytes, filename: 'upload.jpg'),
    );

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final Map<String, dynamic> resJson = jsonDecode(responseData);

    if (response.statusCode == 200 && resJson['success'] == true) {
      final url = resJson['data']?['url'] as String?;
      if (url != null && url.trim().isNotEmpty) {
        print("Image uploaded successfully: $url");
        editProfile(imageProfileUrl: url, context: context);
        return url;
      }
      throw Exception("Response tidak berisi URL");
    } else {
      throw Exception(
        "Failed to upload image: ${response.statusCode} - ${resJson['error']?['message'] ?? responseData}",
      );
    }
  } catch (e) {
    print("Error uploading image: $e");
    rethrow;
  }
}

Future<Uint8List?> pickAndCompressImage(BuildContext context) async {
  final ImagePicker Picker = ImagePicker();
  final XFile? pickedImage = await Picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );
  if (pickedImage == null) {
    return null;
  }
  // Compress image before upload
  final XFile? compressedFile = await testCompressAndGetFile(pickedImage);
  final Uint8List bytes = await compressedFile!.readAsBytes();
  return bytes;
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

    // Convert result to String if it's XFile
    final String filePath = result is XFile ? result.path : result.toString();
    return XFile(filePath);
  } catch (e) {
    print('Error compressing image: $e');
    return null;
  }
}

Future<void> editProfile({
  required String imageProfileUrl,
  required BuildContext context,
}) async {
  print("Updating profile with image URL: $imageProfileUrl");
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return;
  }

  await FirebaseFirestore.instance.collection('userDetails').doc(user.uid).set({
    'imageProfile': imageProfileUrl,
  }, SetOptions(merge: true));
}
