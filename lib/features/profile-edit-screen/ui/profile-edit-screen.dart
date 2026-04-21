import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kontaku/core/models/account_model.dart';
import 'package:kontaku/core/utils/auth-check.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontaku/features/authentication/logic/bloc/authentication.dart';
import 'package:kontaku/features/authentication/logic/event-state/authentication-event-state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'loading...',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'loading...',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'password123',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: 'loading...',
  );

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
    return setState(() {
      _nameController.text = myProfile.username;
      _emailController.text = myProfile.email ?? 'No email';
      _phoneController.text = myProfile.phoneNumber;
    });
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

    return Scaffold(
      backgroundColor: Color(Kontaku.colors[1]),
      body: SafeArea(
        child: Container(
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
                      child: SizedBox(
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: Color(Kontaku.sand),
                          child: CircleAvatar(
                            radius: avatarInnerRadius,
                            backgroundColor: Color(Kontaku.cream),
                            child: Icon(
                              Icons.person,
                              size: isCompact ? 42 : 50,
                              color: Color(Kontaku.dark),
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
                              "Nama anda muncul disini",
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
                              "Nomor anda muncul disini",
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
                        Column(
                          spacing: 8,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 36.0,
                              child: ElevatedButton(
                                onPressed: () async {
                                  print("Save button tapped");
                                  editProfile(
                                    username: _nameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    phoneNumber: _phoneController.text,
                                    context: context,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF95BE67),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  "Simpan",
                                  style: GoogleFonts.outfit(
                                    fontSize: isCompact ? 12 : 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 36.0,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (dialogContext) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                        child: Center(
                                          child: Container(
                                            width: isCompact ? 280 : 300,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: isCompact
                                                        ? 18
                                                        : 20,
                                                    vertical: isCompact
                                                        ? 24
                                                        : 30,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        'Batalkan pilihan ini?',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.outfit(
                                                              fontSize:
                                                                  isCompact
                                                                  ? 18
                                                                  : 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  const Color(
                                                                    0xFF111111,
                                                                  ),
                                                            ),
                                                      ),
                                                      SizedBox(
                                                        height: isCompact
                                                            ? 14
                                                            : 18,
                                                      ),
                                                      Text(
                                                        'Yakin ingin membatalkan pilihan?',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.outfit(
                                                              fontSize:
                                                                  isCompact
                                                                  ? 15
                                                                  : 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  const Color(
                                                                    0xFF222222,
                                                                  ),
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Divider(
                                                  height: 1,
                                                  thickness: 1,
                                                  color: Color(0xFFD7D7D7),
                                                ),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        dialogContext,
                                                      ).pop();
                                                      context.go(
                                                        '/mainNavigation/2',
                                                      );
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.red,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: isCompact
                                                                ? 16
                                                                : 18,
                                                          ),
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .zero,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'Batalkan',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: isCompact
                                                            ? 18
                                                            : 20,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Divider(
                                                  height: 1,
                                                  thickness: 1,
                                                  color: Color(0xFFD7D7D7),
                                                ),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        dialogContext,
                                                      ).pop();
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          const Color(
                                                            0xFF111111,
                                                          ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: isCompact
                                                                ? 16
                                                                : 18,
                                                          ),
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .zero,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'Tetap mengedit',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: isCompact
                                                            ? 18
                                                            : 20,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: const Color(
                                                          0xFF111111,
                                                        ),
                                                      ),
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
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A474A),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  "Batal",
                                  style: GoogleFonts.outfit(
                                    fontSize: isCompact ? 12 : 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                    print('icon back button tapped');
                    context.go('/mainNavigation/2');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: SvgPicture.asset(
                      'assets/icons/iconBack.svg',
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        Color(Kontaku.dark),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
      // showCursor: false,
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

Future<void> editProfile({
  required String username,
  required String email,
  required String password,
  required String phoneNumber,
  required BuildContext context,
}) async {
  print(
    "Editing profile with username: $username, email: $email, phone: $phoneNumber",
  );
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return;
  }

  await user.updateDisplayName(username);

  if (user.email != email) {
    print("Updating email...");
    await user.verifyBeforeUpdateEmail(email);
  }

  await FirebaseFirestore.instance.collection('userDetails').doc(user.uid).set({
    'username': username,
    'email': email,
    'phoneNumber': phoneNumber,
  }, SetOptions(merge: true));
  context.read<AuthenticationBloc>().add(LoggedOut());
}
