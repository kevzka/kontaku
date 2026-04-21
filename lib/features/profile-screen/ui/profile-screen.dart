import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  final ImagePicker _picker = ImagePicker();
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
    return setState(() {
      _nameController.text = myProfile.username;
      _emailController.text = myProfile.email ?? 'No email';
      _phoneController.text = myProfile.phoneNumber;
      _profileImageUrl = myProfile.imageProfile;
    });
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedImage == null) {
        return;
      }
      final Uint8List bytes = await pickedImage.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() {
        _pickedAvatarBytes = bytes;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  ImageProvider<Object>? _resolveAvatarImage() {
    if (_pickedAvatarBytes != null) {
      return MemoryImage(_pickedAvatarBytes!);
    }
    if (_profileImageUrl != null && _profileImageUrl!.trim().isNotEmpty) {
      return NetworkImage(_profileImageUrl!);
    }
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
                          backgroundImage: _resolveAvatarImage(),
                          child:
                              _resolveAvatarImage() == null
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
