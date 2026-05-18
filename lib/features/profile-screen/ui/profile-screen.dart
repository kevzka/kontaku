import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kontaku/core/models/account_model.dart';
import 'package:kontaku/core/utils/auth-check.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:kontaku/core/utils/image_cache_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontaku/features/authentication/logic/bloc/authentication.dart';
import 'package:kontaku/features/authentication/logic/event-state/authentication-event-state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  List<int> get _themeColors => Kontaku.colors;
  Color get _pageBackgroundColor => Color(_themeColors[1]);
  Color get _panelColor => Color(_themeColors[2]);
  Color get _surfaceColor => Color(_themeColors[3]);
  Color get _primaryTextColor => Color(_themeColors[0]);
  Color get _dividerColor => Color(_themeColors[4]);

  @override
  void initState() {
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
    print(_profileImageUrl);
    setState(() {
      _nameController.text = myProfile.username;
      _emailController.text = myProfile.email ?? 'No email';
      _phoneController.text = myProfile.phoneNumber;
      _profileImageUrl = myProfile.profilePath;
    });

    if (Kontaku.checkPlatform()) {
      final cachedBytes = await ImageCacheService.readFromCache(
        cacheKey: FirebaseAuth.instance.currentUser?.uid ?? 'default_profile',
      );
      if (!mounted) {
        return;
      }

      if (cachedBytes != null) {
        setState(() {
          _pickedAvatarBytes = cachedBytes;
        });
        return;
      }
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      if (!mounted) {
        return;
      }
      final imageData = await pickImageBytes(context);
      if (imageData == null) {
        return;
      }
      final bytes = imageData.bytes;

      setState(() {
        // Tampilkan avatar baru secepat mungkin agar terasa responsif.
        _pickedAvatarBytes = bytes;
      });

      // Cache locally
      await ImageCacheService.writeToCache(
        cacheKey: FirebaseAuth.instance.currentUser?.uid ?? 'default_profile',
        bytes: bytes,
      );

      final url = await uploadImage(
        imageBytes: bytes,
        fileName: imageData.fileName,
        context: context,
      );
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
    final avatarImageUrl = _profileImageUrl;

    return SafeArea(
      child: Container(
        width: Kontaku.vw(100, context),
        height: Kontaku.vh(100, context),
        color: _pageBackgroundColor,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              child: Container(
                width: Kontaku.vw(100, context) - (isCompact ? 72 : 50),
                height: Kontaku.vh(100, context),
                decoration: BoxDecoration(
                  color: _panelColor,
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
                          backgroundColor: _panelColor,
                          child: CircleAvatar(
                            radius: avatarInnerRadius,
                            backgroundColor: _surfaceColor,
                            backgroundImage:
                                avatarImageUrl != null &&
                                    avatarImageUrl!.isNotEmpty
                                ? NetworkImage(avatarImageUrl!)
                                : null,
                            child:
                                avatarImageUrl == null ||
                                    avatarImageUrl!.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: isCompact ? 42 : 50,
                                    color: _primaryTextColor,
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
                              color: _primaryTextColor,
                            ),
                          ),
                          Container(
                            height: 4,
                            width: isCompact ? 220 : 300,
                            color: _dividerColor,
                          ),
                          Text(
                            _phoneController.text,
                            style: GoogleFonts.outfit(
                              fontSize: isCompact ? 13 : 16,
                              color: _primaryTextColor,
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
                        obscureText: true,
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
                          functionCallbackProfile: () {
                            setState(() {
                              Kontaku.toggleDarkMode();
                            });
                            debugPrint(
                              'Tema tapped: ${Kontaku.isDarkMode ? 'dark' : 'light'}',
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: buttonHeight,
                        child: elevatedButtonProfile(
                          text: 'Bahasa',
                          icon: const Icon(Icons.language),
                          functionCallbackProfile: () {
                            debugPrint('Bahasa tapped');
                          },
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
                          functionCallbackProfile: () {
                            debugPrint('Bantuan tapped');
                          },
                        ),
                      ),
                      SizedBox(
                        height: buttonHeight,
                        child: elevatedButtonProfile(
                          text: 'Tentang Kami',
                          icon: const Icon(Icons.info),
                          functionCallbackProfile: () {
                            debugPrint('Tentang Kami tapped');
                          },
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
                      color: _primaryTextColor,
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
    required VoidCallback functionCallbackProfile,
  }) {
    return ElevatedButton(
      onPressed: functionCallbackProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: _pageBackgroundColor,
        foregroundColor: _primaryTextColor,
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
              color: _primaryTextColor,
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
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      readOnly: true,
      showCursor: false,
      style: GoogleFonts.outfit(
        color: _primaryTextColor,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.outfit(color: _primaryTextColor, fontSize: 13),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        filled: true,
        fillColor: _surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: _primaryTextColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: _primaryTextColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: _primaryTextColor),
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
      profilePath: snapshot['profilePath'] ?? '',
      phoneNumber: snapshot['phoneNumber'] ?? '',
    );

    //print myProfile data to console
    print('My Profile:');
    print('Username: ${myProfile.username}');
    print('Email: ${myProfile.email}');
    print('UID: ${myProfile.uid}');
    print('Image Profile: ${myProfile.profilePath}');
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
  required String fileName,
  required BuildContext context,
}) async {
  try {
    const String IMGBB_API_KEY = "aced5b107ad1946e43cc4880c1d114fc";
    final String IMGBB_API_URL =
        "https://api.imgbb.com/1/upload?key=$IMGBB_API_KEY";

    final request = http.MultipartRequest('POST', Uri.parse(IMGBB_API_URL));
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: fileName,
      ),
    );

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final Map<String, dynamic> resJson = jsonDecode(responseData);

    if (response.statusCode == 200 && resJson['success'] == true) {
      dynamic url = resJson['data']?['url'] as String?;
      url = url?.replaceAll('https://i.ibb.co/', 'https://i.ibb.co.com/');
      dynamic deleteProfilePathUrl = resJson['data']?['delete_url'] as String?;
      deleteProfilePathUrl = deleteProfilePathUrl?.replaceAll(
        'https://i.ibb.co/',
        'https://i.ibb.co.com/',
      );
      if (url != null && url.trim().isNotEmpty) {
        print("Image uploaded successfully: $url");
        editProfile(
          profilePathUrl: url,
          deleteProfilePathUrl: deleteProfilePathUrl,
          context: context,
        );
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

Future<void> editProfile({
  required String profilePathUrl,
  required String deleteProfilePathUrl,
  required BuildContext context,
}) async {
  print("Updating profile with image URL: $profilePathUrl");
  final user = FirebaseAuth.instance.currentUser;
  String? previousDeleteProfilePathUrl;
  if (user == null) {
    return;
  }

  try {
    previousDeleteProfilePathUrl = await FirebaseFirestore.instance
        .collection('userDetails')
        .doc(user.uid)
        .get()
        .then((snapshot) => snapshot['deleteProfilePathUrl'] as String?);
  } catch (e) {
    print("Error fetching previous deleteProfilePathUrl: $e");
  }

  print(
    "Deleting previous profile image at URL: $previousDeleteProfilePathUrl",
  );
  if (previousDeleteProfilePathUrl != null &&
      previousDeleteProfilePathUrl.isNotEmpty) {
    await deleteProfile(previousDeleteProfilePathUrl);
  }

  print(
    "Saving new profile data to Firestore for user ${user.uid}, profilePathUrl: $profilePathUrl, deleteProfilePathUrl: $deleteProfilePathUrl",
  );
  try {
    await FirebaseFirestore.instance
        .collection('userDetails')
        .doc(user.uid)
        .set({
          'profilePath': profilePathUrl,
          'deleteProfilePathUrl': deleteProfilePathUrl,
        }, SetOptions(merge: true));
  } catch (e) {
    print("Error updating profile in Firestore: $e");
  }
  print(
    "Profile updated successfully in Firestore with new image URL: $profilePathUrl deleteProfilePath: $deleteProfilePathUrl",
  );
}

Future<void> deleteProfile(String deleteProfilePathUrl) async {
  try {
    // Contoh URL input: "https://ibb.co/JRw9r7F2/362aaa1e716a2a8164c2d4c4232b9105"
    // Kita bersihkan dulu domainnya agar tersisa: "JRw9r7F2/362aaa1e716a2a8164c2d4c4232b9105"
    String cleanPath = deleteProfilePathUrl
        .replaceAll('https://ibb.co/', '')
        .replaceAll('https://i.ibb.co.com/', '') // antisipasi subdomain lain
        .replaceAll('https://i.ibb.co/', '');

    List<String> parts = cleanPath.split('/');
    if (parts.length < 2) {
      print("Format URL tidak valid, pastikan ada ID dan Hash.");
      return;
    }

    final deleteId = parts[0];
    final deleteHash = parts[1];
    final pathname = '/$deleteId/$deleteHash';

    print("Deleting image with ID: $deleteId and Hash: $deleteHash");

    final uri = Uri.parse('https://ibb.co/json');

    // Menggunakan MultipartRequest karena catatan reverse engineering menyebutkan 'multipart/form-data'
    var request = http.MultipartRequest('POST', uri)
      ..fields['pathname'] = pathname
      ..fields['action'] = 'delete'
      ..fields['delete'] = 'image'
      ..fields['from'] = 'resource'
      ..fields['deleting[id]'] = deleteId
      ..fields['deleting[hash]'] = deleteHash;

    // Tambahkan header standar untuk mengelabui proteksi dasar (jika ada)
    request.headers.addAll({
      'X-Requested-With': 'XMLHttpRequest',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print('Image deleted successfully: ${response.body}');
    } else {
      print(
        'Failed to delete image: ${response.statusCode} - ${response.body}',
      );
    }
  } catch (e) {
    print('Error deleting image: $e');
  }
}
